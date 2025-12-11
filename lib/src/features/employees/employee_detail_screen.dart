import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

enum StatsFilter { general, month, week, day }

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  bool _isLoading = true;
  double _totalSales = 0.0;
  double _totalExpenses = 0.0;
  int _salesCount = 0;
  int _expensesCount = 0;
  List<Map<String, dynamic>> _recentSales = [];
  List<Map<String, dynamic>> _recentExpenses = [];

  // Filter state
  StatsFilter _currentFilter = StatsFilter.general;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  void _updateDate(int offset) {
    setState(() {
      if (_currentFilter == StatsFilter.month) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + offset,
          1,
        );
      } else if (_currentFilter == StatsFilter.week) {
        _selectedDate = _selectedDate.add(Duration(days: 7 * offset));
      } else if (_currentFilter == StatsFilter.day) {
        _selectedDate = _selectedDate.add(Duration(days: offset));
      }
    });
    _loadEmployeeData();
  }

  String _getDateLabel(AppLocalizations l10n) {
    final localeStr = l10n.locale.toString();
    if (_currentFilter == StatsFilter.month) {
      return DateFormat(
        'MMMM yyyy',
        localeStr,
      ).format(_selectedDate).toUpperCase();
    } else if (_currentFilter == StatsFilter.week) {
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1),
      );
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('d MMM', localeStr).format(startOfWeek)} - ${DateFormat('d MMM', localeStr).format(endOfWeek)}';
    } else if (_currentFilter == StatsFilter.day) {
      return DateFormat(
        'EEEE d MMMM',
        localeStr,
      ).format(_selectedDate).toUpperCase();
    }
    return '';
  }

  Future<void> _loadEmployeeData() async {
    setState(() => _isLoading = true);

    try {
      final employeeId = widget.employee['id'];

      // Build date filters
      DateTime? start;
      DateTime? end;

      if (_currentFilter != StatsFilter.general) {
        final now = _selectedDate;

        if (_currentFilter == StatsFilter.month) {
          start = DateTime(now.year, now.month, 1);
          end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        } else if (_currentFilter == StatsFilter.week) {
          start = now.subtract(Duration(days: now.weekday - 1));
          start = DateTime(start.year, start.month, start.day);
          end = start
              .add(const Duration(days: 6))
              .add(const Duration(hours: 23, minutes: 59, seconds: 59));
        } else if (_currentFilter == StatsFilter.day) {
          start = DateTime(now.year, now.month, now.day);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        }
      }

      // Fetch sales for this employee (optimized: only needed fields)
      var salesQuery = Supabase.instance.client
          .from('sales')
          .select('id, amount, date, description, product_id, products(name)')
          .eq('user_id', employeeId);

      if (start != null && end != null) {
        salesQuery = salesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());
      }

      final salesResponse = await salesQuery.order('date', ascending: false);

      // Fetch expenses for this employee (optimized: only needed fields)
      var expensesQuery = Supabase.instance.client
          .from('expenses')
          .select('id, amount, date, description, product_id, products(name)')
          .eq('user_id', employeeId);

      if (start != null && end != null) {
        expensesQuery = expensesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());
      }

      final expensesResponse = await expensesQuery.order(
        'date',
        ascending: false,
      );

      double totalSales = 0.0;
      for (var sale in salesResponse) {
        totalSales += (sale['amount'] as num).toDouble();
      }

      double totalExpenses = 0.0;
      for (var expense in expensesResponse) {
        totalExpenses += (expense['amount'] as num).toDouble();
      }

      if (mounted) {
        setState(() {
          _totalSales = totalSales;
          _totalExpenses = totalExpenses;
          _salesCount = salesResponse.length;
          _expensesCount = expensesResponse.length;
          _recentSales = List<Map<String, dynamic>>.from(
            salesResponse.take(5).toList(),
          );
          _recentExpenses = List<Map<String, dynamic>>.from(
            expensesResponse.take(5).toList(),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading employee data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFilterChip(String label, StatsFilter filter) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
          _selectedDate = DateTime.now();
        });
        _loadEmployeeData();
      },
      selectedColor: const Color(0xFF1A237E).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF1A237E),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1A237E) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final employee = widget.employee;
    final name = employee['full_name'] ?? l10n.noName;
    final phone = employee['phone'] ?? '';
    final balance = _totalSales - _totalExpenses;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEmployeeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF1A237E),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  if (phone.isNotEmpty)
                                    Text(
                                      phone,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(l10n.general, StatsFilter.general),
                          const SizedBox(width: 8),
                          _buildFilterChip(l10n.monthly, StatsFilter.month),
                          const SizedBox(width: 8),
                          _buildFilterChip(l10n.weekly, StatsFilter.week),
                          const SizedBox(width: 8),
                          _buildFilterChip(l10n.daily, StatsFilter.day),
                        ],
                      ),
                    ),

                    // Date Navigation (if not general)
                    if (_currentFilter != StatsFilter.general) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _updateDate(-1),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  locale: l10n.locale,
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                  _loadEmployeeData();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF1A237E,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF1A237E),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _getDateLabel(l10n),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _updateDate(1),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.sales,
                            '€ ${_totalSales.toStringAsFixed(2)}',
                            '$_salesCount ${l10n.records}',
                            Colors.green,
                            Icons.arrow_upward,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.expenses,
                            '€ ${_totalExpenses.toStringAsFixed(2)}',
                            '$_expensesCount ${l10n.records}',
                            Colors.red,
                            Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Balance Card
                    Card(
                      color: balance >= 0
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.netProfit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '€ ${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: balance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Sales
                    if (_recentSales.isNotEmpty) ...[
                      Text(
                        l10n.recentSales,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._recentSales.map(
                        (sale) => _buildTransactionTile(
                          sale,
                          isExpense: false,
                          l10n: l10n,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Recent Expenses
                    if (_recentExpenses.isNotEmpty) ...[
                      Text(
                        l10n.recentExpenses,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._recentExpenses.map(
                        (expense) => _buildTransactionTile(
                          expense,
                          isExpense: true,
                          l10n: l10n,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    Map<String, dynamic> transaction, {
    required bool isExpense,
    required AppLocalizations l10n,
  }) {
    final amount = transaction['amount'];
    final date = DateTime.parse(transaction['date']);
    final formattedDate = DateFormat.yMMMd(l10n.locale.toString()).format(date);
    final product = transaction['products'];
    final productName = product != null ? product['name'] : null;
    final description =
        productName ??
        transaction['description'] ??
        (isExpense ? l10n.expenses : l10n.sales);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isExpense ? Colors.red : Colors.green).withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
            color: isExpense ? Colors.red : Colors.green,
            size: 20,
          ),
        ),
        title: Text(
          '€ $amount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          formattedDate,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }
}
