import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/models/product.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart'; // НОВЫЙ

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();

    // ЗАГРУЖАЕМ ДАННЫЕ С СЕРВЕРА
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      productsProvider.loadProducts();
      productsProvider.loadCategories();
    });
  }

  // Функция для расчета экономии
  double getRetailPrice(double optPrice) {
    return optPrice * 2.8;
  }

  int getSavingsPercent(double optPrice, double retailPrice) {
    return ((retailPrice - optPrice) / retailPrice * 100).round();
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '💰 Цены указаны за коллективную закупку\n🚚 Экономия до 70% от розничных цен!',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // СОДЕРЖИМОЕ ЗАГРУЖАЕТСЯ С СЕРВЕРА
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
                                productsProvider.loadProducts();
                              },
                              child: Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!productsProvider.hasProducts) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Товары не найдены',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Попробуйте обновить список'),
                          ],
                        ),
                      );
                    }

                    // ОТОБРАЖАЕМ РЕАЛЬНЫЕ ТОВАРЫ С СЕРВЕРА
                    return ListView.builder(
                      itemCount: productsProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = productsProvider.products[index];
                        return _buildProductCard(product, context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    final double price = double.tryParse(product['price'].toString()) ?? 0.0;
    final double retailPrice = getRetailPrice(price);
    final int savingsPercent = getSavingsPercent(price, retailPrice);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Изображение товара (заглушка)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(width: 16),

            // Информация о товаре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Неизвестный товар',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Цены и экономия
                  Row(
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${retailPrice.toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Экономия $savingsPercent%',
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

            // Кнопка добавления в корзину
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return ElevatedButton(
                  onPressed: () {
                    // Преобразуем Map в объект для корзины
                    final cartItem = {
                      'id': product['id'],
                      'name': product['name'],
                      'price': price,
                      'unit': product['unit'] ?? 'шт',
                      'quantity': 1,
                    };

                    cartProvider.addItem(cartItem as Product);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product['name']} добавлен в корзину'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('В корзину'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
