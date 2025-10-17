// lib/screens/profile/add_address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';
import '../../providers/auth_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // addAddress возвращает bool, а не Map
      final success = await authProvider.addAddress(
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        isDefault: _isDefault,
      );

      if (success) {
        HapticFeedback.heavyImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Адрес добавлен'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        throw Exception(authProvider.lastError ?? 'Ошибка добавления адреса');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.aurora,
          ),
        ),
        title: Text(
          'Добавить адрес',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.ice,
              AppColors.snow,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Информационная карточка
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ice.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.primaryLight,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Укажите адрес для доставки товаров',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Название адреса
                      _buildTextField(
                        controller: _titleController,
                        label: 'Название адреса',
                        hint: 'Например: Дом, Работа',
                        icon: Icons.label_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите название адреса';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Адрес
                      _buildTextField(
                        controller: _addressController,
                        label: 'Адрес доставки',
                        hint: 'г. Магадан, ул. Примерная, д. 1, кв. 1',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите адрес доставки';
                          }
                          if (value.trim().length < 10) {
                            return 'Адрес слишком короткий';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Чекбокс "Сделать основным"
                      Container(
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
                        child: CheckboxListTile(
                          title: Text(
                            'Сделать основным адресом',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Будет использоваться по умолчанию',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: _isDefault,
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            setState(() => _isDefault = value ?? false);
                          },
                          activeColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 8, bottom: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: Icon(icon, color: AppColors.primaryLight),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              validator: validator,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Сохранить адрес',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
