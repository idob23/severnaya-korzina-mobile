// lib/screens/profile/profile_screen.dart - МИНИМАЛЬНЫЕ ИЗМЕНЕНИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // ДОБАВИТЬ ЭТОТ ИМПОРТ
import '../auth/auth_choice_screen.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  // Старые тестовые данные заменяем на реальные
  final ApiService _apiService = ApiService(); // НОВАЯ СТРОКА
  Map<String, dynamic>? _batchData; // ИЗМЕНЕНО: теперь nullable
  bool _isLoadingBatch = true; // НОВАЯ СТРОКА
  String? _batchError; // НОВАЯ СТРОКА

  @override
  void initState() {
    super.initState();

    // Анимация прогресс-бара
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Анимация пульсации
    _pulseAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // ЗАМЕНИТЬ ЭТИ СТРОКИ:
    // Инициализируем анимации с базовыми значениями
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0, // Будет обновлено после загрузки данных
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // ДОБАВЛЯЕМ: Проверяем авторизацию при входе на экран
    _checkAndRefreshAuth();

    // ДОБАВИТЬ ЭТУ СТРОКУ:
    _loadActiveBatch(); // Загружаем реальные данные
  }

  // НОВЫЙ МЕТОД - добавить после initState
  Future<void> _checkAndRefreshAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Если пользователь не авторизован, но есть сохраненные данные
    if (!authProvider.isAuthenticated) {
      await authProvider.checkAuthStatus();
    }
  }

  /// Загружает данные активной закупки из API
  Future<void> _loadActiveBatch() async {
    setState(() {
      _isLoadingBatch = true;
      _batchError = null;
    });

    try {
      final response = await _apiService.getActiveBatch();

      if (response['success'] == true && response['batch'] != null) {
        setState(() {
          _batchData = response['batch'];
          _isLoadingBatch = false;
        });

        // Обновляем анимацию с реальными данными
        _updateProgressAnimation();

        // Запускаем анимации
        _progressAnimationController.forward();
        if (_getProgress() > 0.8) {
          _pulseAnimationController.repeat(reverse: true);
        }
      } else {
        setState(() {
          _batchData = null;
          _isLoadingBatch = false;
          _batchError = response['message'] ?? 'Нет активных закупок';
        });
      }
    } catch (e) {
      setState(() {
        _batchData = null;
        _isLoadingBatch = false;
        _batchError = 'Ошибка загрузки: $e';
      });
    }
  }

// 5. Добавьте эти вспомогательные методы:

  /// Обновляет анимацию прогресса с реальными данными
  void _updateProgressAnimation() {
    if (_batchData != null) {
      final progress = _getProgress();
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: progress,
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  /// Получает прогресс как число от 0.0 до 1.0
  double _getProgress() {
    if (_batchData == null) return 0.0;

    final current = (_batchData!['currentAmount'] ?? 0).toDouble();
    final target = (_batchData!['targetAmount'] ?? 1).toDouble();

    if (target <= 0) return 0.0;
    return math.min(current / target, 1.0);
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildUnauthenticatedView(context);
          }

          final user = authProvider.currentUser;
          if (user == null) {
            return _buildLoadingView();
          }

          return _buildAuthenticatedView(context, user, authProvider);
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Вы не авторизованы',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Войдите в систему, чтобы получить доступ к профилю и заказам',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AuthChoiceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Войти в аккаунт',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Загрузка профиля...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(
      BuildContext context, user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // ПАНЕЛЬ ЦЕЛЕВОЙ СУММЫ - ГЛАВНАЯ ФИЧА
          _buildBatchProgressCard(),

          SizedBox(height: 16),

          // Информация о пользователе
          _buildUserInfoCard(user),

          SizedBox(height: 16),

          // Настройки и действия
          _buildSettingsCard(context, authProvider),

          SizedBox(height: 16),

          // Кнопка выхода
          _buildLogoutButton(context, authProvider),
        ],
      ),
    );
  }

  // ================== ПАНЕЛЬ ЦЕЛЕВОЙ СУММЫ - ОБНОВЛЕННАЯ ==================
  Widget _buildBatchProgressCard() {
    // Показать загрузку
    if (_isLoadingBatch) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Загрузка данных закупки...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Показать ошибку
    if (_batchError != null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              _batchError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadActiveBatch,
              icon: Icon(Icons.refresh),
              label: Text('Обновить'),
            ),
          ],
        ),
      );
    }

    // Если нет данных
    if (_batchData == null) {
      return SizedBox.shrink();
    }

    // ОСТАЛЬНОЙ КОД ОСТАЕТСЯ ТАК ЖЕ, ТОЛЬКО ЗАМЕНИТЬ _batchData НА _batchData!:
    final progress = _getProgress(); // ИСПОЛЬЗОВАТЬ НОВЫЙ МЕТОД
    final progressPercent = (progress * 100).round();

    // Определяем цвет в зависимости от прогресса
    Color getProgressColor() {
      if (progress < 0.3) return Colors.red;
      if (progress < 0.7) return Colors.orange;
      if (progress < 0.9) return Colors.blue;
      return Colors.green;
    }

    // Определяем мотивационный текст
    String getMotivationalText() {
      if (progress < 0.3) return 'Нужно больше участников! 🚀';
      if (progress < 0.5) return 'Отличное начало! 💪';
      if (progress < 0.7) return 'Больше половины! Продолжаем! 🔥';
      if (progress < 0.9) return 'Почти готово! Последний рывок! ⚡';
      if (progress < 1.0) return 'Ещё чуть-чуть! 🎯';
      return 'Цель достигнута! Готовим машину! 🚛';
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: progress > 0.8 ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  getProgressColor().withOpacity(0.1),
                  getProgressColor().withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: getProgressColor().withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Заголовок
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: getProgressColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: getProgressColor(),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🎯 ТЕКУЩАЯ ЗАКУПКА',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: getProgressColor(),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              _batchData!['title'] ??
                                  'Активная закупка', // ЗАМЕНИТЬ
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Прогресс-бар
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_formatCurrency((_batchData!['currentAmount'] ?? 0).toInt())}', // ЗАМЕНИТЬ
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: getProgressColor(),
                                ),
                              ),
                              Text(
                                '$progressPercent%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: getProgressColor(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  getProgressColor(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Собрано',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Цель: ${_formatCurrency((_batchData!['targetAmount'] ?? 0).toInt())}', // ЗАМЕНИТЬ
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // Мотивационный текст
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: getProgressColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getMotivationalText(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: getProgressColor(),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Статистика
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.people,
                          label: 'Участников',
                          value:
                              '${_batchData!['participantsCount'] ?? 0}', // ЗАМЕНИТЬ
                          color: Colors.blue,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.account_balance_wallet,
                          label: 'Ваш вклад',
                          value: _formatCurrency(
                              (_batchData!['userContribution'] ?? 0)
                                  .toInt()), // ЗАМЕНИТЬ
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
// // Кнопка действия по центру
//                   Center(
//                     child: SizedBox(
//                       width:
//                           200, // Фиксированная ширина для центрированной кнопки
//                       child: OutlinedButton.icon(
//                         onPressed: () {
//                           _showBatchDetails();
//                         },
//                         icon: Icon(Icons.info_outline, size: 18),
//                         label: Text('Подробнее'),
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: getProgressColor(),
//                           side: BorderSide(color: getProgressColor(), width: 2),
//                           padding: EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ================== ВСЕ ОСТАЛЬНЫЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ ==================
  Widget _buildUserInfoCard(user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Аватар
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              user.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                user.phone,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (user.email != null && user.email!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                user.email!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey[600], size: 24),
                SizedBox(width: 8),
                Text(
                  'Настройки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // ДОБАВИТЬ КНОПКУ ОБНОВЛЕНИЯ ДАННЫХ:
            _buildSettingItem(
              icon: Icons.refresh,
              title: 'Обновить данные',
              subtitle: 'Перезагрузить информацию о закупке',
              onTap: () {
                _loadActiveBatch();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Данные обновлены')),
                );
              },
            ),
            // _buildSettingItem(
            //   icon: Icons.edit,
            //   title: 'Редактировать профиль',
            //   subtitle: 'Изменить имя, email',
            //   onTap: () => _showEditProfileDialog(context, authProvider),
            // ),
            // _buildSettingItem(
            //   icon: Icons.location_on,
            //   title: 'Адреса доставки',
            //   subtitle: 'Управление адресами',
            //   onTap: () {
            //     // Переход к управлению адресами
            //   },
            // ),
            // _buildSettingItem(
            //   icon: Icons.notifications,
            //   title: 'Уведомления',
            //   subtitle: 'Push, Email, SMS',
            //   onTap: () {
            //     // Настройки уведомлений
            //   },
            // ),
            // _buildSettingItem(
            //   icon: Icons.help,
            //   title: 'Помощь и поддержка',
            //   subtitle: 'FAQ, контакты',
            //   onTap: () {
            //     // Поддержка
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () => _showLogoutDialog(context, authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
        child: authProvider.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red[700],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Выйти из аккаунта',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} млн ₽';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} тыс ₽';
    } else {
      return '$amount ₽';
    }
  }

  void _showBatchDetails() {
    // ОБНОВИТЬ ЭТОТ МЕТОД ДЛЯ РАБОТЫ С РЕАЛЬНЫМИ ДАННЫМИ:
    if (_batchData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Детали закупки',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Информация о закупке - ОБНОВЛЕННЫЕ ДАННЫЕ
              _buildDetailItem(
                  'Название', _batchData!['title'] ?? 'Не указано'),
              _buildDetailItem('Статус', 'Активная'),
              _buildDetailItem('Собрано',
                  '${_formatCurrency((_batchData!['currentAmount'] ?? 0).toInt())} из ${_formatCurrency((_batchData!['targetAmount'] ?? 0).toInt())}'),
              _buildDetailItem('Участников',
                  '${_batchData!['participantsCount'] ?? 0} человек'),
              _buildDetailItem(
                  'Ваш вклад',
                  _formatCurrency(
                      (_batchData!['userContribution'] ?? 0).toInt())),

              SizedBox(height: 20),

              // Прогноз
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Прогноз',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'При текущих темпах цель будет достигнута в ближайшее время. Машина отправится за товарами сразу после достижения целевой суммы.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // // Кнопки
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton(
              //         onPressed: () {
              //           Navigator.pop(context);
              //           // Поделиться закупкой
              //         },
              //         child: Text('Поделиться'),
              //       ),
              //     ),
              //     SizedBox(width: 12),
              //     Expanded(
              //       child: ElevatedButton(
              //         onPressed: () {
              //           Navigator.pop(context);
              //           // Переход к каталогу
              //           DefaultTabController.of(context)?.animateTo(0);
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //         ),
              //         child: Text('Добавить заказ'),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    final firstNameController = TextEditingController(text: user.name);
    final lastNameController = TextEditingController(text: user.lastName ?? '');
    final emailController = TextEditingController(text: user.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать профиль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Фамилия',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await authProvider.updateUserProfile(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                email: emailController.text,
              );

              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Профиль успешно обновлен'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка обновления профиля'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выход из аккаунта'),
        content: Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();

              // Переход к экрану авторизации
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AuthChoiceScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
