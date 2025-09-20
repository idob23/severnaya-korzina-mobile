// lib/screens/maintenance_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class MaintenanceScreen extends StatelessWidget {
  final String message;
  final String? endTime;

  const MaintenanceScreen({
    Key? key,
    this.message = 'Проводятся технические работы',
    this.endTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.engineering,
                    size: 50,
                    color: Colors.orange.shade700,
                  ),
                ),

                const SizedBox(height: 32),

                // Заголовок
                Text(
                  'Технические работы',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Сообщение
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (endTime != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ориентировочное время: $endTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Информация
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Мы работаем над улучшением приложения.\nПриносим извинения за временные неудобства.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Кнопка обновить - ИСПРАВЛЕННАЯ ВЕРСИЯ
                OutlinedButton.icon(
                  onPressed: () async {
                    // Показываем индикатор загрузки
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    );

                    try {
                      // Проверяем статус приложения
                      final apiService = ApiService();
                      final statusResponse = await apiService.checkAppStatus();

                      // Закрываем диалог загрузки
                      Navigator.of(context).pop();

                      print(
                          '🔍 Проверка статуса: maintenance=${statusResponse['maintenance']}');

                      if (statusResponse['maintenance'] != true) {
                        // Режим обслуживания отключен, перезапускаем приложение
                        print(
                            '✅ Режим обслуживания отключен, перезапускаем приложение');

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => AppInitializer(),
                          ),
                          (route) => false,
                        );
                      } else {
                        // Режим все еще включен
                        print('⚠️ Режим обслуживания все еще активен');

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                      'Технические работы еще не завершены'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      // Закрываем диалог если он еще открыт
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }

                      print('❌ Ошибка при проверке статуса: $e');

                      // Показываем ошибку
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                    'Ошибка подключения. Попробуйте позже'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Попробовать снова'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // // Дополнительная информация о версии (опционально)
                // Text(
                //   'Версия приложения: 4.0.0',
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey.shade500,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Вспомогательный класс AppInitializer должен быть импортирован из main.dart
// Если он не экспортируется, создайте отдельный файл app_initializer.dart
