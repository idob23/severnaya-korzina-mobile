// ========================================
// 3. lib/screens/profile/profile_screen.dart
// ========================================

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
          CircularProgressIndicator(),
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
          // Информация о пользователе
          Card(
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
                      color: Colors.blue,
                      shape: BoxShape.circle,
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
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Пункты меню
          _buildMenuSection(context, authProvider),

          SizedBox(height: 20),

          // Кнопка выхода
          _buildLogoutButton(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Редактировать профиль',
            subtitle: 'Изменить имя, email и другие данные',
            onTap: () => _showEditProfileDialog(context, authProvider),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Мои адреса',
            subtitle: 'Управление адресами доставки',
            onTap: () {
              // TODO: Переход к экрану адресов
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Экран адресов в разработке')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'История заказов',
            subtitle: 'Посмотреть все ваши заказы',
            onTap: () {
              // TODO: Переход к истории заказов
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('История заказов в разработке')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Уведомления',
            subtitle: 'Настройка push-уведомлений',
            onTap: () {
              // TODO: Настройки уведомлений
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Настройки уведомлений в разработке')),
              );
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Помощь и поддержка',
            subtitle: 'Часто задаваемые вопросы',
            onTap: () {
              // TODO: Экран помощи
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Помощь в разработке')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
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

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    final firstNameController = TextEditingController(text: user.name);
    final lastNameController = TextEditingController(text: user.lastName ?? '');
    final emailController = TextEditingController(text: user.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать профиль'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Фамилия',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await authProvider.updateUserProfile(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                email: emailController.text.trim(),
              );

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
                    content:
                        Text(authProvider.lastError ?? 'Ошибка обновления'),
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

              // Переходим к экрану выбора авторизации
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => AuthChoiceScreen(),
                ),
                (route) => false,
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
