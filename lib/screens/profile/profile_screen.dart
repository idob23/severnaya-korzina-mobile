// lib/screens/profile/profile_screen.dart - С ВИЗУАЛЬНЫМИ УЛУЧШЕНИЯМИ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавлен для HapticFeedback
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_choice_screen.dart';
import 'dart:math' as math;
import 'package:severnaya_korzina/services/update_service.dart';
import '../../design_system/colors/app_colors.dart'; // Добавлено
import '../../design_system/colors/gradients.dart'; // Добавлено

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  String _appVersion = '';

  static const String WHATSAPP_GROUP_LINK =
      'https://chat.whatsapp.com/BkMuB7ALKzZ5Zj81yGhdvG';

  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _fadeController; // Добавлено
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation; // Добавлено

  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _batchData;
  bool _isLoadingBatch = true;
  String? _batchError;

  @override
  void initState() {
    super.initState();

    _loadAppVersion();

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

    // Анимация появления экрана
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
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

    _checkAndRefreshAuth();
    _loadActiveBatch();
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    _fadeController.dispose(); // Добавлено
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _openWhatsAppGroup() async {
    HapticFeedback.lightImpact(); // Добавлено
    try {
      final Uri whatsappUrl = Uri.parse(WHATSAPP_GROUP_LINK);

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось открыть WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkAndRefreshAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await authProvider.checkAuthStatus();
    }
  }

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

        _updateProgressAnimation();

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
        _batchError = 'Ошибка загрузки данных';
      });
    }
  }

  void _updateProgressAnimation() {
    final progress = _getProgress();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  double _getProgress() {
    if (_batchData == null) return 0.0;

    final current = _safeDouble(_batchData!['currentAmount']);
    final target = _safeDouble(_batchData!['targetAmount']);

    if (target <= 0) return 0.0;

    return (current / target).clamp(0.0, 1.0);
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatCurrency(int amount) {
    return '$amount ₽';
  }

  Color getProgressColor() {
    final progress = _getProgress();
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.8) return Colors.orange;
    if (progress >= 0.5) return Colors.blue;
    return Colors.grey;
  }

  String getMotivationalText() {
    final progress = _getProgress();
    if (progress >= 1.0) return '🎉 Цель достигнута!';
    if (progress >= 0.8) return '🔥 Почти у цели!';
    if (progress >= 0.5) return '💪 Уже больше половины!';
    if (progress >= 0.3) return '👍 Хороший старт!';
    return '🚀 Начинаем сбор!';
  }

  Future<void> _checkForUpdates() async {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      ),
    );

    final updateService = UpdateService();
    final updateInfo = await updateService.checkForUpdate(); // БЕЗ ПАРАМЕТРОВ!

    if (mounted) Navigator.of(context).pop();

    if (updateInfo != null && mounted) {
      updateService.showUpdateDialog(context, updateInfo);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('У вас последняя версия приложения'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAboutDialog() {
    HapticFeedback.lightImpact(); // Добавлено
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Увеличен радиус
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.aurora1.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.aurora, // Градиент северного сияния
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Северная Корзина',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Версия $_appVersion',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Контент с инструкцией
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInstructionSection(
                          '🎯 Как это работает',
                          [
                            'Северная Корзина - это платформа коллективных закупок для жителей Усть-Неры.',
                            'Мы объединяем заказы жителей, чтобы получить оптовые цены от поставщиков.',
                          ],
                        ),

                        _buildInstructionSection(
                          'Проект имеет высокую степень сложности, для пользователя видна лишь малая часть сервиса, протестировать все возможные варианты событий невозможно, поэтому просим оказывать содействие в модернизации и развитии проекта путём вступления в нашу группу WhatsApp "Северная Корзина", где можно сообщать о проблемах и вносить предложения. Также там будет вся актуальная информация. Ссылка на группу доступна в профиле.',
                          [],
                        ),

                        _buildInstructionSection(
                          '🛒 Как сделать заказ',
                          [
                            '1. Перейдите в раздел "Каталог"',
                            '2. Выберите нужную категорию товаров',
                            '3. Укажите количество и нажмите "В корзину"',
                            '4. Товары сохраняются в корзине даже после закрытия приложения',
                            '5. Перейдите в "Корзину" для оформления заказа',
                            '6. Кнопка "Оформить заказ" активна только при наличии товаров и иногда может быть неактивна, когда проводятся профилактические работы или нет активной закупки.',
                          ],
                        ),

                        _buildInstructionSection(
                          '💳 Оплата заказа',
                          [
                            '• Требуется 100% предоплата',
                            '• Принимаются карты МИР через систему ЮKassa',
                            '• После оплаты заказ автоматически попадает в обработку',
                            '• Корзина очищается только после успешной оплаты',
                            '• Оплаченные заказы нельзя отменить, за исключением случаев, когда не набрана общая целевая сумма закупки',
                            '• После успешной оплаты в окне ЮKassa закройте его и вернитесь в приложение.',
                          ],
                        ),

                        _buildInstructionSection(
                          '🚛 Доставка',
                          [
                            '• Машина отправляется после набора целевой суммы закупки',
                            '• Прогресс закупки отображается в разделе "Профиль"',
                            '• Доставка осуществляется по адресу, указанному в приложении или в группе WhatsApp.',
                            '• Вы получите SMS когда заказ будет сформирован и готов к выдаче',
                            '• Время доставки: 7-14 дней после отправки машины',
                          ],
                        ),

                        _buildInstructionSection(
                          '📊 Отслеживание заказов',
                          [
                            '• Все ваши заказы доступны в разделе "Заказы"',
                            '• Статусы заказов:',
                            '  - Ожидает оплаты (оранжевый)',
                            '  - Оплачен (зеленый)',
                            '  - Отправлен (синий)',
                            '  - Доставлен (зеленый)',
                            '  - Отменен (красный)',
                          ],
                        ),

                        _buildInstructionSection(
                          '🎯 Целевая сумма закупки',
                          [
                            '• Минимальная сумма для отправки машины отображается в профиле',
                            '• Текущий прогресс показан в виде прогресс-бара',
                            '• Машина отправляется сразу после достижения цели',
                            '• Приглашайте друзей для быстрого набора суммы!',
                          ],
                        ),

                        _buildInstructionSection(
                          '🔄 Обновления приложения',
                          [
                            '• Приложение автоматически проверяет обновления',
                            '• При наличии новой версии появится уведомление (актуально только для Android). В веб-версии на iOS обновление происходит автоматически.',
                            '• Нажмите "Обновить" для загрузки',
                            '• Обновление установится автоматически',
                            '• Важные обновления обязательны для установки',
                          ],
                        ),

                        _buildInstructionSection(
                          '📞 Контакты поддержки',
                          [
                            '📧 Email: sevkorzina@gmail.com',
                            '📱 Телефон: +7 (914) 266-75-82',
                            '⏰ Время работы: Пн-Пт 9:00-18:00',
                            '📍 Адрес: Республика Саха (Якутия), пос. Усть-Нера',
                          ],
                        ),

                        SizedBox(height: 16),

                        // Информация о разработчике
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '© 2025 Северная Корзина',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionSection(String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          ...items
              .map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 4, left: 8),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: item.startsWith('Q:')
                            ? Colors.grey[700]
                            : item.startsWith('A:')
                                ? Colors.blue[600]
                                : Colors.grey[600],
                        fontWeight:
                            item.startsWith('Q:') || item.startsWith('A:')
                                ? FontWeight.w600
                                : FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Изменено
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.aurora, // Градиент северного сияния
          ),
        ),
        title: Text(
          'Профиль',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        // Добавлена анимация появления
        opacity: _fadeAnimation,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return _buildLoadingView();
            }

            final user = authProvider.currentUser;
            if (user == null) {
              return _buildGuestView();
            }

            return _buildAuthenticatedView(context, user, authProvider);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: AppColors.primaryLight), // Изменен цвет
          SizedBox(height: 16),
          Text(
            'Загрузка профиля...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: TweenAnimationBuilder(
          // Добавлена анимация
          duration: Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.aurora1.withOpacity(0.2),
                          AppColors.aurora2.withOpacity(0.2)
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Вы не авторизованы',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Войдите в систему, чтобы получить доступ к профилю и заказам',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppGradients.button,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => AuthChoiceScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Войти в аккаунт',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
      BuildContext context, user, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBatchProgressCard(),
          SizedBox(height: 12),
          _buildUserInfoCard(user),
          SizedBox(height: 12),
          _buildSettingsCard(context, authProvider),
          SizedBox(height: 12),
          _buildWhatsAppGroupCard(),
          _buildAboutSection(),
          SizedBox(height: 16),
          _buildLogoutButton(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildBatchProgressCard() {
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
              CircularProgressIndicator(color: AppColors.primaryLight),
              SizedBox(height: 16),
              Text(
                'Загрузка данных закупки...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

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
            Icon(Icons.info_outline, color: Colors.orange, size: 48),
            SizedBox(height: 12),
            Text(
              _batchError!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    }

    if (_batchData != null) {
      return GestureDetector(
        onTap: () => _showBatchDetailsDialog(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.aurora1.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppGradients.aurora,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Закупка #${_batchData!['id']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_formatCurrency((_batchData!['currentAmount'] ?? 0).toInt())} из ${_formatCurrency((_batchData!['targetAmount'] ?? 0).toInt())}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getProgress() >= 1.0
                                    ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600
                                      ]
                                    : [AppColors.aurora1, AppColors.aurora2],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: (_getProgress() >= 1.0
                                          ? Colors.green
                                          : AppColors.aurora1)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${(_getProgress() * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getProgress() > 0.5
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.people,
                        label: 'Участников',
                        value: '${_batchData!['participantsCount'] ?? 0}',
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
                            _safeDouble(_batchData!['userContribution'])
                                .toInt()),
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24), // Увеличен размер
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
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.aurora,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.aurora1.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name != null && user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
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
              '${user.name ?? 'Имя'} ${user.lastName ?? ''}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              user.phone ?? 'Телефон не указан',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            if (user.email != null && user.email.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.aurora1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.refresh, color: AppColors.aurora1),
        ),
        title: Text('Обновить данные'),
        subtitle: Text('Синхронизация с сервером'),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () async {
          HapticFeedback.lightImpact();
          await _loadActiveBatch();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Данные обновлены'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhatsAppGroupCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.success,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp группа',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Новости и обсуждения',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Важно',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupFeature('📢 Актуальные новости о закупках'),
                _buildGroupFeature('💬 Общение с другими участниками'),
                _buildGroupFeature('❓ Ответы на вопросы'),
                _buildGroupFeature('🔔 Уведомления о статусе заказов'),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _openWhatsAppGroup();
                    },
                    icon: Icon(Icons.chat),
                    label: Text(
                      'Войти в WhatsApp группу',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFeature(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAboutDialog();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'О приложении',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Версия $_appVersion',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _checkForUpdates();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Проверить обновления',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                await authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthChoiceScreen()),
                  (Route<dynamic> route) => false,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: authProvider.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showBatchDetailsDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.aurora,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Детали закупки #${_batchData!['id']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                (_batchData!['userContribution'] ?? 0)
                                    .toInt())),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.aurora1.withOpacity(0.1),
                                AppColors.aurora2.withOpacity(0.1)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.aurora1.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.analytics,
                                      color: AppColors.aurora1, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Прогноз',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'При текущих темпах цель будет достигнута в ближайшее время. Машина отправится за товарами сразу после достижения целевой суммы.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                color: AppColors.textSecondary,
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
                color: AppColors.textPrimary,
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

    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.aurora1.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppGradients.aurora,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Редактирование профиля',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.primaryLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primaryLight, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.primaryLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primaryLight, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email (необязательно)',
                      prefixIcon: Icon(Icons.email_outlined,
                          color: AppColors.primaryLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: AppColors.primaryLight, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.button,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final success =
                                await authProvider.updateUserProfile(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                            );

                            Navigator.of(context).pop();

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Профиль обновлен'),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Сохранить',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
