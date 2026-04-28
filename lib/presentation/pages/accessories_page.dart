import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/adaptive_image.dart';
import '../routes/app_routes.dart';

class AccessoriesPage extends StatelessWidget {
  const AccessoriesPage({super.key});

  String _formatPrice(int price) {
    return '\$${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Sombrero de ala ancha',
        'price': 45990,
        'image': 'assets/images/products/accesorios/sombrero_ala_ancha.png'
      },
      {
        'name': 'Bufanda de seda estampada',
        'price': 38990,
        'image': 'assets/images/products/accesorios/bufanda_seda_estampada.png'
      },
      {
        'name': 'Bolso de cuero marrón',
        'price': 125990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
      {
        'name': 'Gafas de sol aviador',
        'price': 89990,
        'image': 'assets/images/products/accesorios/gafas_sol.png'
      },
      {
        'name': 'Cinturón de cuero',
        'price': 52990,
        'image': 'assets/images/products/accesorios/cinturon_cuero_hebilla.png'
      },
      {
        'name': 'Reloj elegante dorado',
        'price': 198990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
      {
        'name': 'Pulsera de oro minimalista',
        'price': 75990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
      {
        'name': 'Collar de perlas',
        'price': 145990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
      {
        'name': 'Aretes de plata',
        'price': 68990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
      {
        'name': 'Cartera pequeña negra',
        'price': 95990,
        'image': 'assets/images/products/accesorios/bolso_cuero.png'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Accesorios',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filtros',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      ListTile(
                        leading: const Icon(Icons.sort),
                        title: const Text('Ordenar por precio'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.filter_list),
                        title: const Text('Filtrar por talla'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: const Text('Filtrar por color'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) =>
            _buildProductCard(context, products[index]),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.productDetail,
            arguments: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AdaptiveImage(
                        src: product['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Botón Ver Detalle
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.productDetail,
                            arguments: product);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4)
                          ],
                        ),
                        child: const Text(
                          'Ver Detalle',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'],
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 2),
                  const SizedBox(height: 6),
                  Text(_formatPrice(product['price']),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 2) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (route) => false);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined), label: 'Categorías'),
        BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined), label: 'Búsqueda'),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined), label: 'Bolsa'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }
}
