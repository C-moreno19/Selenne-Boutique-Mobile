import 'package:flutter/material.dart';
import '../../core/services/favorites_service.dart';
import '../../core/utils/adaptive_image.dart';
import '../routes/app_routes.dart';
import '../../core/constants/app_colors.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final favs = await FavoritesService.getFavorites();
    setState(() {
      _favorites = favs;
      _loading = false;
    });
  }

  Widget _buildCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail,
          arguments: product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AdaptiveImage(
                  src: product['image'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Text(product['name'] ?? '',
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await FavoritesService.removeFavorite(product);
                      await _load();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('No tienes favoritos todavía'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, i) => _buildCard(_favorites[i]),
                ),
    );
  }
}
