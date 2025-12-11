import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/auth_provider.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
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
        .from('expenses')
        .select(
          'id, amount, date, quantity, payment_method, description, photo_url, product_id, products(name)',
        );

    // Role-based filtering:
    // - Employees see only their own expenses (by user_id)
    // - Owners and Superadmin (when impersonating) see all expenses in the business (by business_id)
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
    final now = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = now.add(const Duration(days: 365));
    final l10n = AppLocalizations.of(context);

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

  Future<void> _launchURL(String url) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.expenses),
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
          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noExpenses,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final amount = expense['amount'];
              final description = expense['description'] ?? 'Sin descripción';
              final dateString = expense['date'] as String;
              final date = DateTime.parse(dateString);
              final formattedDate = DateFormat.yMMMd(
                l10n.locale.toString(),
              ).add_jm().format(date);

              final product = expense['products'];
              final productName = product != null ? product['name'] : null;
              final quantity = expense['quantity'] ?? 1;
              final paymentMethod = expense['payment_method'] ?? 'Efectivo';
              final photoUrl = expense['photo_url'];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF5252,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '€ $amount',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            paymentMethod,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Colors.grey,
                                          ),
                                          onSelected: (value) async {
                                            if (value == 'delete') {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text(
                                                        l10n.confirmDelete,
                                                      ),
                                                      content: Text(
                                                        l10n.deleteMessage,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: Text(
                                                            l10n.cancel,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: Text(
                                                            l10n.delete,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await Supabase.instance.client
                                                      .from('expenses')
                                                      .delete()
                                                      .eq('id', expense['id']);
                                                  if (context.mounted) {
                                                    setState(() {
                                                      _loadData();
                                                    }); // Refresh list
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          l10n.success,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${l10n.error}: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            } else if (value == 'edit') {
                                              await context.push(
                                                '/expenses/add',
                                                extra: expense,
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
                                      ],
                                    ),
                                  ],
                                ),
                                if (productName != null)
                                  Text(
                                    '$productName (x$quantity)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                if (expense['type'] != null)
                                  Text(
                                    '${l10n.type}: ${expense['type']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                if (expense['provider'] != null)
                                  Text(
                                    '${l10n.provider}: ${expense['provider']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (photoUrl != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Image.network(
                                          photoUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: const Icon(Icons.close),
                                            label: Text(l10n.close),
                                          ),
                                          FilledButton.icon(
                                            onPressed: () {
                                              _launchURL(photoUrl);
                                            },
                                            icon: const Icon(Icons.download),
                                            label: Text(l10n.download),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  photoUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.photoSelected,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
          await context.push('/expenses/add');
          setState(() {
            _loadData();
          }); // Refresh list after adding
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newExpense),
        backgroundColor: const Color(0xFFFF5252),
        foregroundColor: Colors.white,
      ),
    );
  }
}
