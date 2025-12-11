import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../settings/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/auth_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Optimized: only select fields needed for the list
    _future = Supabase.instance.client
        .from('products')
        .select(
          'id, name, stock, price, barcode, category_id, categories(name)',
        )
        .order('name', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).value;
    final isEmployee = profile?.role == 'employee';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.products)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noProducts,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final name = product['name'] as String;
              final stock = product['stock'] as int;
              final price = product['price'];

              final threshold = ref.watch(settingsProvider);
              final isLowStock = stock <= threshold;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.red.withValues(alpha: 0.1)
                          : const Color(0xFFFFA000).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: isLowStock ? Colors.red : const Color(0xFFFFA000),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${l10n.price}: € $price'),
                      if (product['barcode'] != null)
                        Text('${l10n.barcode}: ${product['barcode']}'),
                      if (product['categories'] != null)
                        Text(
                          '${l10n.category}: ${product['categories']['name']}',
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            stock > 0 ? Icons.check_circle : Icons.warning,
                            size: 14,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stock > 0
                                ? '${l10n.stock}: $stock'
                                : '${l10n.stock}: 0',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (isLowStock && stock > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${l10n.lowStock})',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  // Only show edit/delete menu for owners (not employees)
                  trailing: isEmployee
                      ? null
                      : PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.confirmDelete),
                                  content: Text(l10n.deleteMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        l10n.delete,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await Supabase.instance.client
                                      .from('products')
                                      .delete()
                                      .eq('id', product['id']);
                                  if (context.mounted) {
                                    setState(() {
                                      _loadData();
                                    }); // Refresh list
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.success)),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${l10n.error}: $e'),
                                      ),
                                    );
                                  }
                                }
                              }
                            } else if (value == 'edit') {
                              await context.push(
                                '/products/add',
                                extra: product,
                              );
                              setState(() {
                                _loadData();
                              }); // Refresh list after edit
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.delete),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
      // Only show FAB for owners (not employees)
      floatingActionButton: isEmployee
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/products/add');
                setState(() {
                  _loadData();
                }); // Refresh list after adding
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.newProduct),
              backgroundColor: const Color(0xFFFFA000),
              foregroundColor: Colors.white,
            ),
    );
  }
}
