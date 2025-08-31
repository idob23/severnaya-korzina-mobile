// lib/services/update_service.dart
// Сервис для проверки и установки обновлений приложения

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart'; // Добавьте этот импорт

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final Dio _dio = Dio();
  PackageInfo? _packageInfo;

  // Используем тот же baseUrl что и в ApiService
  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

  // Информация о доступном обновлении
  UpdateInfo? _availableUpdate;

  // Callback для прогресса загрузки
  Function(double)? onDownloadProgress;

  // Инициализация сервиса
  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    print(
        '📱 App version: ${_packageInfo?.version} (${_packageInfo?.buildNumber})');
  }

  // Получить текущую версию приложения
  String get currentVersion => _packageInfo?.version ?? '1.0.0';

  // Проверка обновлений
  Future<UpdateInfo?> checkForUpdate({bool silent = false}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/app/version',
        queryParameters: {
          'current_version': currentVersion,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['update_available'] == true) {
          _availableUpdate = UpdateInfo.fromJson(data);

          // Сохраняем информацию о последней проверке
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'last_update_check', DateTime.now().toIso8601String());
          await prefs.setString('available_version', data['latest_version']);

          return _availableUpdate;
        }
      }

      return null;
    } catch (e) {
      if (!silent) {
        print('❌ Error checking for updates: $e');
      }
      return null;
    }
  }

  // Показать диалог обновления
  Future<void> showUpdateDialog(
      BuildContext context, UpdateInfo updateInfo) async {
    final canSkip = updateInfo.features['can_skip'] ?? true;

    await showDialog(
      context: context,
      barrierDismissible: canSkip,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => canSkip,
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.system_update,
                    color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text('Доступно обновление'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Версия ${updateInfo.latestVersion}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Размер: ${updateInfo.sizeMb} МБ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (updateInfo.forceUpdate) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Критическое обновление! Необходимо для продолжения работы.',
                              style: TextStyle(
                                  color: Colors.red[800], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (updateInfo.showChangelog &&
                      updateInfo.changelog.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Что нового:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: updateInfo.changelog
                              .map((item) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      item,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (canSkip && !updateInfo.forceUpdate)
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Сохраняем, что пользователь отложил обновление
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      'update_skipped_date',
                      DateTime.now().toIso8601String(),
                    );
                  },
                  child: Text('Позже'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _downloadAndInstallUpdate(context, updateInfo);
                },
                child: Text('Обновить'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Замените метод _downloadAndInstallUpdate в update_service.dart на этот:

  // Скачивание и установка обновления
  Future<void> _downloadAndInstallUpdate(
    BuildContext context,
    UpdateInfo updateInfo,
  ) async {
    // Проверяем разрешение на установку
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        final result = await Permission.requestInstallPackages.request();
        if (!result.isGranted) {
          // Открываем настройки для включения разрешения
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Разрешите установку из неизвестных источников в настройках'),
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Открыть настройки',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }
    }

    // Показываем диалог загрузки
    bool downloadCancelled = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: _DownloadProgressDialog(
            updateInfo: updateInfo,
            onCancel: () {
              downloadCancelled = true;
              _dio.close();
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );

    try {
      // Получаем путь для сохранения файла
      Directory? dir;

      // Для Android 10+ используем getExternalStorageDirectory
      if (Platform.isAndroid) {
        // Пробуем разные варианты путей
        dir = await getExternalStorageDirectory();
        if (dir == null) {
          dir = await getApplicationDocumentsDirectory();
        }
      } else {
        dir = await getTemporaryDirectory();
      }

      final fileName = 'severnaya_korzina_${updateInfo.latestVersion}.apk';
      final filePath = '${dir.path}/$fileName';

      print('📱 Saving APK to: $filePath');

      // Удаляем старый файл, если существует
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Скачиваем APK
      await _dio.download(
        updateInfo.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && !downloadCancelled) {
            final progress = received / total;
            onDownloadProgress?.call(progress);
          }
        },
        options: Options(
          headers: {
            'Accept': '*/*',
            'Connection': 'keep-alive',
          },
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      // Закрываем диалог загрузки
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Проверяем, что файл существует и имеет размер
      if (!await file.exists()) {
        throw Exception('Файл не был сохранен');
      }

      final fileSize = await file.length();
      print('📱 APK saved successfully. Size: $fileSize bytes');

      if (fileSize < 1000000) {
        // Меньше 1MB - явно что-то не то
        throw Exception(
            'Файл слишком маленький, возможно загрузка не завершена');
      }

      // // ВАЖНО: Добавляем задержку перед открытием
      // await Future.delayed(Duration(seconds: 1));

      // // Открываем установщик
      // print('📱 Opening APK installer for: $filePath');

      // // Используем open_file для открытия
      // final result = await OpenFile.open(
      //   filePath,
      //   type: 'application/vnd.android.package-archive',
      // );

      // Показываем уведомление с кнопкой установки
      await _showInstallNotification(context, filePath, fileName);

      // Пробуем открыть автоматически через секунду
      await Future.delayed(Duration(seconds: 1));

      final result = await OpenFile.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      print('📱 OpenFile result: ${result.type} - ${result.message}');

      // Если open_file не сработал, пробуем альтернативный метод
      if (result.type != ResultType.done) {
        // Показываем инструкцию пользователю
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Установка обновления'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('APK файл успешно загружен!'),
                  SizedBox(height: 12),
                  Text('Для установки:'),
                  SizedBox(height: 8),
                  Text('1. Откройте "Файлы" или "Загрузки"'),
                  Text('2. Найдите файл "$fileName"'),
                  Text('3. Нажмите на него для установки'),
                  SizedBox(height: 12),
                  Text('Путь к файлу:',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(filePath,
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Пробуем открыть папку загрузок
                    _openDownloadsFolder();
                  },
                  child: Text('Открыть папку'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error downloading/installing update: $e');

      if (context.mounted) {
        Navigator.of(context).pop(); // Закрываем диалог загрузки

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка установки: ${e.toString()}'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _downloadAndInstallUpdate(context, updateInfo),
            ),
          ),
        );
      }
    }
  }

  // Добавьте этот метод в update_service.dart для показа уведомления

  // Метод для показа постоянного уведомления с кнопкой установки
  Future<void> _showInstallNotification(
      BuildContext context, String filePath, String fileName) async {
    if (!context.mounted) return;

    // Показываем Snackbar, который не исчезает
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '✅ Обновление загружено',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Нажмите "Установить" для обновления приложения',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.green[50],
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

              // Пробуем открыть файл еще раз
              final result = await OpenFile.open(
                filePath,
                type: 'application/vnd.android.package-archive',
              );

              if (result.type != ResultType.done) {
                // Если не удалось, показываем путь к файлу
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Откройте файл $fileName в папке Загрузки'),
                    duration: Duration(seconds: 10),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Установить'),
          ),
        ],
      ),
    );
  }

  // Новый метод для открытия папки загрузок
  Future<void> _openDownloadsFolder() async {
    try {
      // Пробуем открыть папку через intent
      const platform = MethodChannel('app.channel.shared.data');
      await platform.invokeMethod('openDownloads');
    } catch (e) {
      print('Could not open downloads folder: $e');
    }
  }

//   // Упрощенный метод для открытия папки загрузок
// Future<void> _openDownloadsFolder() async {
//   try {
//     // Пробуем открыть файловый менеджер
//     // Большинство Android устройств откроют папку загрузок
//     final Uri uri = Uri.parse('content://com.android.externalstorage.documents/document/primary:Download');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   } catch (e) {
//     print('Could not open downloads folder: $e');
//   }
// }

  // Проверка, нужно ли показывать диалог обновления
  Future<bool> shouldShowUpdateDialog() async {
    if (_availableUpdate == null) return false;

    final prefs = await SharedPreferences.getInstance();

    // Если обновление принудительное - всегда показываем
    if (_availableUpdate!.forceUpdate) return true;

    // Проверяем, когда пользователь отложил обновление
    final skippedDateStr = prefs.getString('update_skipped_date');
    if (skippedDateStr != null) {
      final skippedDate = DateTime.parse(skippedDateStr);
      final daysSinceSkipped = DateTime.now().difference(skippedDate).inDays;
      final remindDays = _availableUpdate!.features['remind_later_days'] ?? 3;

      // Не показываем, если еще не прошло нужное количество дней
      if (daysSinceSkipped < remindDays) return false;
    }

    return true;
  }
}

// Модель информации об обновлении
class UpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String latestVersion;
  final String minVersion;
  final String currentVersion;
  final String downloadUrl;
  final double sizeMb;
  final String releaseDate;
  final List<String> changelog;
  final Map<String, dynamic> features;
  final String message;
  final bool showChangelog;

  UpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.latestVersion,
    required this.minVersion,
    required this.currentVersion,
    required this.downloadUrl,
    required this.sizeMb,
    required this.releaseDate,
    required this.changelog,
    required this.features,
    required this.message,
  }) : showChangelog = features['show_changelog'] ?? true;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      updateAvailable: json['update_available'] ?? false,
      forceUpdate: json['force_update'] ?? false,
      latestVersion: json['latest_version'] ?? '',
      minVersion: json['min_version'] ?? '',
      currentVersion: json['current_version'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      sizeMb: (json['size_mb'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      changelog: List<String>.from(json['changelog'] ?? []),
      features: json['features'] ?? {},
      message: json['message'] ?? '',
    );
  }
}

// Виджет диалога прогресса загрузки
class _DownloadProgressDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onCancel;

  const _DownloadProgressDialog({
    Key? key,
    required this.updateInfo,
    required this.onCancel,
  }) : super(key: key);

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    UpdateService().onDownloadProgress = (progress) {
      setState(() {
        _progress = progress;
      });
    };
  }

  @override
  void dispose() {
    UpdateService().onDownloadProgress = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadedMb =
        (widget.updateInfo.sizeMb * _progress).toStringAsFixed(1);
    final totalMb = widget.updateInfo.sizeMb.toStringAsFixed(1);
    final percentage = (_progress * 100).toInt();

    return AlertDialog(
      title: Text('Загрузка обновления'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
          ),
          SizedBox(height: 16),
          Text(
            '$percentage%',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '$downloadedMb МБ / $totalMb МБ',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text('Отмена'),
        ),
      ],
    );
  }
}
