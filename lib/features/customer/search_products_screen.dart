import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import 'product_list_screen.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().fetchProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: isWide ? 72 : 64,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: _SearchField(
                controller: _searchController,
                isWide: isWide,
                onChanged: (value) {
                  context.read<ProductProvider>().searchProducts(value);
                  setState(() {});
                },
                onClear: () {
                  _searchController.clear();
                  context.read<ProductProvider>().searchProducts('');
                  setState(() {});
                },
                onSubmitted: (value) {
                  _addRecentSearch(value);
                },
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final query = _searchController.text.trim();
          final suggestions = query.isEmpty
              ? const <String>[]
              : productProvider.allProducts
                    .where(
                      (p) => p.name.toLowerCase().contains(query.toLowerCase()),
                    )
                    .map((p) => p.name)
                    .toSet()
                    .take(6)
                    .toList();

          if (productProvider.filteredProducts.isEmpty) {
            return Center(
              child: Text(
                query.isEmpty ? 'Start typing to search' : 'No products found',
              ),
            );
          }

          return Column(
            children: [
              if (query.isEmpty && _recentSearches.isNotEmpty)
                _RecentSearches(
                  searches: _recentSearches,
                  onTap: (value) {
                    _searchController.text = value;
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    );
                    context.read<ProductProvider>().searchProducts(value);
                    setState(() {});
                  },
                )
              else if (suggestions.isNotEmpty)
                _Suggestions(
                  suggestions: suggestions,
                  onTap: (value) {
                    _searchController.text = value;
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    );
                    context.read<ProductProvider>().searchProducts(value);
                    _addRecentSearch(value);
                    setState(() {});
                  },
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.filteredProducts[index];
                    return ProductCard(product: product);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addRecentSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 6) {
        _recentSearches.removeLast();
      }
    });
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isWide;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  const _SearchField({
    required this.controller,
    required this.isWide,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(isWide ? 14 : 999);

    return Container(
      height: isWide ? 52 : 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'I am searching for...',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
        ],
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;

  const _RecentSearches({required this.searches, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: searches
            .map(
              (value) =>
                  ActionChip(label: Text(value), onPressed: () => onTap(value)),
            )
            .toList(),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _Suggestions({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions
            .map(
              (value) =>
                  InputChip(label: Text(value), onPressed: () => onTap(value)),
            )
            .toList(),
      ),
    );
  }
}
