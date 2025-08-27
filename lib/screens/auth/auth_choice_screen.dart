import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Логотип и заголовок
                Icon(
                  Icons.shopping_cart,
                  size: 100,
                  color: Colors.blue,
                ),
                SizedBox(height: 24),
                Text(
                  'Северная корзина',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Коллективные закупки в Усть-Нере',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Экономьте до 50% на товарах первой необходимости',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 32),

                // Информационные карточки
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: Colors.green, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Экономия до 70%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Оптовые цены для всех',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                // Container(
                //   padding: EdgeInsets.all(14),
                //   decoration: BoxDecoration(
                //     color: Colors.blue[50],
                //     borderRadius: BorderRadius.circular(12),
                //     border: Border.all(color: Colors.blue[200]!),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(Icons.local_shipping, color: Colors.blue, size: 28),
                //       SizedBox(width: 12),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Доставка из Якутска и Магадана',
                //               style: TextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.blue[800],
                //                 fontSize: 14,
                //               ),
                //             ),
                //             Text(
                //               'Качественные товары',
                //               style: TextStyle(
                //                 color: Colors.blue[700],
                //                 fontSize: 13,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 32),

                // Кнопки входа и регистрации
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Войти',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Зарегистрироваться',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('О проекте'),
                        content: Text(
                          'Северная корзина - это платформа коллективных закупок для жителей Усть-Неры.\n\n'
                          'Мы объединяем заказы жителей и закупаем товары оптом, что позволяет получить значительные скидки.\n\n'
                          'Оплата производится полностью при оформлении заказа.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Понятно'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Узнать больше о проекте',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
