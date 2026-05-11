require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const logger = require('./src/logger');
const { setupSocketHandlers } = require('./src/socket_handler');
const roomManager = require('./src/room_manager');

const app = express();
const server = http.createServer(app);

const allowedOrigins = (process.env.CORS_ORIGINS || '*').split(',').map(s => s.trim());

const io = new Server(server, {
  cors: {
    origin: allowedOrigins,
    methods: ['GET', 'POST']
  },
  maxHttpBufferSize: parseInt(process.env.MAX_MESSAGE_SIZE, 10) || 1024
});

app.use(helmet());
app.use(cors({ origin: allowedOrigins }));

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10) || 100,
  standardHeaders: true,
  legacyHeaders: false
});
app.use(limiter);

app.use(express.json({ limit: '1kb' }));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '2.0.0' });
});

app.get('/stats', (req, res) => {
  res.json(roomManager.getStats());
});

app.get('/ice-config', (req, res) => {
  try {
    const iceServers = process.env.ICE_SERVERS
      ? JSON.parse(process.env.ICE_SERVERS)
      : [{ urls: 'stun:stun.l.google.com:19302' }];
    res.json({ iceServers });
  } catch (err) {
    logger.error(`Failed to parse ICE servers`, { error: err.message });
    res.status(500).json({ error: 'Invalid ICE server configuration' });
  }
});

setupSocketHandlers(io);

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  logger.info(`SwiftShare Signaling Server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  logger.info(`Allowed origins: ${allowedOrigins.join(', ')}`);
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
