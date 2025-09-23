// lib/screens/orders/orders_screen.dart - ПРЕМИУМ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';
import '../auth/auth_choice_screen.dart';
import 'order_details_screen.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Анимация появления
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
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

    // Добавляем haptic при смене табов
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.aurora1.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Премиум заголовок с градиентом
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  gradient: AppGradients.aurora,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.aurora2.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Заголовок с иконкой
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Мои заказы',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Премиум табы
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        isScrollable: false,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time, size: 18),
                                SizedBox(width: 4),
                                Text('Активные'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_shipping, size: 18),
                                SizedBox(width: 4),
                                Text('В пути'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 18),
                                SizedBox(width: 4),
                                Text('Готовые'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 18),
                                SizedBox(width: 4),
                                Text('История'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Тело экрана с анимацией
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (!authProvider.isAuthenticated) {
                        return _buildPremiumUnauthenticatedView();
                      }

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildActiveOrders(),
                          _buildInTransitOrders(),
                          _buildReadyOrders(),
                          _buildHistoryOrders(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированная иконка с градиентом
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppGradients.aurora,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.aurora1.withOpacity(0.3),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),

            // Заголовок с градиентом
            Text(
              'Войдите для просмотра заказов',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Авторизуйтесь, чтобы видеть свои заказы\nи отслеживать их статус',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 40),

            // Премиум кнопка входа
            GestureDetector(
              onTapDown: (_) => HapticFeedback.lightImpact(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                decoration: BoxDecoration(
                  gradient: AppGradients.button,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Войти в аккаунт',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
  }

  Widget _buildActiveOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return _buildPremiumLoadingState();
        }

        if (ordersProvider.error != null) {
          return _buildPremiumErrorState(ordersProvider);
        }

        final activeOrders = ordersProvider.activeOrders;

        if (activeOrders.isEmpty) {
          return _buildPremiumEmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Нет активных заказов',
            subtitle: 'Здесь появятся ваши новые заказы',
            gradientColors: [AppColors.aurora1, AppColors.aurora2],
          );
        }

        return _buildOrdersList(activeOrders);
      },
    );
  }

  Widget _buildInTransitOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return _buildPremiumLoadingState();
        }

        final inTransitOrders = ordersProvider.getOrdersByStatus('shipped');

        if (inTransitOrders.isEmpty) {
          return _buildPremiumEmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Нет заказов в пути',
            subtitle: 'Заказы в доставке появятся здесь',
            gradientColors: [Colors.orange.shade400, Colors.orange.shade600],
          );
        }

        return _buildOrdersList(inTransitOrders);
      },
    );
  }

  Widget _buildReadyOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return _buildPremiumLoadingState();
        }

        final readyOrders = ordersProvider.getOrdersByStatus('ready');

        if (readyOrders.isEmpty) {
          return _buildPremiumEmptyState(
            icon: Icons.check_circle_outline,
            title: 'Нет готовых заказов',
            subtitle: 'Готовые к получению заказы появятся здесь',
            gradientColors: [Colors.green.shade400, Colors.green.shade600],
          );
        }

        return _buildOrdersList(readyOrders);
      },
    );
  }

  Widget _buildHistoryOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return _buildPremiumLoadingState();
        }

        final historyOrders = ordersProvider.completedOrders;

        if (historyOrders.isEmpty) {
          return _buildPremiumEmptyState(
            icon: Icons.history,
            title: 'История пуста',
            subtitle: 'Завершенные заказы появятся здесь',
            gradientColors: [AppColors.textSecondary, AppColors.textPrimary],
          );
        }

        return _buildOrdersList(historyOrders);
      },
    );
  }

  // Премиум состояние загрузки с shimmer эффектом
  Widget _buildPremiumLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.5, -0.5),
                end: Alignment(1.5, 0.5),
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
                stops: [
                  0.0,
                  0.5,
                  1.0,
                ],
                transform: GradientRotation(0.5),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  // Премиум состояние ошибки
  Widget _buildPremiumErrorState(OrdersProvider ordersProvider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              ordersProvider.error ?? 'Произошла ошибка при загрузке заказов',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTapDown: (_) => HapticFeedback.lightImpact(),
              onTap: () {
                ordersProvider.clearError();
                ordersProvider.loadOrders();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppGradients.button,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Попробовать снова',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Премиум пустое состояние
  Widget _buildPremiumEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.3),
                          blurRadius: 30,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 56, color: Colors.white),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Список заказов с анимацией
  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildPremiumOrderCard(orders[index]),
              ),
            );
          },
        );
      },
    );
  }

  // Премиум карточка заказа
  Widget _buildPremiumOrderCard(Order order) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
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
              color: _getStatusGradientColors(order.status)[0].withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Верхняя часть с градиентом
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getStatusGradientColors(order.status)
                      .map((c) => c.withOpacity(0.1))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Номер заказа с иконкой
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getStatusGradientColors(order.status),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getStatusIcon(order.status),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Заказ #${order.id}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Статус с анимацией
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getStatusGradientColors(order.status),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusGradientColors(order.status)[0]
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      order.statusText,
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

            // Информация о заказе
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Адрес доставки
                  if (order.address != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.address?['address'] ?? 'Адрес не указан',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],

                  // Товары и сумма
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${order.itemsCount} ${_getItemsText(order.itemsCount)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Сумма с градиентом
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.formattedAmount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getStatusGradientColors(String status) {
    switch (status) {
      case 'pending':
        return [Colors.orange.shade400, Colors.orange.shade600];
      case 'processing':
        return [AppColors.aurora1, AppColors.aurora2];
      case 'ready':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'completed':
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 'cancelled':
        return [Colors.red.shade400, Colors.red.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.sync;
      case 'ready':
        return Icons.check_circle;
      case 'completed':
        return Icons.archive;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_getDaysText(difference.inDays)} назад';
    } else {
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }

  String _getItemsText(int count) {
    if (count == 1) return 'товар';
    if (count >= 2 && count <= 4) return 'товара';
    return 'товаров';
  }

  String _getDaysText(int count) {
    if (count == 1) return 'день';
    if (count >= 2 && count <= 4) return 'дня';
    return 'дней';
  }
}
