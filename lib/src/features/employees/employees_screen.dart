import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/auth_provider.dart';
import '../admin/providers/admin_provider.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.value([]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  void _loadEmployees() {
    // Check if superadmin is impersonating an owner
    final impersonatedBusinessId = ref.read(impersonatedBusinessIdProvider);
    final profile = ref.read(profileProvider).value;

    // Use impersonated business_id if available, otherwise use user's own business_id
    final businessIdToUse = impersonatedBusinessId ?? profile?.businessId;

    if (businessIdToUse == null) {
      setState(() {
        _future = Future.value([]);
      });
      return;
    }

    // Query employees directly using the correct business_id
    setState(() {
      _future = Supabase.instance.client
          .from('profiles')
          .select()
          .eq('business_id', businessIdToUse)
          .eq('role', 'employee')
          .order('full_name', ascending: true)
          .then((data) => List<Map<String, dynamic>>.from(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.employees)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final employees = snapshot.data ?? [];

          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noEmployees,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noEmployeesHint,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final employee = employees[index];
              final name = employee['full_name'] ?? l10n.noName;
              final phone = employee['phone'] ?? '';
              final createdAt = DateTime.parse(employee['created_at']);

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1A237E),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                      if (phone.isNotEmpty)
                        Text(
                          '${l10n.phone}: $phone',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      Text(
                        '${l10n.since}: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/employees/detail', extra: employee);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
