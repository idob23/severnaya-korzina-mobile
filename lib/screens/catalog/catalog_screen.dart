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
                      // TODO: Переход в корзину
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Переход в корзину - в разработке')),
                      );
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

                  if (productsProvider.error != null) {
                    return Center(
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
                        ],
                      ),
                    );
                  }

                  final products = productsProvider.filteredProducts;

                  if (products.isEmpty) {
                    return Center(
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
                                : 'Товары пока не загружены',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (productsProvider.hasActiveFilters) ...[
                            SizedBox(height: 8),
                            Text(
                              'Попробуйте изменить критерии поиска',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                productsProvider.clearFilters();
                              },
                              child: Text('Сбросить фильтры'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product);
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

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Изображение товара
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                color: Colors.grey[100],
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
          ),

          // Информация о товаре
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),

                  Spacer(),

                  // Цена и кнопка
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'за ${product.unit}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return IconButton(
                            onPressed: () {
                              cartProvider.addItem(
                                productId: product.id,
                                name: product.name,
                                price: product.price,
                                unit: product.unit,
                                quantity: product.minQuantity,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.name} добавлен в корзину'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(Icons.add_shopping_cart),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              foregroundColor: Colors.blue[700],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(String productName) {
    return Container(
      color: Colors.blue[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.blue[300],
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              productName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
