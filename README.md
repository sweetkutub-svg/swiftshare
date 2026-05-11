# SwiftShare

**Proprietary & Confidential. All Rights Reserved.**

SwiftShare is a closed-source, cross-platform peer-to-peer file transfer application. Transfer files at maximum speed locally without internet, or remotely without uploading to any server.

## Project Structure

```
swiftshare/
├── app/                    # Flutter application (all 5 platforms)
├── signaling-server/       # Node.js WebRTC signaling server
└── web-receiver/          # Browser-based file receiver page
```

## Quick Start

### Signaling Server

```bash
cd signaling-server
cp .env.example .env
npm install
npm start
```

Deploy to Railway.app (free tier) for production use.

### Web Receiver

Host `web-receiver/` on GitHub Pages or any static host. Update `SIGNALING_URL` in `app.js` to point to your deployed signaling server.

### Flutter App

```bash
cd app
flutter pub get
flutter run
```

## Architecture

- **LAN Mode**: mDNS discovery + WebSocket file transfer
- **WiFi Direct**: Native platform channels (Android/Windows)
- **Remote P2P**: WebRTC DataChannel with Socket.io signaling
- **Theme**: System adaptive dark/light using `ThemeMode.system`
- **State**: Riverpod providers throughout
- **Security**: DTLS 1.3 (WebRTC), SHA-256 integrity checks, optional PIN

## CI/CD

GitHub Actions workflows included for:
- Android (APK + AAB)
- iOS
- Windows, macOS, Linux

## License

Closed Source. All rights reserved. No redistribution permitted.
