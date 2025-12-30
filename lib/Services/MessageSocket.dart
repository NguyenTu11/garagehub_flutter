import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Utils.dart';
import 'MessageNotifier.dart';

class MessageSocket {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static bool isInChatPage = false;

  static String get _socketUrl {
    final baseUrl = Utils.baseUrl;
    if (baseUrl.contains('/api/v1')) {
      return baseUrl.replaceAll('/api/v1', '');
    }
    return baseUrl;
  }

  static void connect() {
    if (_isConnected || Utils.userId.isEmpty) return;

    _socket = IO.io(
      '$_socketUrl/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': Utils.userId, 'isAdmin': 'false'})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      MessageNotifier.refresh();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
    });

    _socket!.on('receive-message', (data) {
      if (data != null && !isInChatPage) {
        if (data['senderRole'] == 'admin') {
          MessageNotifier.incrementCount();
        }
      }
    });

    _socket!.connect();
  }

  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  static bool get isConnected => _isConnected;
}
