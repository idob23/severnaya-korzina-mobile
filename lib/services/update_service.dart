// lib/services/update_service.dart
// УЛУЧШЕННАЯ ВЕРСИЯ с защитой от проблем кэширования

import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  PackageInfo? _packageInfo;
  CancelToken? _currentDownloadToken;

  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');
  UpdateInfo? _availableUpdate;
  Function(double)? onDownloadProgress;

  // НОВОЕ: Очистка старых APK файлов
  Future<void> _cleanOldApkFiles() async {
    try {
      // Получаем директории где могут храниться APK
      final List<Directory?> directories = [
        await getExternalStorageDirectory(),
        await getApplicationDocumentsDirectory(),
        await getTemporaryDirectory(),
      ];

      // Также проверяем стандартную папку Downloads
      final downloadsDir = Directory('/storage/emulated/0/Download/');
      if (await downloadsDir.exists()) {
        directories.add(downloadsDir);
      }

      for (final dir in directories) {
        if (dir == null) continue;

        // Ищем все APK файлы нашего приложения
        final files = dir.listSync().where((item) =>
            item.path.contains('severnaya') && item.path.endsWith('.apk'));

        // Удаляем старые файлы
        for (final file in files) {
          try {
            if (file is File) {
              await file.delete();
              print('🗑️ Deleted old APK: ${file.path}');
            }
          } catch (e) {
            print('⚠️ Could not delete: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error cleaning old APK files: $e');
    }
  }

  // НОВОЕ: Генерация уникального имени файла
  String _generateUniqueFileName(String version) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'severnaya_korzina_${version}_${timestamp}_$random.apk';
  }

  // НОВОЕ: Проверка целостности загруженного файла
  Future<bool> _verifyApkIntegrity(File file, double expectedSizeMb) async {
    try {
      final fileSize = await file.length();
      final fileSizeMb = fileSize / (1024 * 1024);

      // Проверяем размер (допускаем отклонение 10%)
      final minSize = expectedSizeMb * 0.9;
      final maxSize = expectedSizeMb * 1.1;

      if (fileSizeMb < minSize || fileSizeMb > maxSize) {
        print(
            '❌ APK size mismatch: ${fileSizeMb}MB, expected ~${expectedSizeMb}MB');
        return false;
      }

      // Проверяем, что файл начинается с PK (ZIP signature для APK)
      final bytes = await file.openRead(0, 4).first;
      if (bytes[0] != 0x50 || bytes[1] != 0x4B) {
        print('❌ Invalid APK signature');
        return false;
      }

      print('✅ APK verified: ${fileSizeMb.toStringAsFixed(1)}MB');
      return true;
    } catch (e) {
      print('❌ Error verifying APK: $e');
      return false;
    }
  }

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    print(
        '📱 App version: ${_packageInfo?.version} (${_packageInfo?.buildNumber})');

    // Очищаем старые APK при инициализации
    await _cleanOldApkFiles();
  }

  String get currentVersion => _packageInfo?.version ?? '1.0.0';
  String get currentBuildNumber => _packageInfo?.buildNumber ?? '1';

  Future<UpdateInfo?> checkForUpdate({bool silent = false}) async {
    try {
      final dio = Dio();

      // Добавляем timestamp для обхода кэша
      final response = await dio.get(
        '$baseUrl/api/app/version',
        queryParameters: {
          'current_version': currentVersion,
          'current_build': currentBuildNumber,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['update_available'] == true) {
          _availableUpdate = UpdateInfo.fromJson(data);

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

  Future<void> showUpdateDialog(
      BuildContext context, UpdateInfo updateInfo) async {
    final canSkip = updateInfo.features['can_skip'] ?? true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => canSkip && !updateInfo.forceUpdate,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.system_update, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Доступно обновление',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Версия ${updateInfo.latestVersion}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: updateInfo.forceUpdate
                              ? Colors.red[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          updateInfo.forceUpdate ? 'Обязательное' : 'Новое',
                          style: TextStyle(
                            fontSize: 12,
                            color: updateInfo.forceUpdate
                                ? Colors.red[800]
                                : Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Размер: ${updateInfo.sizeMb.toStringAsFixed(1)} МБ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    'Текущая версия: $currentVersion',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (updateInfo.forceUpdate) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red[800], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Это обновление обязательно для продолжения работы.',
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
                    Text('Что нового:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: updateInfo.changelog
                              .map((item) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(item,
                                        style: TextStyle(fontSize: 13)),
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

    // ВАЖНО: Очищаем старые APK перед загрузкой новой версии
    await _cleanOldApkFiles();

    final dio = Dio();
    _currentDownloadToken = CancelToken();

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
              _currentDownloadToken?.cancel('User cancelled download');
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );

    try {
      // Получаем путь для сохранения с уникальным именем
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        dir = await getApplicationDocumentsDirectory();
      }

      // ВАЖНО: Используем уникальное имя файла
      final fileName = _generateUniqueFileName(updateInfo.latestVersion);
      final filePath = '${dir.path}/$fileName';

      print('📱 Downloading APK to: $filePath');

      // Удаляем файл если существует (на всякий случай)
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Добавляем timestamp к URL для обхода кэша
      final downloadUrl =
          '${updateInfo.downloadUrl}?t=${DateTime.now().millisecondsSinceEpoch}';

      // Скачиваем APK
      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && !downloadCancelled) {
            final progress = received / total;
            onDownloadProgress?.call(progress);
          }
        },
        cancelToken: _currentDownloadToken,
        options: Options(
          headers: {
            'Accept': '*/*',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      // Закрываем диалог загрузки
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // ВАЖНО: Проверяем целостность файла
      if (!await file.exists()) {
        throw Exception('Файл не был сохранен');
      }

      if (!await _verifyApkIntegrity(file, updateInfo.sizeMb)) {
        await file.delete();
        throw Exception('Загруженный файл поврежден или неполный');
      }

      // Показываем уведомление об успешной загрузке
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Обновление загружено успешно')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Ждем немного перед установкой
      await Future.delayed(Duration(seconds: 1));

      // Пробуем открыть для установки
      final result = await OpenFile.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      print('📱 OpenFile result: ${result.type} - ${result.message}');

      // Если не удалось открыть автоматически
      if (result.type != ResultType.done) {
        if (context.mounted) {
          _showManualInstallDialog(context, filePath, fileName);
        }
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        print('📱 Download cancelled by user');
        _currentDownloadToken = null;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Загрузка отменена'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('❌ DioError downloading update: $e');
        _handleDownloadError(context, e.toString(), updateInfo);
      }
    } catch (e) {
      print('❌ Error downloading/installing update: $e');
      _handleDownloadError(context, e.toString(), updateInfo);
    } finally {
      _currentDownloadToken = null;
    }
  }

  void _showManualInstallDialog(
      BuildContext context, String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Установка обновления'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('APK файл успешно загружен!'),
            SizedBox(height: 12),
            Text('Для завершения установки:'),
            SizedBox(height: 8),
            Text('1. Откройте "Файлы" или "Загрузки"'),
            Text('2. Найдите файл "$fileName"'),
            Text('3. Нажмите на него для установки'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Путь к файлу:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(filePath,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openDownloadsFolder();
            },
            child: Text('Открыть папку'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Пробуем еще раз
              await OpenFile.open(
                filePath,
                type: 'application/vnd.android.package-archive',
              );
            },
            child: Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  void _handleDownloadError(
      BuildContext context, String error, UpdateInfo updateInfo) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Ошибка обновления'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Не удалось загрузить обновление.'),
              SizedBox(height: 12),
              Text('Возможные причины:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Нестабильное интернет-соединение'),
              Text('• Недостаточно места на устройстве'),
              Text('• Временные проблемы с сервером'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ошибка: ${error.length > 100 ? error.substring(0, 100) + '...' : error}',
                  style: TextStyle(fontSize: 11, color: Colors.red[900]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadAndInstallUpdate(context, updateInfo);
              },
              child: Text('Повторить'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openDownloadsFolder() async {
    try {
      const platform = MethodChannel('app.channel.shared.data');
      await platform.invokeMethod('openDownloads');
    } catch (e) {
      print('Could not open downloads folder: $e');
    }
  }

  Future<bool> shouldShowUpdateDialog() async {
    if (_availableUpdate == null) return false;

    final prefs = await SharedPreferences.getInstance();

    if (_availableUpdate!.forceUpdate) return true;

    final skippedDateStr = prefs.getString('update_skipped_date');
    if (skippedDateStr != null) {
      final skippedDate = DateTime.parse(skippedDateStr);
      final daysSinceSkipped = DateTime.now().difference(skippedDate).inDays;
      final remindDays = _availableUpdate!.features['remind_later_days'] ?? 3;

      if (daysSinceSkipped < remindDays) return false;
    }

    return true;
  }
}

// Модель и диалог прогресса остаются без изменений...
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
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
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
          if (percentage > 0) ...[
            SizedBox(height: 8),
            Text(
              'Не закрывайте приложение',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
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
