// lib/screens/catalog/catalog_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Каталог товаров'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final productsProvider =
              Provider.of<ProductsProvider>(context, listen: false);
          await productsProvider.refresh();
        },
        child: Column(
          children: [
            // Информационный баннер
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '💰 Цены за коллективную закупку',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '🚚 Экономия до 50% от розничных цен!',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Поиск и фильтры
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Поисковая строка
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск товаров...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                final productsProvider =
                                    Provider.of<ProductsProvider>(context,
                                        listen: false);
                                productsProvider.clearSearch();
                                productsProvider.loadProducts();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (query) {
                      final productsProvider =
                          Provider.of<ProductsProvider>(context, listen: false);
                      productsProvider.searchProducts(query);
                    },
                  ),
                  SizedBox(height: 16),

                  // Категории
                  Consumer<ProductsProvider>(
                    builder: (context, productsProvider, child) {
                      if (productsProvider.categories.isEmpty) {
                        return SizedBox.shrink();
                      }

                      return SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategoryChip(
                              'Все',
                              productsProvider.selectedCategoryId == null,
                              () => productsProvider.filterByCategory(null),
                            ),
                            ...productsProvider.categories.map(
                              (category) => _buildCategoryChip(
                                category.name,
                                productsProvider.selectedCategoryId ==
                                    category.id,
                                () => productsProvider
                                    .filterByCategory(category.id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Список товаров
            Expanded(
              child: Consumer<ProductsProvider>(
                builder: (context, productsProvider, child) {
                  // Отображение загрузки
                  if (productsProvider.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загружаем товары...'),
                        ],
                      ),
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
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Ошибка загрузки товаров',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              productsProvider.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                productsProvider.clearError();
                                productsProvider.loadProducts();
                              },
                              child: Text('Повторить'),
                            ),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                // Показываем подробную информацию об ошибке
                                _showErrorDetails(
                                    context, productsProvider.error!);
                              },
                              child: Text('Подробнее'),
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
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
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
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              productsProvider.hasSearchQuery ||
                                      productsProvider.hasSelectedCategory
                                  ? 'Попробуйте изменить условия поиска'
                                  : 'Товары пока не добавлены',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            if (productsProvider.hasSearchQuery ||
                                productsProvider.hasSelectedCategory)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      productsProvider.clearFilters(),
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

  /// Виджет чипа категории
  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// Виджет карточки товара с отображением остатков
  Widget _buildProductCard(BuildContext context, Product product) {
    // Определяем статус остатков
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! <= 5 &&
        product.maxQuantity! > 0;
    final bool isOutOfStock =
        product.maxQuantity != null && product.maxQuantity! == 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Подсветка карточки если товара нет
      color: isOutOfStock ? Colors.red[50] : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasStock ? () => _showProductDetails(context, product) : null,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 16),

              // Информация о товаре
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название товара с бейджем остатка
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock ? Colors.grey : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Бейдж остатка
                        if (product.maxQuantity != null)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.red
                                  : isLowStock
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? 'НЕТ'
                                  : product.maxQuantity.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Категория
                    if (product.category != null)
                      Text(
                        product.category!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    SizedBox(height: 8),

                    // Описание
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isOutOfStock
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Предупреждение о низких остатках
                    if (isLowStock)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning,
                                size: 12, color: Colors.orange[700]),
                            SizedBox(width: 4),
                            Text(
                              'Спешите! Осталось мало',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Сообщение если товара нет
                    if (isOutOfStock)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cancel,
                                size: 12, color: Colors.red[700]),
                            SizedBox(width: 4),
                            Text(
                              'Временно нет в наличии',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 12),

                    // Цена и кнопка добавления
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock
                                    ? Colors.grey
                                    : Colors.green[700],
                              ),
                            ),
                            Text(
                              'за ${product.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            // Показываем доступное количество
                            if (product.maxQuantity != null && !isOutOfStock)
                              Text(
                                'Доступно: ${product.maxQuantity} ${product.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLowStock
                                      ? Colors.orange
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),

                        // Кнопка добавления в корзину
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            final quantityInCart =
                                cartProvider.getProductQuantity(product.id);

                            if (quantityInCart > 0) {
                              // Если товар уже в корзине, показываем счетчик
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isOutOfStock
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, size: 20),
                                      onPressed: isOutOfStock
                                          ? null
                                          : () {
                                              cartProvider
                                                  .updateProductQuantity(
                                                      product.id,
                                                      quantityInCart - 1);
                                            },
                                      constraints: BoxConstraints.tightFor(
                                          width: 32, height: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$quantityInCart',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, size: 20),
                                      onPressed: (isOutOfStock ||
                                              (product.maxQuantity != null &&
                                                  quantityInCart >=
                                                      product.maxQuantity!))
                                          ? null
                                          : () {
                                              // Проверяем, не превышаем ли доступное количество
                                              if (product.maxQuantity == null ||
                                                  quantityInCart <
                                                      product.maxQuantity!) {
                                                cartProvider
                                                    .updateProductQuantity(
                                                        product.id,
                                                        quantityInCart + 1);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Достигнут максимум: ${product.maxQuantity} ${product.unit}'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                            },
                                      constraints: BoxConstraints.tightFor(
                                          width: 32, height: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Если товара нет в корзине, показываем кнопку добавления
                              return ElevatedButton.icon(
                                onPressed: isOutOfStock
                                    ? null
                                    : () {
                                        cartProvider.addProduct(
                                            product, product.minQuantity);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${product.name} добавлен в корзину'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                icon: Icon(
                                    isOutOfStock
                                        ? Icons.cancel
                                        : Icons.add_shopping_cart,
                                    size: 18),
                                label: Text(isOutOfStock ? 'Нет' : 'В корзину'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isOutOfStock ? Colors.grey : Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Плейсхолдер изображения
  Widget _buildPlaceholderImage(String productName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              color: Colors.blue[300],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              productName.length > 10
                  ? '${productName.substring(0, 10)}...'
                  : productName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Показать детали товара с информацией об остатках
  void _showProductDetails(BuildContext context, Product product) {
    final bool hasStock =
        product.maxQuantity == null || product.maxQuantity! > 0;
    final bool isLowStock = product.maxQuantity != null &&
        product.maxQuantity! <= 5 &&
        product.maxQuantity! > 0;
    final bool isOutOfStock =
        product.maxQuantity != null && product.maxQuantity! == 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Шапка с изображением и статусом остатка
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  // Кнопка закрытия
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  // Бейдж остатка
                  if (product.maxQuantity != null)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.red
                              : isLowStock
                                  ? Colors.orange
                                  : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isOutOfStock
                                  ? Icons.cancel
                                  : isLowStock
                                      ? Icons.warning
                                      : Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isOutOfStock
                                  ? 'Нет в наличии'
                                  : isLowStock
                                      ? 'Осталось: ${product.maxQuantity}'
                                      : 'В наличии: ${product.maxQuantity}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Информация о товаре
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название и цена
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.maxQuantity != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'Доступно: ${product.maxQuantity} ${product.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isLowStock
                                    ? Colors.orange
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Предупреждение о низких остатках
                    if (isLowStock)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.orange[700], size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Спешите! Товар заканчивается. Осталось всего ${product.maxQuantity} ${product.unit}',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Сообщение если товара нет
                    if (isOutOfStock)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red[700], size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'К сожалению, товар временно отсутствует. Попробуйте заказать позже.',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Категория
                    if (product.category != null) ...[
                      Text(
                        'Категория',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        product.category!.name,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Описание
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      Text(
                        'Описание',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        product.description!,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Минимальное и максимальное количество
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Минимальный заказ:'),
                              Text(
                                '${product.minQuantity} ${product.unit}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (product.maxQuantity != null) ...[
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Максимальный заказ:'),
                                Text(
                                  '${product.maxQuantity} ${product.unit}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLowStock ? Colors.orange : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка добавления в корзину
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final quantityInCart =
                      cartProvider.getProductQuantity(product.id);

                  return SizedBox(
                    width: double.infinity,
                    child: quantityInCart > 0
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'В корзине: $quantityInCart ${product.unit}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: isOutOfStock ||
                                        (product.maxQuantity != null &&
                                            quantityInCart >=
                                                product.maxQuantity!)
                                    ? null
                                    : () {
                                        cartProvider.updateProductQuantity(
                                            product.id, quantityInCart + 1);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Количество обновлено'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Добавить еще',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: isOutOfStock
                                ? null
                                : () {
                                    cartProvider.addProduct(
                                        product, product.minQuantity);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${product.name} добавлен в корзину'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isOutOfStock ? Colors.grey : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? 'Нет в наличии'
                                  : 'Добавить в корзину',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Показать детали ошибки
  void _showErrorDetails(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
