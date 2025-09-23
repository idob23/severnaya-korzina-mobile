// lib/screens/catalog/catalog_screen.dart - ФИНАЛЬНАЯ ВЕРСИЯ с визуальными улучшениями
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
// ДОБАВЛЯЕМ импорты для визуала
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

import 'package:flutter/services.dart'; // Для HapticFeedback
import '../../design_system/spacing/app_spacing.dart'; // Для констант отступов

import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Загружаем данные с сервера при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Метод для показа красивого меню категорий - ЦЕНТРИРОВАННЫЙ ДИАЛОГ
  void _showCategoryMenu(
      BuildContext context, ProductsProvider productsProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // УЛУЧШЕНО: темный фон
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // УЛУЧШЕНО: больше радиус
          ),
          elevation: 16, // ДОБАВЛЕНО: тень
          child: Container(
            // ДОБАВЛЕНО: дополнительная тень для премиум эффекта
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary, // УЛУЧШЕНО: градиент
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          24), // УЛУЧШЕНО: соответствует диалогу
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Выберите категорию',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing:
                              0.5, // ДОБАВЛЕНО: межбуквенный интервал
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Список категорий
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Показать все товары
                        _buildCategoryTile(
                          context: context,
                          icon: Icons.apps,
                          title: 'Все товары',
                          isSelected:
                              productsProvider.selectedCategoryId == null,
                          count: productsProvider.products.length,
                          onTap: () {
                            productsProvider.filterByCategory(null);
                            Navigator.pop(context);
                          },
                        ),

                        // Разделитель
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                              height: 1,
                              color: AppColors.border), // УЛУЧШЕНО: цвет
                        ),

                        // Остальные категории
                        ...productsProvider.categories.map((category) {
                          final isSelected =
                              productsProvider.selectedCategoryId ==
                                  category.id;
                          return _buildCategoryTile(
                            context: context,
                            icon: Icons.category,
                            title: category.name,
                            isSelected: isSelected,
                            count: category.productsCount,
                            onTap: () {
                              productsProvider.filterByCategory(category.id);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                // Нижняя панель с действиями
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // УЛУЧШЕНО: градиент
                      colors: [AppColors.background, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24), // УЛУЧШЕНО: радиус
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            productsProvider.filterByCategory(null);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            // УЛУЧШЕНО: стиль кнопки
                            foregroundColor: AppColors.primaryDark,
                          ),
                          child: Text('Показать все'),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: Text('Закрыть'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Виджет плитки категории с улучшенным дизайном
  Widget _buildCategoryTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    int? count,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          // ДОБАВЛЕНО: анимация
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            // УЛУЧШЕНО: градиентный фон для выбранной категории
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.05),
                      AppColors.primaryLight.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // УЛУЧШЕНО: градиент для иконки
                  gradient: isSelected ? AppGradients.button : null,
                  color: isSelected ? null : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppGradients.button : null,
                    color: isSelected ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              if (isSelected) ...[
                SizedBox(width: 8),
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary, // УЛУЧШЕНО: градиент
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            // Компактный заголовок с выпадающим списком категорий
            title: Consumer<ProductsProvider>(
              builder: (context, productsProvider, child) {
                // Получаем текущую выбранную категорию
                String currentCategoryName = 'Все товары';
                Icon currentIcon = Icon(Icons.apps, size: 18);

                if (productsProvider.selectedCategoryId != null) {
                  final selectedCategory =
                      productsProvider.categories.firstWhere(
                    (cat) => cat.id == productsProvider.selectedCategoryId,
                    orElse: () => productsProvider.categories.first,
                  );
                  currentCategoryName = selectedCategory.name;
                  currentIcon = Icon(Icons.category, size: 18);
                }

                return InkWell(
                  onTap: () {
                    // Показываем красивое меню при нажатии
                    _showCategoryMenu(context, productsProvider);
                  },
                  borderRadius:
                      BorderRadius.circular(8), // ДОБАВЛЕНО: эффект ripple
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), // ДОБАВЛЕНО: фон
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        currentIcon,
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            currentCategoryName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              // Иконка корзины с индикатором
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.pushNamed(context, '/cart');
                        },
                      ),
                      if (cart.totalItems > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                // УЛУЧШЕНО: градиент
                                colors: [Colors.red, Colors.red.shade700],
                              ),
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cart.totalItems}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // ДОБАВЛЕНО: фоновый градиент
            colors: [AppColors.background, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Поле поиска - Компактная версия с улучшенным дизайном
            // УЛУЧШЕННАЯ поисковая строка с анимацией и микрофоном
            Consumer<ProductsProvider>(
              builder: (context, productsProvider, child) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  height: 56, // Увеличен размер для лучшего UX
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28), // Более округлый
                    // Множественные тени для премиум эффекта
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                    // Градиентная обводка
                    border: Border.all(
                      color: productsProvider.hasSearchQuery
                          ? AppColors.primaryLight.withOpacity(0.3)
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      productsProvider.searchProducts(value);
                      setState(() {}); // Обновляем UI для кнопки очистки
                    },
                    onSubmitted: (query) {
                      productsProvider.searchProducts(query);
                    },
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Поиск товаров...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      // Анимированная иконка поиска
                      prefixIcon: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          _searchController.text.isNotEmpty
                              ? Icons.search_off
                              : Icons.search,
                          key: ValueKey(_searchController.text.isNotEmpty),
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
                      ),
                      // Суффиксные иконки: микрофон и очистка
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Кнопка микрофона (визуальная)
                          // if (_searchController.text.isEmpty)
                          //   AnimatedOpacity(
                          //     duration: Duration(milliseconds: 200),
                          //     opacity: _searchController.text.isEmpty ? 1 : 0,
                          //     child: IconButton(
                          //       icon: Icon(
                          //         Icons.mic,
                          //         color: AppColors.primaryLight,
                          //         size: 20,
                          //       ),
                          //       onPressed: () {
                          //         // Haptic feedback
                          //         HapticFeedback.lightImpact();
                          //         // TODO: Реализовать голосовой поиск
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           SnackBar(
                          //             content:
                          //                 Text('Голосовой поиск в разработке'),
                          //             duration: Duration(seconds: 1),
                          //             backgroundColor: AppColors.primaryDark,
                          //             behavior: SnackBarBehavior.floating,
                          //             margin: EdgeInsets.all(20),
                          //             shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(12),
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // Кнопка очистки с анимацией
                          if (_searchController.text.isNotEmpty)
                            AnimatedScale(
                              duration: Duration(milliseconds: 200),
                              scale: _searchController.text.isNotEmpty ? 1 : 0,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.clear,
                                    color: AppColors.error,
                                    size: 16,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _searchController.clear();
                                  productsProvider.clearSearch();
                                  productsProvider.loadProducts();
                                  setState(() {});
                                },
                              ),
                            ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Список товаров
            Expanded(
              child: Consumer<ProductsProvider>(
                builder: (context, productsProvider, child) {
                  // Отображение загрузки с SHIMMER эффектом
                  if (productsProvider.isLoading) {
                    return ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: 6, // Показываем 6 skeleton карточек
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withOpacity(0.08),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Имитация названия товара
                              _ShimmerWidget(
                                child: Container(
                                  height: 20,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),

                              // Имитация описания
                              _ShimmerWidget(
                                child: Container(
                                  height: 14,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Имитация цены и кнопки
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Цена
                                  _ShimmerWidget(
                                    child: Container(
                                      height: 32,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  // Кнопка
                                  _ShimmerWidget(
                                    child: Container(
                                      height: 44,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  // Отображение ошибки
                  if (productsProvider.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Ошибка загрузки',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              productsProvider.error ?? 'Неизвестная ошибка',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(Icons.refresh),
                                  label: Text('Обновить'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () => productsProvider.refresh(),
                                ),
                                SizedBox(width: 16),
                                OutlinedButton(
                                  child: Text('Подробнее'),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    _showErrorDetails(
                                      context,
                                      productsProvider.error ??
                                          'Нет дополнительной информации',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final products = productsProvider.filteredProducts;

                  // Отображение пустого состояния
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              productsProvider.hasSearchQuery ||
                                      productsProvider.hasSelectedCategory
                                  ? 'Товары не найдены'
                                  : 'Каталог пуст',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              productsProvider.hasSearchQuery ||
                                      productsProvider.hasSelectedCategory
                                  ? 'Попробуйте изменить условия поиска'
                                  : 'Товары пока не добавлены',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            if (productsProvider.hasSearchQuery ||
                                productsProvider.hasSelectedCategory)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      productsProvider.clearFilters(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text('Сбросить фильтры'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Отображение списка товаров
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Определяем статус остатков
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! > 0 &&
        product.maxQuantity! <= 10;

    final cartProvider = Provider.of<CartProvider>(context);
    final quantityInCart = cartProvider.getProductQuantity(product.id);

    return AnimatedContainer(
      // ДОБАВЛЕНО: анимация
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0, // ИЗМЕНЕНО: убираем стандартную тень
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // УЛУЧШЕНО: больше радиус
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                hasStock ? () => _showProductDetails(context, product) : null,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Левая часть - информация о товаре
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Название
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // УЛУЧШЕНО: цвет
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),

                        // Категория
                        if (product.category != null)
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category!.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),

                        // Описание
                        if (product.description != null &&
                            product.description!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        SizedBox(height: 8),

                        // Индикатор остатков с градиентом
                        if (product.maxQuantity != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: !hasStock
                                  ? LinearGradient(colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade600
                                    ])
                                  : isLowStock
                                      ? LinearGradient(colors: [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600
                                        ])
                                      : LinearGradient(colors: [
                                          Colors.green.shade400,
                                          Colors.green.shade600
                                        ]),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: !hasStock
                                      ? Colors.red.withOpacity(0.3)
                                      : isLowStock
                                          ? Colors.orange.withOpacity(0.3)
                                          : Colors.green.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              !hasStock
                                  ? '❌ Нет в наличии'
                                  : isLowStock
                                      ? '⚠️ Осталось: ${product.maxQuantity}'
                                      : '✅ В наличии: ${product.maxQuantity}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        SizedBox(height: 8),

                        // Цена с градиентным текстом
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppGradients.primary.createShader(bounds),
                              child: Text(
                                '${product.price.toStringAsFixed(0)} ₽',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              ' / ${product.unit ?? 'шт'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Правая часть - управление количеством
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Если товар уже в корзине - показываем счетчик
                      if (quantityInCart > 0) ...[
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.button, // УЛУЧШЕНО: градиент
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  cartProvider.decrementItem(product.id);
                                },
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$quantityInCart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add,
                                    color: Colors.white, size: 20),
                                onPressed: hasStock
                                    ? () {
                                        if (product.maxQuantity == null ||
                                            quantityInCart <
                                                product.maxQuantity!) {
                                          cartProvider.addItem(
                                            productId: product.id,
                                            name: product.name,
                                            price: product.price,
                                            unit: product.unit ?? 'шт',
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Достигнуто максимальное количество',
                                              ),
                                              backgroundColor: Colors.orange,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Кнопка добавления в корзину с градиентом
                        ElevatedButton(
                          onPressed: hasStock
                              ? () => cartProvider.addItem(
                                    productId: product.id,
                                    name: product.name,
                                    price: product.price,
                                    unit: product.unit ?? 'шт',
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: hasStock
                                  ? AppGradients.button
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.shade400,
                                        Colors.grey.shade500
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: hasStock
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryLight
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Container(
                              constraints:
                                  BoxConstraints(minWidth: 120, minHeight: 40),
                              alignment: Alignment.center,
                              child: Text(
                                hasStock ? 'В корзину' : 'Нет в наличии',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // /// Виджет карточки товара с УЛУЧШЕННЫМ ДИЗАЙНОМ
  // Widget _buildProductCard(BuildContext context, Product product) {
  //   // Определяем статус остатков
  //   final bool hasStock =
  //       product.maxQuantity == null || product.maxQuantity! > 0;
  //   final bool isLowStock = product.maxQuantity != null &&
  //       product.maxQuantity! > 0 &&
  //       product.maxQuantity! <= 10;
  //   final bool isOutOfStock = !hasStock;

  //   final cartProvider = Provider.of<CartProvider>(context);
  //   final quantityInCart = cartProvider.getProductQuantity(product.id);

  //   return AnimatedContainer(
  //     duration: Duration(milliseconds: 200),
  //     margin: EdgeInsets.only(bottom: 16), // Увеличен отступ
  //     child: Material(
  //       color: Colors.transparent,
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20), // Больше радиус
  //           boxShadow: [
  //             BoxShadow(
  //               color: AppColors.primaryLight.withOpacity(0.08),
  //               blurRadius: 20,
  //               offset: Offset(0, 8),
  //             ),
  //             BoxShadow(
  //               color: AppColors.shadowLight,
  //               blurRadius: 10,
  //               offset: Offset(0, 4),
  //             ),
  //           ],
  //         ),
  //         child: InkWell(
  //           borderRadius: BorderRadius.circular(20),
  //           onTap: hasStock
  //               ? () {
  //                   HapticFeedback.lightImpact();
  //                   _showProductDetails(context, product);
  //                 }
  //               : null,
  //           child: Padding(
  //             padding: EdgeInsets.all(18), // Увеличенные отступы
  //             child: Row(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 // Левая часть - информация о товаре
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Название с бейджем категории
  //                       Row(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Expanded(
  //                             child: Text(
  //                               product.name,
  //                               style: TextStyle(
  //                                 fontSize: 17,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: isOutOfStock
  //                                     ? AppColors.textSecondary
  //                                     : AppColors.textPrimary,
  //                                 height: 1.3,
  //                               ),
  //                               maxLines: 2,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ),
  //                           // Бейдж наличия
  //                           if (isOutOfStock || isLowStock)
  //                             Container(
  //                               margin: EdgeInsets.only(left: 8),
  //                               padding: EdgeInsets.symmetric(
  //                                 horizontal: 8,
  //                                 vertical: 4,
  //                               ),
  //                               decoration: BoxDecoration(
  //                                 color: isOutOfStock
  //                                     ? AppColors.error.withOpacity(0.1)
  //                                     : AppColors.warning.withOpacity(0.1),
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 border: Border.all(
  //                                   color: isOutOfStock
  //                                       ? AppColors.error.withOpacity(0.3)
  //                                       : AppColors.warning.withOpacity(0.3),
  //                                   width: 1,
  //                                 ),
  //                               ),
  //                               child: Text(
  //                                 isOutOfStock ? 'Нет' : 'Мало',
  //                                 style: TextStyle(
  //                                   fontSize: 11,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: isOutOfStock
  //                                       ? AppColors.error
  //                                       : AppColors.warning,
  //                                 ),
  //                               ),
  //                             ),
  //                         ],
  //                       ),

  //                       SizedBox(height: 8),

  //                       // Единица измерения
  //                       Row(
  //                         children: [
  //                           Icon(
  //                             Icons.scale_outlined,
  //                             size: 14,
  //                             color: AppColors.textSecondary.withOpacity(0.6),
  //                           ),
  //                           SizedBox(width: 4),
  //                           Text(
  //                             product.unit ?? 'шт',
  //                             style: TextStyle(
  //                               fontSize: 13,
  //                               color: AppColors.textSecondary,
  //                             ),
  //                           ),
  //                         ],
  //                       ),

  //                       SizedBox(height: 12),

  //                       // Цена с анимированным фоном
  //                       Container(
  //                         padding: EdgeInsets.symmetric(
  //                           horizontal: 12,
  //                           vertical: 6,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [
  //                               AppColors.primaryLight.withOpacity(0.05),
  //                               AppColors.aurora1.withOpacity(0.03),
  //                             ],
  //                             begin: Alignment.centerLeft,
  //                             end: Alignment.centerRight,
  //                           ),
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Text(
  //                               '${product.price.toStringAsFixed(0)}',
  //                               style: TextStyle(
  //                                 fontSize: 22,
  //                                 fontWeight: FontWeight.w700,
  //                                 color: AppColors.primaryDark,
  //                               ),
  //                             ),
  //                             SizedBox(width: 4),
  //                             Text(
  //                               '₽',
  //                               style: TextStyle(
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.w500,
  //                                 color: AppColors.primaryDark.withOpacity(0.8),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 SizedBox(width: 16),

  //                 // Правая часть - управление количеством с анимацией
  //                 AnimatedContainer(
  //                   duration: Duration(milliseconds: 300),
  //                   child: quantityInCart > 0
  //                       ? Container(
  //                           decoration: BoxDecoration(
  //                             gradient: AppGradients.button,
  //                             borderRadius: BorderRadius.circular(16),
  //                             boxShadow: [
  //                               BoxShadow(
  //                                 color:
  //                                     AppColors.primaryLight.withOpacity(0.3),
  //                                 blurRadius: 12,
  //                                 offset: Offset(0, 6),
  //                               ),
  //                             ],
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               // Кнопка уменьшения
  //                               Material(
  //                                 color: Colors.transparent,
  //                                 child: InkWell(
  //                                   borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(16),
  //                                     bottomLeft: Radius.circular(16),
  //                                   ),
  //                                   onTap: () {
  //                                     HapticFeedback.lightImpact();
  //                                     cartProvider.decrementItem(product.id);
  //                                   },
  //                                   child: Container(
  //                                     padding: EdgeInsets.all(12),
  //                                     child: Icon(
  //                                       Icons.remove,
  //                                       color: Colors.white,
  //                                       size: 20,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               // Количество с анимацией
  //                               AnimatedContainer(
  //                                 duration: Duration(milliseconds: 200),
  //                                 padding: EdgeInsets.symmetric(horizontal: 16),
  //                                 child: Text(
  //                                   '$quantityInCart',
  //                                   style: TextStyle(
  //                                     fontSize: 17,
  //                                     fontWeight: FontWeight.bold,
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                               // Кнопка увеличения
  //                               Material(
  //                                 color: Colors.transparent,
  //                                 child: InkWell(
  //                                   borderRadius: BorderRadius.only(
  //                                     topRight: Radius.circular(16),
  //                                     bottomRight: Radius.circular(16),
  //                                   ),
  //                                   onTap: hasStock &&
  //                                           (product.maxQuantity == null ||
  //                                               quantityInCart <
  //                                                   product.maxQuantity!)
  //                                       ? () {
  //                                           HapticFeedback.lightImpact();
  //                                           cartProvider.addItem(
  //                                             productId: product.id,
  //                                             name: product.name,
  //                                             price: product.price,
  //                                             unit: product.unit ?? 'шт',
  //                                           );
  //                                         }
  //                                       : null,
  //                                   child: Container(
  //                                     padding: EdgeInsets.all(12),
  //                                     child: Icon(
  //                                       Icons.add,
  //                                       color: (product.maxQuantity != null &&
  //                                               quantityInCart >=
  //                                                   product.maxQuantity!)
  //                                           ? Colors.white.withOpacity(0.3)
  //                                           : Colors.white,
  //                                       size: 20,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         )
  //                       : SizedBox(
  //                           height: 52,
  //                           child: ElevatedButton(
  //                             onPressed: isOutOfStock
  //                                 ? null
  //                                 : () {
  //                                     HapticFeedback.mediumImpact();
  //                                     cartProvider.addItem(
  //                                       productId: product.id,
  //                                       name: product.name,
  //                                       price: product.price,
  //                                       unit: product.unit ?? 'шт',
  //                                     );
  //                                   },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: isOutOfStock
  //                                   ? AppColors.textSecondary.withOpacity(0.3)
  //                                   : null,
  //                               padding: EdgeInsets.zero,
  //                               elevation: 0,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(16),
  //                               ),
  //                             ),
  //                             child: Ink(
  //                               decoration: BoxDecoration(
  //                                 gradient:
  //                                     isOutOfStock ? null : AppGradients.button,
  //                                 color: isOutOfStock
  //                                     ? AppColors.textSecondary.withOpacity(0.3)
  //                                     : null,
  //                                 borderRadius: BorderRadius.circular(16),
  //                               ),
  //                               child: Container(
  //                                 padding: EdgeInsets.symmetric(
  //                                   vertical: 14,
  //                                   horizontal: 20,
  //                                 ),
  //                                 child: Row(
  //                                   mainAxisSize: MainAxisSize.min,
  //                                   children: [
  //                                     Icon(
  //                                       isOutOfStock
  //                                           ? Icons.remove_shopping_cart
  //                                           : Icons.shopping_cart,
  //                                       size: 20,
  //                                       color: Colors.white,
  //                                     ),
  //                                     SizedBox(width: 8),
  //                                     Text(
  //                                       isOutOfStock ? 'Нет' : 'В корзину',
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.w600,
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// Показать детали товара с информацией об остатках
  void _showProductDetails(BuildContext context, Product product) {
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! <= 5 &&
        product.maxQuantity! > 0;
    final bool isOutOfStock =
        product.maxQuantity != null && product.maxQuantity! <= 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Индикатор для свайпа
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Название товара
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Категория
                    if (product.category != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category!.name,
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    SizedBox(height: 16),

                    // Описание
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      Text(
                        'Описание',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Информация о наличии с премиум дизайном
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isOutOfStock
                              ? [Colors.red.shade50, Colors.red.shade100]
                              : isLowStock
                                  ? [
                                      Colors.orange.shade50,
                                      Colors.orange.shade100
                                    ]
                                  : [
                                      Colors.green.shade50,
                                      Colors.green.shade100
                                    ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOutOfStock
                              ? Colors.red.shade200
                              : isLowStock
                                  ? Colors.orange.shade200
                                  : Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOutOfStock
                                ? Icons.cancel
                                : isLowStock
                                    ? Icons.warning
                                    : Icons.check_circle,
                            color: isOutOfStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : Colors.green,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOutOfStock
                                      ? 'Нет в наличии'
                                      : isLowStock
                                          ? 'Заканчивается!'
                                          : 'В наличии',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock
                                        ? Colors.red.shade700
                                        : isLowStock
                                            ? Colors.orange.shade700
                                            : Colors.green.shade700,
                                  ),
                                ),
                                if (product.maxQuantity != null &&
                                    product.maxQuantity! > 0)
                                  Text(
                                    'Остаток: ${product.maxQuantity} ${product.unit ?? 'шт'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Цена и кнопка с градиентом
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Цена',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppGradients.primary.createShader(bounds),
                              child: Text(
                                '${product.price.toStringAsFixed(0)} ₽',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            final quantityInCart =
                                cartProvider.getProductQuantity(product.id);

                            return quantityInCart > 0
                                ? Container(
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.button,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryLight
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove,
                                              color: Colors.white),
                                          onPressed: () => cartProvider
                                              .decrementItem(product.id),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Text(
                                            '$quantityInCart',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              color: Colors.white),
                                          onPressed: () => cartProvider.addItem(
                                            productId: product.id,
                                            name: product.name,
                                            price: product.price,
                                            unit: product.unit ?? 'шт',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: isOutOfStock
                                        ? null
                                        : () => cartProvider.addItem(
                                              productId: product.id,
                                              name: product.name,
                                              price: product.price,
                                              unit: product.unit ?? 'шт',
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isOutOfStock ? Colors.grey : null,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: isOutOfStock
                                            ? null
                                            : AppGradients.button,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 24),
                                        child: Text(
                                          isOutOfStock
                                              ? 'Нет в наличии'
                                              : 'Добавить в корзину',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Показать детали ошибки
  void _showErrorDetails(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Детали ошибки'),
        content: SingleChildScrollView(
          child: Text(error),
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
}

/// Виджет для создания shimmer эффекта
class _ShimmerWidget extends StatefulWidget {
  final Widget child;

  const _ShimmerWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: GradientRotation(0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}
