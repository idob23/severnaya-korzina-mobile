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
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemsCount = cartProvider.totalItems;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Переходим на вкладку корзины
                      DefaultTabController.of(context)?.animateTo(1);
                    },
                  ),
                  if (itemsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemsCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
                    '🚚 Экономия до 70% от розничных цен!',
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

  /// Виджет карточки товара
  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showProductDetails(context, product),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение товара
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.hasImage
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(product.name);
                          },
                        )
                      : _buildPlaceholderImage(product.name),
                ),
              ),

              SizedBox(width: 16),

              // Информация о товаре
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название товара
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              'за ${product.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, size: 20),
                                      onPressed: () {
                                        cartProvider.updateProductQuantity(
                                            product.id, quantityInCart - 1);
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
                                      onPressed: () {
                                        if (product.maxQuantity == null ||
                                            quantityInCart <
                                                product.maxQuantity!) {
                                          cartProvider.updateProductQuantity(
                                              product.id, quantityInCart + 1);
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
                                onPressed: () {
                                  cartProvider.addProduct(
                                      product, product.minQuantity);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} добавлен в корзину'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.add_shopping_cart, size: 18),
                                label: Text('В корзину'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
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

  /// Показать детали товара
  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Содержимое
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Изображение
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: product.hasImage
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage(product.name);
                                },
                              )
                            : _buildPlaceholderImage(product.name),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Цена
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'за ${product.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

                    // Минимальное количество
                    Text(
                      'Минимальный заказ: ${product.minQuantity} ${product.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    if (product.maxQuantity != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Максимальный заказ: ${product.maxQuantity} ${product.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Кнопка добавления в корзину
            Container(
              padding: EdgeInsets.all(20),
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cartProvider.addProduct(product, product.minQuantity);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} добавлен в корзину'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Добавить в корзину',
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
