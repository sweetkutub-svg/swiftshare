import 'package:shelf/shelf.dart';

class ReceiverPageHandler {
  static Response handle(Request request) {
    if (request.url.path != '/') {
      return Response.notFound('Not Found');
    }

    final html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SwiftShare | Receive</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', system-ui, sans-serif;
      background: #F8F8FF;
      color: #0D0D1A;
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      min-height: 100vh; text-align: center; padding: 24px;
    }
    h1 { font-size: 24px; margin-bottom: 8px; }
    p { color: #4A4A6A; margin-bottom: 24px; }
    .btn {
      background: #5B4EFF; color: #fff; border: none; padding: 14px 28px;
      border-radius: 10px; font-size: 14px; font-weight: 600; cursor: pointer;
    }
  </style>
</head>
<body>
  <h1>SwiftShare Receiver</h1>
  <p>Connected to local network. Waiting for files...</p>
  <button class="btn" onclick="location.reload()">Refresh</button>
</body>
</html>
''';

    return Response.ok(html, headers: {'content-type': 'text/html'});
  }
}
