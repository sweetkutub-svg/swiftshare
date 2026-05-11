const { v4: uuidv4 } = require('uuid');
const logger = require('./logger');

class RoomManager {
  constructor() {
    this.rooms = new Map();
    this.roomExpiryMs = parseInt(process.env.ROOM_EXPIRY_MS, 10) || 86400000;
    this.startCleanupInterval();
  }

  createRoom(senderSocketId) {
    const roomId = uuidv4().substring(0, 12);
    const room = {
      id: roomId,
      senderSocketId,
      receiverSocketId: null,
      createdAt: Date.now(),
      lastActivity: Date.now(),
      status: 'waiting',
      metadata: null
    };
    this.rooms.set(roomId, room);
    logger.info(`Room created`, { roomId, senderSocketId });
    return room;
  }

  getRoom(roomId) {
    return this.rooms.get(roomId) || null;
  }

  joinRoom(roomId, receiverSocketId) {
    const room = this.rooms.get(roomId);
    if (!room) return null;
    if (room.receiverSocketId) {
      logger.warn(`Room already has receiver`, { roomId });
      return null;
    }
    room.receiverSocketId = receiverSocketId;
    room.status = 'connected';
    room.lastActivity = Date.now();
    logger.info(`Receiver joined room`, { roomId, receiverSocketId });
    return room;
  }

  updateRoomActivity(roomId) {
    const room = this.rooms.get(roomId);
    if (room) {
      room.lastActivity = Date.now();
    }
  }

  setRoomMetadata(roomId, metadata) {
    const room = this.rooms.get(roomId);
    if (room) {
      room.metadata = metadata;
      room.lastActivity = Date.now();
    }
  }

  closeRoom(roomId) {
    const existed = this.rooms.delete(roomId);
    if (existed) {
      logger.info(`Room closed`, { roomId });
    }
    return existed;
  }

  removeSocket(socketId) {
    for (const [roomId, room] of this.rooms.entries()) {
      if (room.senderSocketId === socketId || room.receiverSocketId === socketId) {
        this.rooms.delete(roomId);
        logger.info(`Room removed due to socket disconnect`, { roomId, socketId });
      }
    }
  }

  startCleanupInterval() {
    setInterval(() => {
      const now = Date.now();
      let cleaned = 0;
      for (const [roomId, room] of this.rooms.entries()) {
        if (now - room.lastActivity > this.roomExpiryMs) {
          this.rooms.delete(roomId);
          cleaned++;
        }
      }
      if (cleaned > 0) {
        logger.info(`Cleaned up ${cleaned} expired rooms`);
      }
    }, 300000);
  }

  getStats() {
    return {
      totalRooms: this.rooms.size,
      waitingRooms: Array.from(this.rooms.values()).filter(r => r.status === 'waiting').length,
      activeRooms: Array.from(this.rooms.values()).filter(r => r.status === 'connected').length
    };
  }
}

module.exports = new RoomManager();
