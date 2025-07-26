import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/models/product.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';

class CatalogScreen extends StatelessWidget {
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Гречка 1кг',
      category: 'Крупы',
      approximatePrice: 52.0,
      lastPurchasePrice: 52.0,
      description: 'Гречневая крупа высокого качества',
      isActive: true,
    ),
    Product(
      id: 2,
      name: 'Рис круглый 1кг',
      category: 'Крупы',
      approximatePrice: 48.0,
      lastPurchasePrice: 48.0,
      description: 'Рис круглозерный для плова',
      isActive: true,
    ),
    Product(
      id: 3,
      name: 'Говядина зам. 1кг',
      category: 'Мясо',
      approximatePrice: 420.0,
      lastPurchasePrice: 420.0,
      description: 'Говядина замороженная',
      isActive: true,
    ),
    Product(
      id: 4,
      name: 'Курица зам. 1кг',
      category: 'Мясо',
      approximatePrice: 185.0,
      lastPurchasePrice: 185.0,
      description: 'Курица замороженная',
      isActive: true,
    ),
    Product(
      id: 5,
      name: 'Молоко 3.2% 1л',
      category: 'Молочка',
      approximatePrice: 58.0,
      lastPurchasePrice: 58.0,
      description: 'Молоко пастеризованное',
      isActive: true,
    ),
  ];

  // Функция для расчета экономии
  double getRetailPrice(double optPrice) {
    // Примерно розничная цена в 2.5-3 раза выше оптовой
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
      body: Padding(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final retailPrice = getRetailPrice(product.approximatePrice);
                  final savings =
                      getSavingsPercent(product.approximatePrice, retailPrice);

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.shopping_basket,
                                color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${product.approximatePrice.toInt()}₽',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${retailPrice.toInt()}₽',
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '-${savings}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              print('🔥 Кнопка нажата!');
                              try {
                                final cartProvider = Provider.of<CartProvider>(
                                    context,
                                    listen: false);
                                print('📦 CartProvider получен');
                                print(
                                    '📊 Товаров в корзине ДО добавления: ${cartProvider.itemCount}');

                                cartProvider.addItem(product);

                                print(
                                    '📊 Товаров в корзине ПОСЛЕ добавления: ${cartProvider.itemCount}');
                                print(
                                    '🛒 Список товаров: ${cartProvider.items.map((item) => item.product.name).toList()}');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} добавлен в корзину'),
                                    duration: Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                print('❌ Ошибка: $e');
                              }
                            },
                            icon: Icon(Icons.add_shopping_cart,
                                color: Colors.blue),
                          ),
                        ],
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
}
