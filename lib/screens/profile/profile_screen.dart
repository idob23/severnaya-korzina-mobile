// lib/screens/profile/profile_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
          if (!authProvider.isAuthenticated) {
            return _buildUnauthenticatedView(context);
          }

          final user = authProvider.currentUser!;
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
            Icon(
              Icons.person_outline,
              size: 80,
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
              'Авторизуйтесь для доступа к профилю, заказам и персональным настройкам',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Войти или зарегистрироваться',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(
      BuildContext context, user, AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Шапка профиля
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: Column(
              children: [
                // Аватар
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[100],
                  child: user.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(user.initials);
                            },
                          ),
                        )
                      : _buildDefaultAvatar(user.initials),
                ),
                SizedBox(height: 16),

                // Имя пользователя
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),

                // Телефон
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                if (user.email != null && user.email!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    user.email!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Меню профиля
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMenuSection('Аккаунт', [
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Редактировать профиль',
                    subtitle: 'Изменить личные данные',
                    onTap: () =>
                        _showEditProfileDialog(context, user, authProvider),
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Адреса доставки',
                    subtitle: 'Управление адресами',
                    onTap: () => _showAddressesDialog(context),
                  ),
                ]),

                SizedBox(height: 24),

                _buildMenuSection('Заказы', [
                  _buildMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'Мои заказы',
                    subtitle: 'История покупок и текущие заказы',
                    onTap: () {
                      // Переходим на вкладку заказов
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'Избранное',
                    subtitle: 'Понравившиеся товары',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Избранное - в разработке')),
                      );
                    },
                  ),
                ]),

                SizedBox(height: 24),

                _buildMenuSection('Настройки', [
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Уведомления',
                    subtitle: 'Настройки push-уведомлений',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Настройки уведомлений - в разработке')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Помощь',
                    subtitle: 'Часто задаваемые вопросы',
                    onTap: () => _showHelpDialog(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    subtitle: 'Версия и информация',
                    onTap: () => _showAboutDialog(context),
                  ),
                ]),

                SizedBox(height: 32),

                // Кнопка выхода
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    icon: Icon(Icons.logout, color: Colors.red),
                    label: Text(
                      'Выйти из аккаунта',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildDefaultAvatar(String initials) {
    return Text(
      initials,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.blue[800],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        child: Icon(icon, color: Colors.blue[700]),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(
      BuildContext context, user, AuthProvider authProvider) {
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
                labelText: 'Email (необязательно)',
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
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                email: emailController.text.trim(),
              );

              Navigator.pop(context);

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
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAddressesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Адреса доставки'),
        content: Text('Управление адресами - в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Помощь'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Частые вопросы:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Как сделать заказ?'),
            Text('• Как отследить доставку?'),
            Text('• Как связаться с поддержкой?'),
            Text('• Условия коллективных закупок'),
            SizedBox(height: 16),
            Text(
              'Для получения помощи обратитесь в поддержку:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('📞 +7 (999) 123-45-67'),
            Text('📧 support@severnaya-korzina.ru'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Северная корзина',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Платформа коллективных закупок для жителей Усть-Неры.',
            ),
            SizedBox(height: 12),
            Text(
              'Экономьте до 70% на покупках благодаря совместным заказам!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
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
        content: Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Вы вышли из аккаунта'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
