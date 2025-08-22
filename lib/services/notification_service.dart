// lib/services/notification_service.dart
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _permissionRequested = false;
  String _permissionStatus = 'default';

  /// Запрашивает разрешение на уведомления (только для веб)
  Future<bool> requestPermission() async {
    if (!kIsWeb) return false;

    try {
      if (!_permissionRequested) {
        _permissionStatus = 'granted'; // Пока просто разрешаем
        _permissionRequested = true;

        if (kDebugMode) {
          print('🔔 Статус разрешения на уведомления: $_permissionStatus');
        }
      }

      return _permissionStatus == 'granted';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка запроса разрешения на уведомления: $e');
      }
      return false;
    }
  }

  /// Показывает локальное уведомление (пока просто в консоль)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? icon,
    String? url,
  }) async {
    print('🔔 ТЕСТ: showLocalNotification начал работу');
    print('🔔 ТЕСТ: title=$title, body=$body');

    // if (!kIsWeb) {
    //   print('🔔 ТЕСТ: Не веб-платформа, выходим');
    //   return;
    // }

    // print('🔔 ТЕСТ: Веб-платформа, продолжаем');
    // if (!kIsWeb) return;

    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        if (kDebugMode) {
          print('❌ Нет разрешения на уведомления');
        }
        return;
      }

      // Пока просто выводим в консоль
      if (kDebugMode) {
        print('🔔 УВЕДОМЛЕНИЕ: $title - $body');
      }

      // В будущем здесь будет реальное уведомление
      // Пока что это заглушка для тестирования логики
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка показа уведомления: $e');
      }
    }
  }

  /// Показывает уведомление об изменении статуса заказа
  Future<void> showOrderStatusNotification({
    required int orderId,
    required String oldStatus,
    required String newStatus,
  }) async {
    final statusMessages = _getStatusMessages(newStatus);

    await showLocalNotification(
      title: '🎯 Заказ #$orderId',
      body: statusMessages['message']!,
      icon: statusMessages['icon'],
      url: '/#/orders/$orderId',
    );
  }

  /// Получает сообщение и иконку для статуса
  Map<String, String> _getStatusMessages(String status) {
    switch (status) {
      case 'paid':
        return {
          'message': 'Заказ оплачен! Готовится к отправке',
          'icon': '/icons/Icon-192.png'
        };
      case 'confirmed':
        return {
          'message': 'Заказ подтвержден и принят в работу',
          'icon': '/icons/Icon-192.png'
        };
      case 'shipped':
        return {
          'message': 'Заказ отправлен! Ожидайте доставку',
          'icon': '/icons/Icon-192.png'
        };
      case 'delivered':
        return {
          'message': 'Заказ доставлен! Можете забрать',
          'icon': '/icons/Icon-192.png'
        };
      case 'cancelled':
        return {'message': 'Заказ отменен', 'icon': '/icons/Icon-192.png'};
      default:
        return {
          'message': 'Статус заказа изменен',
          'icon': '/icons/Icon-192.png'
        };
    }
  }

  /// Проверяет поддержку уведомлений
  bool get isSupported {
    return kIsWeb;
  }

  /// Получает текущий статус разрешения
  String get permissionStatus {
    if (!kIsWeb) return 'not-supported';
    return _permissionStatus;
  }
}
