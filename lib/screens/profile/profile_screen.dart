import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';
import '../auth/auth_choice_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated &&
              authProvider.currentUser != null) {
            // Авторизованный пользователь
            return _buildAuthenticatedProfile(context, authProvider);
          } else {
            // Неавторизованный пользователь
            return _buildUnauthenticatedProfile(context);
          }
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(
      BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    final cartProvider = Provider.of<CartProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Информация о пользователе
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Активный пользователь',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Статистика
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Моя статистика',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.shopping_cart,
                        title: 'В корзине',
                        value: '${cartProvider.itemCount}',
                        color: Colors.blue,
                      ),
                      _buildStatItem(
                        icon: Icons.list_alt,
                        title: 'Заказов',
                        value: '0', // TODO: реальная статистика
                        color: Colors.orange,
                      ),
                      _buildStatItem(
                        icon: Icons.savings,
                        title: 'Экономия',
                        value: '0₽', // TODO: реальная статистика
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Меню действий
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.shopping_bag, color: Colors.blue),
                  title: Text('Мои заказы'),
                  subtitle: Text('История покупок и текущие заказы'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: переход к заказам
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Переход к заказам - в разработке')),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications, color: Colors.orange),
                  title: Text('Уведомления'),
                  subtitle: Text('Настройки push-уведомлений'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Настройки уведомлений - в разработке')),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.purple),
                  title: Text('Помощь'),
                  subtitle: Text('Часто задаваемые вопросы'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showHelpDialog(context);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Выйти'),
                  subtitle: Text('Выход из аккаунта'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showLogoutDialog(context, authProvider);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Информация о приложении
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Северная корзина v1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Коллективные закупки для Усть-Неры',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedProfile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Войдите в аккаунт',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Авторизуйтесь для доступа к личному кабинету и оформления заказов',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Войти или зарегистрироваться',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Помощь'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Как сделать заказ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '1. Выберите товары в каталоге\n2. Добавьте их в корзину\n3. Оплатите предоплату (90%)\n4. Получите товары и доплатите остаток'),
              SizedBox(height: 16),
              Text(
                'Контакты:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Телефон поддержки: +7 (xxx) xxx-xx-xx\nEmail: support@severnaya-korzina.ru'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Выход'),
        content: Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();

              // Очищаем корзину при выходе
              Provider.of<CartProvider>(context, listen: false).clear();

              // Переходим к экрану авторизации
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                (route) => false,
              );
            },
            child: Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
