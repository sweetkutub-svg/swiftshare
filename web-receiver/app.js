/**
 * SwiftShare Web Receiver
 * Proprietary & Confidential. All Rights Reserved.
 * Handles WebRTC DataChannel file reception in the browser.
 */

const SIGNALING_URL = window.location.hostname === 'localhost'
  ? 'http://localhost:3000'
  : 'https://your-railway-url.railway.app';

const ICE_URL = `${SIGNALING_URL}/ice-config`;

let socket = null;
let pc = null;
let dataChannel = null;
let currentRoomId = null;
let receivedChunks = [];
let expectedFile = null;
let bytesReceived = 0;
let startTime = 0;

const $ = (id) => document.getElementById(id);
const hide = (id) => $(id).classList.add('hidden');
const show = (id) => $(id).classList.remove('hidden');
const setBadge = (text, cls) => {
  const b = $('connectionBadge');
  b.textContent = text;
  b.className = 'badge' + (cls ? ' ' + cls : '');
};

async function fetchIceServers() {
  try {
    const res = await fetch(ICE_URL);
    if (!res.ok) throw new Error('Failed to fetch ICE config');
    const data = await res.json();
    return data.iceServers;
  } catch (err) {
    console.warn('Using default STUN servers');
    return [{ urls: 'stun:stun.l.google.com:19302' }];
  }
}

function initSocket() {
  if (socket) return;
  const script = document.createElement('script');
  script.src = 'https://cdn.socket.io/4.7.2/socket.io.min.js';
  script.onload = () => {
    socket = window.io(SIGNALING_URL, { transports: ['websocket', 'polling'] });
    socket.on('connect', () => { console.log('Signaling connected'); });
    socket.on('webrtc-offer', handleOffer);
    socket.on('webrtc-ice-candidate', handleRemoteIce);
    socket.on('transfer-complete', handleTransferComplete);
    socket.on('transfer-cancel', handleTransferCancel);
    socket.on('room-metadata', handleRoomMetadata);
    socket.on('disconnect', () => setBadge('Disconnected'));
  };
  document.head.appendChild(script);
}

async function handleOffer(data) {
  const { offer } = data;
  const iceServers = await fetchIceServers();
  pc = new RTCPeerConnection({ iceServers });
  pc.onicecandidate = (e) => {
    if (e.candidate) {
      socket.emit('webrtc-ice-candidate', { roomId: currentRoomId, candidate: e.candidate });
    }
  };
  pc.ondatachannel = (e) => {
    dataChannel = e.channel;
    setupDataChannel();
  };
  await pc.setRemoteDescription(new RTCSessionDescription(offer));
  const answer = await pc.createAnswer();
  await pc.setLocalDescription(answer);
  socket.emit('webrtc-answer', { roomId: currentRoomId, answer });
  setBadge('Connecting', 'connected');
}

function handleRemoteIce(data) {
  if (!pc || !data.candidate) return;
  pc.addIceCandidate(new RTCIceCandidate(data.candidate)).catch(console.error);
}

function handleRoomMetadata(meta) {
  expectedFile = meta;
  $('senderName').textContent = meta.senderName || 'Unknown Device';
  renderFileList(meta);
  hide('heroSection');
  show('transferPanel');
  setBadge('Incoming', 'connected');
}

function renderFileList(meta) {
  const list = $('fileList');
  list.innerHTML = '';
  const items = meta.files || [meta];
  items.forEach((f) => {
    const ext = f.name.split('.').pop().toUpperCase();
    const size = formatBytes(f.size);
    const el = document.createElement('div');
    el.className = 'file-item';
    el.innerHTML = `
      <div class="file-icon">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
      </div>
      <div class="file-details">
        <div class="file-name">${escapeHtml(f.name)}</div>
        <div class="file-meta">${ext} &middot; ${size}</div>
      </div>
    `;
    list.appendChild(el);
  });
}

function setupDataChannel() {
  dataChannel.binaryType = 'arraybuffer';
  dataChannel.onopen = () => {
    setBadge('Transferring', 'transferring');
    startTime = performance.now();
    receivedChunks = [];
    bytesReceived = 0;
  };
  dataChannel.onmessage = (e) => {
    if (typeof e.data === 'string') {
      const msg = JSON.parse(e.data);
      if (msg.type === 'metadata') {
        expectedFile = msg.payload;
      }
      if (msg.type === 'done') {
        finalizeFile();
      }
      return;
    }
    receivedChunks.push(new Uint8Array(e.data));
    bytesReceived += e.data.byteLength;
    updateProgress();
  };
  dataChannel.onclose = () => { setBadge('Closed'); };
  dataChannel.onerror = (err) => { console.error('DataChannel error', err); };
}

function updateProgress() {
  if (!expectedFile || !expectedFile.size) return;
  const pct = Math.min(100, Math.round((bytesReceived / expectedFile.size) * 100));
  const elapsedSec = (performance.now() - startTime) / 1000;
  const speed = elapsedSec > 0 ? (bytesReceived / elapsedSec / 1024 / 1024).toFixed(1) : '0.0';
  $('progressPercent').textContent = pct + '%';
  $('progressFill').style.width = pct + '%';
  $('progressSpeed').textContent = speed + ' MB/s';
  $('progressSize').textContent = formatBytes(bytesReceived) + ' / ' + formatBytes(expectedFile.size);
  $('progressFilename').textContent = expectedFile.name;
}

function finalizeFile() {
  const blob = new Blob(receivedChunks, { type: expectedFile?.type || 'application/octet-stream' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = expectedFile?.name || 'swiftshare-file';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  setTimeout(() => URL.revokeObjectURL(url), 5000);
  socket.emit('transfer-complete', { roomId: currentRoomId });
  showComplete();
}

function showComplete() {
  hide('transferPanel');
  show('completePanel');
  setBadge('Complete', 'connected');
  $('completeSubtitle').textContent = expectedFile
    ? `${escapeHtml(expectedFile.name)} saved to Downloads.`
    : 'All files saved to Downloads.';
}

function handleTransferComplete() {
  if (!dataChannel || dataChannel.readyState !== 'open') {
    showComplete();
  }
}

function handleTransferCancel() {
  resetState();
  hide('transferPanel');
  hide('completePanel');
  show('heroSection');
  setBadge('Waiting');
}

function resetState() {
  if (dataChannel) { try { dataChannel.close(); } catch (e) {} }
  if (pc) { try { pc.close(); } catch (e) {} }
  dataChannel = null; pc = null;
  receivedChunks = []; expectedFile = null; bytesReceived = 0;
}

function joinRoom() {
  const roomId = $('roomInput').value.trim();
  if (!roomId || roomId.length < 6) {
    $('roomInput').style.borderColor = 'var(--error)';
    setTimeout(() => $('roomInput').style.borderColor = '', 800);
    return;
  }
  currentRoomId = roomId;
  initSocket();
  const tryJoin = () => {
    if (!socket || !socket.connected) {
      setTimeout(tryJoin, 300);
      return;
    }
    socket.emit('join-room', { roomId }, (res) => {
      if (res.success) {
        setBadge('Joined', 'connected');
        hide('heroSection');
        show('transferPanel');
        $('actions').style.display = 'flex';
        show('progressArea');
      } else {
        alert(res.error || 'Failed to join room');
        currentRoomId = null;
      }
    });
  };
  tryJoin();
}

function acceptTransfer() {
  $('actions').style.display = 'none';
  show('progressArea');
}

function declineTransfer() {
  if (socket && currentRoomId) {
    socket.emit('transfer-cancel', { roomId: currentRoomId });
  }
  resetState();
  hide('transferPanel');
  show('heroSection');
  setBadge('Waiting');
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

$('joinBtn').addEventListener('click', joinRoom);
$('roomInput').addEventListener('keydown', (e) => { if (e.key === 'Enter') joinRoom(); });
$('acceptBtn').addEventListener('click', acceptTransfer);
$('declineBtn').addEventListener('click', declineTransfer);
$('receiveAnotherBtn').addEventListener('click', () => {
  resetState();
  hide('completePanel');
  show('heroSection');
  $('roomInput').value = '';
  setBadge('Waiting');
});

window.addEventListener('beforeunload', () => {
  if (socket && currentRoomId) {
    socket.emit('transfer-cancel', { roomId: currentRoomId });
  }
  resetState();
});
