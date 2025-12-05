// lib/screens/catalog/catalog_screen.dart - ФИНАЛЬНАЯ ВЕРСИЯ с визуальными улучшениями
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // ← ДОБАВИТЬ ЭТУ СТРОКУ
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
  Timer? _debounceTimer; // ← ДОБАВИТЬ ЭТУ СТРОКУ
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 🆕 ДОБАВИТЬ слушатель скролла
    _scrollController.addListener(_onScroll);

    // Загружаем данные с сервера при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.init();
    });
  }

  // 🆕 ДОБАВИТЬ ВЕСЬ ЭТОТ МЕТОД
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // За 200 пикселей до конца начинаем загрузку
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);

      if (!productsProvider.isLoadingMore && productsProvider.hasMore) {
        productsProvider.loadMoreProducts();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose(); // 🆕 ДОБАВИТЬ
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
                      Expanded(
                        // ← ИЗМЕНИТЬ Text на Expanded + Text
                        child: Text(
                          'Выберите категорию',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis, // ← ДОБАВИТЬ
                          maxLines: 1, // ← ДОБАВИТЬ
                        ),
                      ),
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
                          count: productsProvider.totalProducts,
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
                      // ✅ НОВОЕ: Отменяем предыдущий таймер
                      if (_debounceTimer?.isActive ?? false) {
                        _debounceTimer!.cancel();
                      }

                      // ✅ НОВОЕ: Запускаем новый таймер на 500мс
                      _debounceTimer =
                          Timer(const Duration(milliseconds: 500), () {
                        productsProvider.searchProducts(value);
                      });
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
                          // ✅ ДОБАВИТЬ: Индикатор загрузки
                          Consumer<ProductsProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoading &&
                                  _searchController.text.isNotEmpty) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          AppColors.primaryDark),
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
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
                    controller: _scrollController, // 🆕 ДОБАВИТЬ
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: products.length +
                        (productsProvider.hasMore ? 1 : 0), // 🆕 ИЗМЕНИТЬ
                    itemBuilder: (context, index) {
                      // 🆕 ДОБАВИТЬ проверку для индикатора загрузки
                      if (index == products.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryLight),
                            ),
                          ),
                        );
                      }

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

  /// Улучшенная карточка товара с исправленными анимациями
  Widget _buildProductCard(BuildContext context, Product product) {
    // Определяем статус остатков
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! > 0 &&
        product.maxQuantity! <= 10;
    final bool isOutOfStock = !hasStock;

    final cartProvider = Provider.of<CartProvider>(context);
    final quantityInCart = cartProvider.getProductQuantity(product.id);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isOutOfStock ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOutOfStock
                  ? Colors.grey.shade300
                  : isLowStock
                      ? AppColors.warning.withOpacity(0.5)
                      : AppColors.border.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLowStock
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.shadowLight,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: hasStock
                ? () {
                    HapticFeedback.lightImpact();
                    _showProductDetails(context, product);
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя строка: категория и статус
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Категория
                      if (product.category != null)
                        Flexible(
                          // ← ДОБАВИТЬ Flexible
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.aurora1.withOpacity(0.1),
                                  AppColors.aurora2.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.aurora1.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 12,
                                  color: AppColors.aurora1,
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  // ← ДОБАВИТЬ Flexible для Text
                                  child: Text(
                                    product.category!.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.aurora1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow:
                                        TextOverflow.ellipsis, // ← ДОБАВИТЬ
                                    maxLines: 1, // ← ДОБАВИТЬ
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Статус наличия
                      if (isLowStock)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Мало',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isOutOfStock)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Нет в наличии',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Название товара
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Описание (если есть)
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    SizedBox(height: 6),
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: 12),

                  // Нижняя строка: цена и кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Цена
                      Flexible(
                        // ✅ ИЗМЕНЕНО: было Expanded
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // ✅ ДОБАВЛЕНО
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                // ✅ ЦЕНА ЗАВИСИТ ОТ ТИПА ПРОДАЖИ
                                Text(
                                  product.saleType == 'только уп'
                                      ? '${product.price.toStringAsFixed(0)}' // Цена за упаковку
                                      : (product.basePrice != null &&
                                              product.inPackage != null)
                                          ? '${(product.price / product.inPackage!).toStringAsFixed(0)}' // Цена за штуку
                                          : '${product.price.toStringAsFixed(0)}', // Цена как есть
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock
                                        ? AppColors.textSecondary
                                        : AppColors.primaryDark,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '₽',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isOutOfStock
                                        ? AppColors.textSecondary
                                            .withOpacity(0.7)
                                        : AppColors.primaryDark
                                            .withOpacity(0.8),
                                  ),
                                ),
                                // ✅ ЕДИНИЦА ИЗМЕРЕНИЯ
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    product.saleType == 'только уп'
                                        ? '/ уп' // Просто "/ уп" для упаковок
                                        : (product.baseUnit != null)
                                            ? '/ ${product.baseUnit}' // "/ шт" для штучных
                                            : '/ ${product.unit}', // Единица как есть
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // Остаток если есть ограничение
                            if (product.maxQuantity != null && hasStock) ...[
                              SizedBox(height: 2),
                              Text(
                                'Осталось: ${product.maxQuantity}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLowStock
                                      ? AppColors.warning
                                      : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis, // ✅ ДОБАВЛЕНО
                              ),
                            ],

                            // ✅ БЕЙДЖ "ТОЛЬКО УПАКОВКАМИ"
                            if (product.saleType == 'только уп' &&
                                product.inPackage != null) ...[
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '📦 ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(width: 12),

                      // Кнопки управления количеством
                      if (quantityInCart > 0)
                        _buildQuantityControls(
                          key: ValueKey('qty_${product.id}'),
                          product: product,
                          quantity: quantityInCart,
                          cartProvider: cartProvider,
                          hasStock: hasStock,
                        )
                      else
                        _buildAddToCartButton(
                          key: ValueKey('add_${product.id}'),
                          product: product,
                          cartProvider: cartProvider,
                          hasStock: hasStock,
                          isOutOfStock: isOutOfStock,
                        ),
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

// Виджет плейсхолдера для изображения
  Widget _buildProductPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.aurora1.withOpacity(0.1),
            AppColors.aurora3.withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 32,
          color: AppColors.aurora2.withOpacity(0.4),
        ),
      ),
    );
  }

// Виджет управления количеством
  Widget _buildQuantityControls({
    Key? key,
    required Product product,
    required int quantity,
    required CartProvider cartProvider,
    required bool hasStock,
  }) {
    // ✅ Шаг и минимум всегда = 1
    final step = 1;
    final minQty = 1;

    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: AppGradients.aurora,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.aurora1.withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка уменьшения
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (quantity > 1) {
                cartProvider.updateQuantity(product.id, quantity - 1);
              } else {
                // Удаляем товар из корзины
                cartProvider.updateQuantity(product.id, 0);
              }
            },
            borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                child: Icon(
                  quantity > 1 ? Icons.remove : Icons.delete,
                  key: ValueKey(quantity > 1),
                  color: quantity > 1 ? Colors.white : Colors.red.shade300,
                  size: 18,
                ),
              ),
            ),
          ),
          // Количество с анимацией
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Кнопка увеличения
          InkWell(
            onTap: hasStock &&
                    (product.maxQuantity == null ||
                        quantity + step <= product.maxQuantity!)
                ? () {
                    HapticFeedback.lightImpact();
                    cartProvider.updateQuantity(product.id, quantity + step);
                  }
                : null,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(
                Icons.add,
                color: hasStock &&
                        (product.maxQuantity == null ||
                            quantity + step <= product.maxQuantity!)
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Виджет кнопки добавления в корзину
  Widget _buildAddToCartButton({
    Key? key,
    required Product product,
    required CartProvider cartProvider,
    required bool hasStock,
    required bool isOutOfStock,
  }) {
    // ✅ ВСЕГДА добавляем 1 единицу (1 шт или 1 уп)
    final initialQuantity = 1;

    // print('=== ADD TO CART ===');
    // print('Product: ${product.name}');
    // print('saleType: ${product.saleType}');
    // print('inPackage: ${product.inPackage}');
    // print('initialQuantity: $initialQuantity');
    // print('===================');

    return GestureDetector(
      key: key,
      onTap: hasStock
          ? () {
              print(
                  '🔴 CLICKED! Adding ${product.name} with quantity: $initialQuantity');
              HapticFeedback.mediumImpact();

              // ✅ Правильная цена в зависимости от типа продажи
              final priceToUse = (product.saleType == 'поштучно' &&
                      product.inPackage != null &&
                      product.inPackage! > 0)
                  ? (product.price / product.inPackage!) // Цена за штуку
                  : product.price; // Цена за упаковку

              cartProvider.addItem(
                productId: product.id,
                name: product.name,
                price: priceToUse,
                unit: product.unit,
                quantity: initialQuantity,
                saleType: product.saleType,
                inPackage: product.inPackage,
              );
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isOutOfStock
              ? LinearGradient(
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                  ],
                )
              : AppGradients.button,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isOutOfStock
                  ? Colors.grey.withOpacity(0.3)
                  : AppColors.primaryLight.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOutOfStock
                  ? Icons.remove_shopping_cart
                  : Icons.add_shopping_cart,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              isOutOfStock ? 'Нет' : 'В корзину',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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

  // /// Показать детали товара с информацией об остатках
  // void _showProductDetails(BuildContext context, Product product) {
  //   final bool hasStock =
  //       product.maxQuantity == null || product.maxQuantity! > 0;
  //   final bool isLowStock = product.maxQuantity != null &&
  //       product.maxQuantity! <= 5 &&
  //       product.maxQuantity! > 0;
  //   final bool isOutOfStock =
  //       product.maxQuantity != null && product.maxQuantity! <= 0;

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppColors.shadowMedium,
  //             blurRadius: 20,
  //             offset: Offset(0, -10),
  //           ),
  //         ],
  //       ),
  //       child: DraggableScrollableSheet(
  //         initialChildSize: 0.6,
  //         minChildSize: 0.3,
  //         maxChildSize: 0.9,
  //         expand: false,
  //         builder: (context, scrollController) {
  //           return SingleChildScrollView(
  //             controller: scrollController,
  //             child: Padding(
  //               padding: EdgeInsets.all(20),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Индикатор для свайпа
  //                   Center(
  //                     child: Container(
  //                       width: 50,
  //                       height: 5,
  //                       decoration: BoxDecoration(
  //                         gradient: AppGradients.primary,
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20),

  //                   // Название товара
  //                   Text(
  //                     product.name,
  //                     style: TextStyle(
  //                       fontSize: 24,
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.textPrimary,
  //                     ),
  //                   ),
  //                   SizedBox(height: 8),

  //                   // Категория
  //                   if (product.category != null)
  //                     Container(
  //                       padding:
  //                           EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.primaryLight.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Text(
  //                         product.category!.name,
  //                         style: TextStyle(
  //                           color: AppColors.primaryDark,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                       ),
  //                     ),

  //                   SizedBox(height: 16),

  //                   // Описание
  //                   if (product.description != null &&
  //                       product.description!.isNotEmpty) ...[
  //                     Text(
  //                       'Описание',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w600,
  //                         color: AppColors.textPrimary,
  //                       ),
  //                     ),
  //                     SizedBox(height: 8),
  //                     Text(
  //                       product.description!,
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: AppColors.textSecondary,
  //                         height: 1.5,
  //                       ),
  //                     ),
  //                     SizedBox(height: 16),
  //                   ],

  //                   // Информация о наличии с премиум дизайном
  //                   Container(
  //                     padding: EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       gradient: LinearGradient(
  //                         colors: isOutOfStock
  //                             ? [Colors.red.shade50, Colors.red.shade100]
  //                             : isLowStock
  //                                 ? [
  //                                     Colors.orange.shade50,
  //                                     Colors.orange.shade100
  //                                   ]
  //                                 : [
  //                                     Colors.green.shade50,
  //                                     Colors.green.shade100
  //                                   ],
  //                       ),
  //                       borderRadius: BorderRadius.circular(16),
  //                       border: Border.all(
  //                         color: isOutOfStock
  //                             ? Colors.red.shade200
  //                             : isLowStock
  //                                 ? Colors.orange.shade200
  //                                 : Colors.green.shade200,
  //                         width: 1,
  //                       ),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(
  //                           isOutOfStock
  //                               ? Icons.cancel
  //                               : isLowStock
  //                                   ? Icons.warning
  //                                   : Icons.check_circle,
  //                           color: isOutOfStock
  //                               ? Colors.red
  //                               : isLowStock
  //                                   ? Colors.orange
  //                                   : Colors.green,
  //                           size: 32,
  //                         ),
  //                         SizedBox(width: 12),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 isOutOfStock
  //                                     ? 'Нет в наличии'
  //                                     : isLowStock
  //                                         ? 'Заканчивается!'
  //                                         : 'В наличии',
  //                                 style: TextStyle(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: isOutOfStock
  //                                       ? Colors.red.shade700
  //                                       : isLowStock
  //                                           ? Colors.orange.shade700
  //                                           : Colors.green.shade700,
  //                                 ),
  //                               ),
  //                               if (product.maxQuantity != null &&
  //                                   product.maxQuantity! > 0)
  //                                 Text(
  //                                   'Остаток: ${product.maxQuantity} ${product.unit ?? 'шт'}',
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     color: AppColors.textSecondary,
  //                                   ),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   SizedBox(height: 20),

  //                   // Цена и кнопка с градиентом
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             'Цена',
  //                             style: TextStyle(
  //                               fontSize: 14,
  //                               color: AppColors.textSecondary,
  //                             ),
  //                           ),
  //                           ShaderMask(
  //                             shaderCallback: (bounds) =>
  //                                 AppGradients.primary.createShader(bounds),
  //                             child: Text(
  //                               '${product.price.toStringAsFixed(0)} ₽',
  //                               style: TextStyle(
  //                                 fontSize: 28,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       Consumer<CartProvider>(
  //                         builder: (context, cartProvider, child) {
  //                           final quantityInCart =
  //                               cartProvider.getProductQuantity(product.id);

  //                           return quantityInCart > 0
  //                               ? Container(
  //                                   decoration: BoxDecoration(
  //                                     gradient: AppGradients.button,
  //                                     borderRadius: BorderRadius.circular(16),
  //                                     boxShadow: [
  //                                       BoxShadow(
  //                                         color: AppColors.primaryLight
  //                                             .withOpacity(0.3),
  //                                         blurRadius: 10,
  //                                         offset: Offset(0, 5),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   child: Row(
  //                                     children: [
  //                                       IconButton(
  //                                         icon: Icon(Icons.remove,
  //                                             color: Colors.white),
  //                                         onPressed: () => cartProvider
  //                                             .decrementItem(product.id),
  //                                       ),
  //                                       Container(
  //                                         padding: EdgeInsets.symmetric(
  //                                             horizontal: 16),
  //                                         child: Text(
  //                                           '$quantityInCart',
  //                                           style: TextStyle(
  //                                             fontSize: 18,
  //                                             fontWeight: FontWeight.bold,
  //                                             color: Colors.white,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       IconButton(
  //                                         icon: Icon(Icons.add,
  //                                             color: Colors.white),
  //                                         onPressed: () => cartProvider.addItem(
  //                                           productId: product.id,
  //                                           name: product.name,
  //                                           price: product.price,
  //                                           unit: product.unit ?? 'шт',
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 )
  //                               : ElevatedButton(
  //                                   onPressed: isOutOfStock
  //                                       ? null
  //                                       : () => cartProvider.addItem(
  //                                             productId: product.id,
  //                                             name: product.name,
  //                                             price: product.price,
  //                                             unit: product.unit ?? 'шт',
  //                                           ),
  //                                   style: ElevatedButton.styleFrom(
  //                                     backgroundColor:
  //                                         isOutOfStock ? Colors.grey : null,
  //                                     padding: EdgeInsets.zero,
  //                                     shape: RoundedRectangleBorder(
  //                                       borderRadius: BorderRadius.circular(16),
  //                                     ),
  //                                   ),
  //                                   child: Ink(
  //                                     decoration: BoxDecoration(
  //                                       gradient: isOutOfStock
  //                                           ? null
  //                                           : AppGradients.button,
  //                                       borderRadius: BorderRadius.circular(16),
  //                                     ),
  //                                     child: Container(
  //                                       padding: EdgeInsets.symmetric(
  //                                           vertical: 16, horizontal: 24),
  //                                       child: Text(
  //                                         isOutOfStock
  //                                             ? 'Нет в наличии'
  //                                             : 'Добавить в корзину',
  //                                         style: TextStyle(
  //                                           fontSize: 16,
  //                                           fontWeight: FontWeight.w600,
  //                                           color: Colors.white,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 );
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  /// Показать детали товара с улучшенным визуальным оформлением
  void _showProductDetails(BuildContext context, Product product) {
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! <= 5 &&
        product.maxQuantity! > 0;
    final bool isOutOfStock =
        product.maxQuantity != null && product.maxQuantity! <= 0;

    // Добавляем haptic feedback при открытии
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: Duration(milliseconds: 500), // Плавная анимация
        vsync: Navigator.of(context),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(32)), // Увеличен радиус
          boxShadow: [
            // Множественные тени для глубины
            BoxShadow(
              color: AppColors.aurora1.withOpacity(0.1),
              blurRadius: 30,
              offset: Offset(0, -15),
            ),
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 20,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7, // Увеличена начальная высота
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: BouncingScrollPhysics(), // Добавлен эффект отскока
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(24, 12, 24, 32), // Увеличены отступы
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Индикатор для свайпа с градиентом
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: AppGradients.aurora,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.aurora2.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // // Изображение товара с эффектом героя
                    // if (product.imageUrl != null)
                    //   AnimatedContainer(
                    //     duration: Duration(milliseconds: 300),
                    //     height: 250,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(20),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: AppColors.primaryLight.withOpacity(0.2),
                    //           blurRadius: 20,
                    //           offset: Offset(0, 10),
                    //         ),
                    //       ],
                    //     ),
                    //     child: ClipRRect(
                    //       borderRadius: BorderRadius.circular(20),
                    //       child: Stack(
                    //         children: [
                    //           // Изображение
                    //           Image.network(
                    //             product.imageUrl!,
                    //             fit: BoxFit.cover,
                    //             width: double.infinity,
                    //             height: 250,
                    //             errorBuilder: (context, error, stackTrace) =>
                    //                 Container(
                    //               color: AppColors.background,
                    //               child: Icon(
                    //                 Icons.image_not_supported,
                    //                 size: 64,
                    //                 color: AppColors.textSecondary,
                    //               ),
                    //             ),
                    //           ),
                    //           // Градиентная тень снизу для текста
                    //           Positioned(
                    //             bottom: 0,
                    //             left: 0,
                    //             right: 0,
                    //             child: Container(
                    //               height: 100,
                    //               decoration: BoxDecoration(
                    //                 gradient: LinearGradient(
                    //                   begin: Alignment.bottomCenter,
                    //                   end: Alignment.topCenter,
                    //                   colors: [
                    //                     Colors.black.withOpacity(0.6),
                    //                     Colors.transparent,
                    //                   ],
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   )
                    // else
                    //   Container(
                    //     height: 200,
                    //     width: double.infinity,
                    //     decoration: BoxDecoration(
                    //       gradient: LinearGradient(
                    //         begin: Alignment.topLeft,
                    //         end: Alignment.bottomRight,
                    //         colors: [
                    //           AppColors.aurora3.withOpacity(0.1),
                    //           AppColors.aurora1.withOpacity(0.05),
                    //         ],
                    //       ),
                    //       borderRadius: BorderRadius.circular(20),
                    //       border: Border.all(
                    //         color: AppColors.border,
                    //         width: 1,
                    //       ),
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         TweenAnimationBuilder<double>(
                    //           tween: Tween(begin: 0.8, end: 1.0),
                    //           duration: Duration(milliseconds: 800),
                    //           curve: Curves.elasticOut,
                    //           builder: (context, value, child) {
                    //             return Transform.scale(
                    //               scale: value,
                    //               child: Icon(
                    //                 Icons.shopping_bag,
                    //                 size: 64,
                    //                 color: AppColors.aurora2.withOpacity(0.5),
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //         SizedBox(height: 8),
                    //         Text(
                    //           'Фото товара',
                    //           style: TextStyle(
                    //             color: AppColors.textSecondary,
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // SizedBox(height: 24),

                    // Анимированное название товара
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Категория с премиум бейджем
                    if (product.category != null)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 700),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppGradients.aurora,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.aurora1.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                // ← ДОБАВИТЬ Flexible
                                child: Text(
                                  product.category!.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis, // ← ДОБАВИТЬ
                                  maxLines: 1, // ← ДОБАВИТЬ
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 20),

                    // Описание с анимацией появления
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: child,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.aurora,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Описание',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.border.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                product.description!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Премиум информация о наличии с анимацией
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 900),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isOutOfStock
                                ? [
                                    Colors.red.shade50,
                                    Colors.red.shade100.withOpacity(0.7)
                                  ]
                                : isLowStock
                                    ? [
                                        Colors.orange.shade50,
                                        Colors.orange.shade100.withOpacity(0.7)
                                      ]
                                    : [
                                        AppColors.aurora1.withOpacity(0.05),
                                        AppColors.aurora2.withOpacity(0.05)
                                      ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isOutOfStock
                                ? Colors.red.shade300
                                : isLowStock
                                    ? Colors.orange.shade300
                                    : AppColors.aurora1.withOpacity(0.2),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isOutOfStock
                                  ? Colors.red.withOpacity(0.1)
                                  : isLowStock
                                      ? Colors.orange.withOpacity(0.1)
                                      : AppColors.aurora1.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Анимированная иконка статуса
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 2 * 3.14159),
                              duration: Duration(milliseconds: 1500),
                              builder: (context, value, child) {
                                return Transform.rotate(
                                  angle: value,
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isOutOfStock
                                            ? [
                                                Colors.red.shade400,
                                                Colors.red.shade600
                                              ]
                                            : isLowStock
                                                ? [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600
                                                  ]
                                                : [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600
                                                  ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isOutOfStock
                                              ? Colors.red.withOpacity(0.4)
                                              : isLowStock
                                                  ? Colors.orange
                                                      .withOpacity(0.4)
                                                  : Colors.green
                                                      .withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isOutOfStock
                                          ? Icons.remove_shopping_cart
                                          : isLowStock
                                              ? Icons.warning_rounded
                                              : Icons.check_circle,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOutOfStock
                                        ? 'Товар закончился'
                                        : isLowStock
                                            ? 'Осталось мало!'
                                            : 'В наличии',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isOutOfStock
                                          ? Colors.red.shade700
                                          : isLowStock
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (product.maxQuantity != null)
                                    Text(
                                      'Доступно: ${product.maxQuantity} ${product.unit}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Без ограничений',
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
                    ),

                    SizedBox(height: 24),

                    // Цена и кнопка добавления с премиум дизайном
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.surface,
                            AppColors.background,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.3),
                          width: 1,
                        ),
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
                          // Цена с анимацией
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: product.price),
                            duration: Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => AppGradients
                                        .aurora
                                        .createShader(bounds),
                                    child: Text(
                                      '${value.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₽',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '/ ${product.unit}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          // // ✅ ОТЛАДКА:
                          // Container(
                          //   padding: EdgeInsets.all(12),
                          //   margin: EdgeInsets.symmetric(vertical: 12),
                          //   decoration: BoxDecoration(
                          //     color: Colors.yellow.withOpacity(0.3),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text('🔍 DEBUG:',
                          //           style:
                          //               TextStyle(fontWeight: FontWeight.bold)),
                          //       Text('basePrice: ${product.basePrice}'),
                          //       Text('baseUnit: ${product.baseUnit}'),
                          //       Text('inPackage: ${product.inPackage}'),
                          //       Text('price: ${product.price}'),
                          //       Text('unit: ${product.unit}'),
                          //     ],
                          //   ),
                          // ),
                          // ✅ ВСТАВИТЬ СЮДА:
                          if (product.basePrice != null &&
                              product.baseUnit != null) ...[
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primaryLight.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Builder(
                                builder: (context) {
                                  // ✅ Вычисляем basePrice с наценкой
                                  final basePriceWithMargin = product
                                                  .inPackage !=
                                              null &&
                                          product.inPackage! > 0
                                      ? product.price /
                                          product
                                              .inPackage! // price уже с наценкой, делим на количество
                                      : product.basePrice! *
                                          1.15; // если нет inPackage, применяем 25% наценку

                                  return Text(
                                    '${basePriceWithMargin.toStringAsFixed(2)} ₽ / ${product.baseUnit}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDark,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          SizedBox(height: 20),

                          // Кнопка добавления в корзину
                          Consumer<CartProvider>(
                            builder: (context, cart, child) {
                              final quantity =
                                  cart.getProductQuantity(product.id);
                              final inCart = quantity > 0;

                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOutCubic,
                                child: inCart
                                    ? Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: AppGradients.aurora,
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.aurora1
                                                  .withOpacity(0.4),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Кнопка уменьшения
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  cart.decrementItem(
                                                      product.id);
                                                },
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  left: Radius.circular(28),
                                                ),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Количество с анимацией
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 24),
                                              child: AnimatedSwitcher(
                                                duration:
                                                    Duration(milliseconds: 200),
                                                transitionBuilder:
                                                    (child, animation) {
                                                  return ScaleTransition(
                                                    scale: animation,
                                                    child: child,
                                                  );
                                                },
                                                child: Text(
                                                  '$quantity',
                                                  key: ValueKey<int>(quantity),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Кнопка увеличения
                                            Expanded(
                                              child: InkWell(
                                                onTap: hasStock
                                                    ? () {
                                                        HapticFeedback
                                                            .lightImpact();
                                                        cart.incrementItem(
                                                            product.id);
                                                      }
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                  right: Radius.circular(28),
                                                ),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.add,
                                                    color: hasStock
                                                        ? Colors.white
                                                        : Colors.white
                                                            .withOpacity(0.3),
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: hasStock
                                            ? () {
                                                HapticFeedback.mediumImpact();
                                                cart.addProduct(product, 1);
                                                // Показываем снекбар с анимацией
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                            'Добавлено в корзину'),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        AppColors.success,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Container(
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: isOutOfStock
                                                ? LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade400,
                                                      Colors.grey.shade600,
                                                    ],
                                                  )
                                                : AppGradients.button,
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isOutOfStock
                                                    ? Colors.grey
                                                        .withOpacity(0.3)
                                                    : AppColors.primaryLight
                                                        .withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isOutOfStock
                                                      ? Icons
                                                          .remove_shopping_cart
                                                      : Icons
                                                          .shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  isOutOfStock
                                                      ? 'Нет в наличии'
                                                      : 'Добавить в корзину',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              );
                            },
                          ),

                          // Минимальное количество для заказа
                          if (product.minQuantity > 1)
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppColors.info,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Минимальный заказ: ${product.minQuantity} ${product.unit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // // Дополнительная информация
                    // if (product.id != null)
                    //   Container(
                    //     margin: EdgeInsets.only(top: 16),
                    //     padding: EdgeInsets.symmetric(vertical: 8),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.qr_code_2,
                    //           size: 16,
                    //           color: AppColors.textSecondary.withOpacity(0.5),
                    //         ),
                    //         SizedBox(width: 6),
                    //         // Text(
                    //         //   'Артикул: #${product.id.toString().padLeft(6, '0')}',
                    //         //   style: TextStyle(
                    //         //     fontSize: 12,
                    //         //     color: AppColors.textSecondary.withOpacity(0.5),
                    //         //     letterSpacing: 0.5,
                    //         //   ),
                    //         // ),
                    //       ],
                    //     ),
                    //   ),
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

// Исправленный Shimmer виджет с корректными значениями
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
      begin: 0.0,
      end: 1.0,
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
                (_animation.value * 2 - 0.3).clamp(0.0, 1.0),
                (_animation.value * 2).clamp(0.0, 1.0),
                (_animation.value * 2 + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}
