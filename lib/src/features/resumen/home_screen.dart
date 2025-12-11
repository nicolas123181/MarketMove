import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart' hide Border;
import '../../shared/utils/file_saver.dart';
import '../../shared/providers/auth_provider.dart';
import '../settings/providers/settings_provider.dart';
import '../admin/providers/admin_provider.dart';
import '../../l10n/app_localizations.dart';

enum StatsFilter { general, month, week, day }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isExporting = false; // Prevent duplicate exports
  DateTime? _lastExportTime; // Debounce timestamp
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  int _lowStockCount = 0;

  StatsFilter _currentFilter = StatsFilter.general;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _checkAndLoadData();
    }
  }

  void _checkAndLoadData() {
    final profile = ref.read(profileProvider).value;
    final businessId = ref.read(businessIdProvider);
    if (businessId != null && profile != null) {
      _loadDashboardData(businessId, userId: profile.id, role: profile.role);
    }
  }

  void _updateDate(int offset) {
    setState(() {
      if (_currentFilter == StatsFilter.month) {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + offset,
          _selectedDate.day,
        );
      } else if (_currentFilter == StatsFilter.week) {
        _selectedDate = _selectedDate.add(Duration(days: offset * 7));
      } else if (_currentFilter == StatsFilter.day) {
        _selectedDate = _selectedDate.add(Duration(days: offset));
      }
      _isLoading = true;
    });
    _checkAndLoadData();
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDate = DateTime(2020);
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: l10n.locale,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      _checkAndLoadData();
    }
  }

  String _getDateRangeLabel() {
    final l10n = AppLocalizations.of(context);
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

  Future<void> _loadDashboardData(
    String businessId, {
    String? userId,
    String? role,
  }) async {
    try {
      var salesQuery = Supabase.instance.client
          .from('sales')
          .select('amount, date');

      var expensesQuery = Supabase.instance.client
          .from('expenses')
          .select('amount, date');

      // Role-based filtering:
      // - Employees see only their own data (by user_id)
      // - Owners see all data in their business (by business_id)
      if (role == 'employee' && userId != null) {
        salesQuery = salesQuery.eq('user_id', userId);
        expensesQuery = expensesQuery.eq('user_id', userId);
      } else {
        salesQuery = salesQuery.eq('business_id', businessId);
        expensesQuery = expensesQuery.eq('business_id', businessId);
      }

      if (_currentFilter != StatsFilter.general) {
        DateTime start, end;
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
        } else {
          // Day
          start = DateTime(now.year, now.month, now.day);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        }

        salesQuery = salesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());

        expensesQuery = expensesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());
      }

      final salesResponse = await salesQuery;
      double income = 0.0;
      for (var sale in salesResponse) {
        income += (sale['amount'] as num).toDouble();
      }

      final expensesResponse = await expensesQuery;
      double expenses = 0.0;
      for (var expense in expensesResponse) {
        expenses += (expense['amount'] as num).toDouble();
      }

      // Fetch Low Stock Products (always by business_id - shared products)
      final threshold = ref.read(settingsProvider);
      final productsResponse = await Supabase.instance.client
          .from('products')
          .select('stock')
          .eq('business_id', businessId)
          .lte('stock', threshold);

      final lowStock = productsResponse.length;

      if (mounted) {
        setState(() {
          _totalIncome = income;
          _totalExpenses = expenses;
          _lowStockCount = lowStock;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportToExcel() async {
    // Prevent duplicate exports with debounce
    final now = DateTime.now();
    if (_isExporting) return;
    if (_lastExportTime != null &&
        now.difference(_lastExportTime!).inSeconds < 5) {
      debugPrint('Export debounced - too soon after last export');
      return;
    }
    _isExporting = true;
    _lastExportTime = now;

    final l10n = AppLocalizations.of(context);
    final localeStr = l10n.locale.toString();
    try {
      final profile = ref.read(profileProvider).value;
      if (profile == null) {
        _isExporting = false;
        return;
      }
      final businessId = profile.businessId;

      // 1. Create Excel
      var excel = Excel.createExcel();

      // 2. Determine Date Range and Filename
      DateTime start, end;
      String periodLabel;
      final now = _selectedDate;

      if (_currentFilter == StatsFilter.month) {
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        periodLabel =
            'Mensual_${DateFormat('MMMM_yyyy', localeStr).format(now)}';
      } else if (_currentFilter == StatsFilter.week) {
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        end = start
            .add(const Duration(days: 6))
            .add(const Duration(hours: 23, minutes: 59, seconds: 59));
        periodLabel =
            'Semanal_${DateFormat('dd_MMM', localeStr).format(start)}-${DateFormat('dd_MMM', localeStr).format(end)}';
      } else if (_currentFilter == StatsFilter.day) {
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        periodLabel =
            'Diario_${DateFormat('dd_MM_yyyy', localeStr).format(now)}';
      } else {
        // General (All time) - Set a wide range or handle differently
        start = DateTime(2020); // Arbitrary start
        end = DateTime.now().add(const Duration(days: 1));
        periodLabel =
            'General_${DateFormat('dd_MM_yyyy', localeStr).format(now)}';
      }

      // 3. Sheet: Ventas
      Sheet sheetSales = excel[l10n.sales];
      sheetSales.appendRow([
        TextCellValue(l10n.date),
        TextCellValue(l10n.products),
        TextCellValue(l10n.quantity),
        TextCellValue(l10n.amount),
        TextCellValue(l10n.paymentMethod),
      ]);

      // Role-based filtering: employees see only their data, owners see all business data
      var salesQuery = Supabase.instance.client
          .from('sales')
          .select('*, products(name)');

      if (profile.role == 'employee') {
        // Employee: only their own sales
        salesQuery = salesQuery.eq('user_id', profile.id);
      } else {
        // Owner/Superadmin: all business sales
        salesQuery = salesQuery.eq('business_id', businessId);
      }

      if (_currentFilter != StatsFilter.general) {
        salesQuery = salesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());
      }

      final salesData = await salesQuery.order('date', ascending: false);

      for (var sale in salesData) {
        sheetSales.appendRow([
          TextCellValue(sale['date'] ?? ''),
          TextCellValue(sale['products']?['name'] ?? 'Desconocido'),
          IntCellValue(sale['quantity'] ?? 0),
          DoubleCellValue((sale['amount'] as num).toDouble()),
          TextCellValue(sale['payment_method'] ?? ''),
        ]);
      }

      // 4. Sheet: Gastos
      Sheet sheetExpenses = excel[l10n.expenses];
      sheetExpenses.appendRow([
        TextCellValue(l10n.date),
        TextCellValue(l10n.description),
        TextCellValue(l10n.amount),
        TextCellValue(l10n.category),
      ]);

      // Role-based filtering for expenses too
      var expensesQuery = Supabase.instance.client
          .from('expenses')
          .select('*, products(name)');

      if (profile.role == 'employee') {
        // Employee: only their own expenses
        expensesQuery = expensesQuery.eq('user_id', profile.id);
      } else {
        // Owner/Superadmin: all business expenses
        expensesQuery = expensesQuery.eq('business_id', businessId);
      }

      if (_currentFilter != StatsFilter.general) {
        expensesQuery = expensesQuery
            .gte('date', start.toIso8601String())
            .lte('date', end.toIso8601String());
      }

      final expensesData = await expensesQuery.order('date', ascending: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.exporting}: ${salesData.length} ${l10n.sales}, ${expensesData.length} ${l10n.expenses}. ($periodLabel)',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      for (var expense in expensesData) {
        sheetExpenses.appendRow([
          TextCellValue(expense['date'] ?? ''),
          TextCellValue(
            expense['comments'] ?? (expense['products']?['name'] ?? 'Gasto'),
          ),
          DoubleCellValue((expense['amount'] as num).toDouble()),
          TextCellValue(expense['payment_method'] ?? ''),
        ]);
      }

      // 5. Remove default sheet before saving
      if (excel.sheets.keys.length > 1 &&
          excel.sheets.keys.contains('Sheet1')) {
        excel.delete('Sheet1');
      }

      // 6. Save and Download (only once!)
      final fileName = 'Reporte_$periodLabel.xlsx';
      final fileBytes = excel.save(fileName: fileName);

      if (fileBytes != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.generatingFile}: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // On Web, excel.save(fileName: fileName) triggers the download automatically.
        // We only need FileSaver for native platforms.
        if (!kIsWeb) {
          await FileSaver.saveFile(fileBytes, fileName);
        }
      }
    } catch (e) {
      debugPrint('Error exporting excel: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    } finally {
      _isExporting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(businessIdProvider, (previous, next) {
      if (next != null) {
        final profile = ref.read(profileProvider).value;
        if (profile != null) {
          _loadDashboardData(next, userId: profile.id, role: profile.role);
        }
      }
    });

    final profile = ref.watch(profileProvider).value;
    final userName = profile?.fullName ?? 'Usuario';
    final balance = _totalIncome - _totalExpenses;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MarketMove'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.exportExcel,
            onPressed: _exportToExcel,
          ),
        ],
      ),
      drawer: _buildDrawer(userName),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (profile != null) {
                  await _loadDashboardData(
                    profile.businessId,
                    userId: profile.id,
                    role: profile.role,
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    if (_currentFilter != StatsFilter.general) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _updateDate(-1),
                          ),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Row(
                              children: [
                                Text(
                                  _getDateRangeLabel(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
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
                    // Low Stock Alert Card (Moved to top)
                    if (_lowStockCount > 0) ...[
                      Card(
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(
                            '$_lowStockCount ${l10n.lowStockAlert}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.red,
                          ),
                          onTap: () => context.go('/products'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.income,
                            _totalIncome,
                            Colors.green,
                            Icons.arrow_upward,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            l10n.expenses,
                            _totalExpenses,
                            Colors.red,
                            Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBalanceCard(balance, l10n),

                    const SizedBox(height: 24),

                    // Pie Chart Section
                    if (_totalIncome > 0 || _totalExpenses > 0) ...[
                      Text(
                        l10n.financialSummary,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: _totalIncome,
                                title:
                                    '${((_totalIncome / (_totalIncome + _totalExpenses)) * 100).toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                color: Colors.red,
                                value: _totalExpenses,
                                title:
                                    '${((_totalExpenses / (_totalIncome + _totalExpenses)) * 100).toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(l10n.income, Colors.green),
                          const SizedBox(width: 24),
                          _buildLegendItem(l10n.expenses, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      l10n.quickAccess,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Responsive quick access grid with max width
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate responsive values
                        final screenWidth = constraints.maxWidth;
                        final crossAxisCount = screenWidth > 600 ? 4 : 2;
                        final maxWidth = screenWidth > 600
                            ? 600.0
                            : double.infinity;

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.3,
                              children: [
                                _buildActionCard(
                                  context,
                                  l10n.sales,
                                  Icons.point_of_sale,
                                  Colors.blue,
                                  '/sales',
                                ),
                                _buildActionCard(
                                  context,
                                  l10n.expenses,
                                  Icons.receipt_long,
                                  Colors.orange,
                                  '/expenses',
                                ),
                                // Products visible to all (employees have view-only access)
                                _buildActionCard(
                                  context,
                                  l10n.products,
                                  Icons.inventory_2,
                                  Colors.purple,
                                  '/products',
                                ),
                                _buildActionCard(
                                  context,
                                  l10n.settings,
                                  Icons.settings,
                                  Colors.grey,
                                  '/settings',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterChip(String label, StatsFilter filter) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _currentFilter = filter;
          _selectedDate = DateTime.now(); // Reset date when changing filter
          _isLoading = true;
        });
        _checkAndLoadData();
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
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
            const SizedBox(height: 12),
            Text(
              '${amount.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalBalance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.netProfit,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Text(
              '${balance.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(String userName) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              Supabase.instance.client.auth.currentUser?.email ?? '',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
          ),
          if (ref.watch(impersonatedBusinessIdProvider) != null)
            Container(
              color: Colors.amber.shade100,
              child: ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.orange,
                ),
                title: Text(
                  l10n.backToSuperadmin,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  ref
                      .read(impersonatedBusinessIdProvider.notifier)
                      .setBusinessId(null);
                  context.go('/admin');
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: Text(l10n.home),
            onTap: () => context.pop(),
            selected: true,
            selectedColor: const Color(0xFF1A237E),
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: Text(l10n.sales),
            onTap: () => context.go('/sales'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(l10n.expenses),
            onTap: () => context.go('/expenses'),
          ),
          // Products visible to all (employees have view-only access)
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: Text(l10n.products),
            onTap: () => context.go('/products'),
          ),
          // Categories only for owners
          if (ref.watch(profileProvider).value?.role != 'employee')
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(l10n.categories),
              onTap: () => context.go('/categories'),
            ),
          // Employees section for owners or when superadmin is impersonating
          if (ref.watch(profileProvider).value?.role == 'owner' ||
              ref.watch(impersonatedBusinessIdProvider) != null)
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(l10n.employees),
              onTap: () => context.go('/employees'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
