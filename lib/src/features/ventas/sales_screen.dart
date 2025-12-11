import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/auth_provider.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  // Fetch sales with product details
  late Future<List<Map<String, dynamic>>> _future;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _future = Future.value([]); // Initialize with empty list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    // Get the effective business_id (respects superadmin impersonation)
    final effectiveBusinessId = ref.read(businessIdProvider);
    if (effectiveBusinessId == null) return;

    // Optimized: only select fields needed for the list
    var query = Supabase.instance.client
        .from('sales')
        .select(
          'id, amount, date, quantity, payment_method, description, product_id, products(name)',
        );

    // Role-based filtering:
    // - Employees see only their own sales (by user_id)
    // - Owners and Superadmin (when impersonating) see all sales in the business (by business_id)
    if (profile.role == 'employee') {
      query = query.eq('user_id', profile.id);
    } else {
      query = query.eq('business_id', effectiveBusinessId);
    }

    if (_selectedDate != null) {
      final start = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final end = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        23,
        59,
        59,
      );
      query = query
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());
    }

    setState(() {
      _future = query.order('date', ascending: false);
    });
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: l10n.locale,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Map<String, String> paymentMethodDisplay = {
      'Efectivo': l10n.paymentMethodCash,
      'Tarjeta': l10n.paymentMethodCard,
      'Transferencia': l10n.paymentMethodTransfer,
      'Otro': l10n.paymentMethodOther,
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.sales),
            if (_selectedDate != null)
              Text(
                DateFormat.yMMMMd(
                  l10n.locale.toString(),
                ).format(_selectedDate!),
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                  _loadData();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.point_of_sale,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSales,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sale = sales[index];
              final amount = sale['amount'];
              final description = sale['description'] ?? l10n.noDescription;
              final dateString = sale['date'] as String;
              final date = DateTime.parse(dateString);
              final formattedDate = DateFormat.yMMMd(
                l10n.locale.toString(),
              ).add_jm().format(date);

              final product = sale['products'];
              final productName = product != null ? product['name'] : null;
              final quantity = sale['quantity'] ?? 1;
              final paymentMethodKey = sale['payment_method'] ?? 'Efectivo';
              final paymentMethod =
                  paymentMethodDisplay[paymentMethodKey] ?? paymentMethodKey;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '€ $amount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Chip(
                        label: Text(
                          paymentMethod,
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (productName != null)
                        Text(
                          '$productName (x$quantity)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text(
                        description,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
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
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await Supabase.instance.client
                                .from('sales')
                                .delete()
                                .eq('id', sale['id']);
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
                                SnackBar(content: Text('${l10n.error}: $e')),
                              );
                            }
                          }
                        }
                      } else if (value == 'edit') {
                        await context.push('/sales/add', extra: sale);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/sales/add');
          setState(() {
            _loadData();
          }); // Refresh list after adding
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newSale),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
    );
  }
}
