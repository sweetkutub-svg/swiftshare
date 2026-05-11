const logger = require('./logger');
const roomManager = require('./room_manager');

function setupSocketHandlers(io) {
  io.on('connection', (socket) => {
    logger.info(`Client connected`, { socketId: socket.id, ip: socket.handshake.address });

    socket.on('create-room', (data, callback) => {
      try {
        const room = roomManager.createRoom(socket.id);
        socket.join(room.id);
        if (typeof callback === 'function') {
          callback({ success: true, roomId: room.id });
        }
      } catch (err) {
        logger.error(`Error creating room`, { error: err.message });
        if (typeof callback === 'function') {
          callback({ success: false, error: 'Failed to create room' });
        }
      }
    });

    socket.on('join-room', (data, callback) => {
      try {
        const { roomId } = data;
        const room = roomManager.joinRoom(roomId, socket.id);
        if (!room) {
          if (typeof callback === 'function') {
            callback({ success: false, error: 'Room not found or already occupied' });
          }
          return;
        }
        socket.join(roomId);
        if (typeof callback === 'function') {
          callback({ success: true, roomId: room.id });
        }
        socket.to(roomId).emit('receiver-joined', { receiverSocketId: socket.id });
        logger.info(`Receiver joined room`, { roomId, socketId: socket.id });
      } catch (err) {
        logger.error(`Error joining room`, { error: err.message });
        if (typeof callback === 'function') {
          callback({ success: false, error: 'Failed to join room' });
        }
      }
    });

    socket.on('room-metadata', (data) => {
      const { roomId, metadata } = data;
      roomManager.updateRoomActivity(roomId);
      roomManager.setRoomMetadata(roomId, metadata);
      socket.to(roomId).emit('room-metadata', metadata);
    });

    socket.on('webrtc-offer', (data) => {
      const { roomId, offer } = data;
      roomManager.updateRoomActivity(roomId);
      socket.to(roomId).emit('webrtc-offer', { offer, senderSocketId: socket.id });
      logger.debug(`WebRTC offer relayed`, { roomId });
    });

    socket.on('webrtc-answer', (data) => {
      const { roomId, answer } = data;
      roomManager.updateRoomActivity(roomId);
      socket.to(roomId).emit('webrtc-answer', { answer, senderSocketId: socket.id });
      logger.debug(`WebRTC answer relayed`, { roomId });
    });

    socket.on('webrtc-ice-candidate', (data) => {
      const { roomId, candidate } = data;
      roomManager.updateRoomActivity(roomId);
      socket.to(roomId).emit('webrtc-ice-candidate', { candidate, senderSocketId: socket.id });
    });

    socket.on('transfer-complete', (data) => {
      const { roomId } = data;
      roomManager.updateRoomActivity(roomId);
      socket.to(roomId).emit('transfer-complete');
      logger.info(`Transfer marked complete`, { roomId });
    });

    socket.on('transfer-cancel', (data) => {
      const { roomId } = data;
      socket.to(roomId).emit('transfer-cancel');
      roomManager.closeRoom(roomId);
      logger.info(`Transfer cancelled`, { roomId });
    });

    socket.on('disconnect', (reason) => {
      logger.info(`Client disconnected`, { socketId: socket.id, reason });
      roomManager.removeSocket(socket.id);
    });
  });
}

module.exports = { setupSocketHandlers };
