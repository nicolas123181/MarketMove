import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/settings/settings_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/resumen/home_screen.dart';
import 'features/ventas/sales_screen.dart';
import 'features/ventas/add_sale_screen.dart';
import 'features/gastos/expenses_screen.dart';
import 'features/gastos/add_expense_screen.dart';
import 'features/productos/products_screen.dart';
import 'features/productos/add_product_screen.dart';
import 'features/productos/categories_screen.dart';
import 'features/productos/add_category_screen.dart';
import 'features/admin/super_admin_screen.dart';
import 'features/employees/employees_screen.dart';
import 'features/employees/employee_detail_screen.dart';
import 'shared/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

class MarketMoveApp extends ConsumerWidget {
  MarketMoveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MarketMove',
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Navy Blue
          secondary: const Color(0xFF00BFA5), // Teal Accent
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A237E),
          ),
          displayMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A237E),
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A237E),
          ),
          titleMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A237E),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A237E)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }

  late final _router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoggingIn =
          state.uri.path == '/login' || state.uri.path == '/register';

      if (!isLoggedIn) {
        // If not logged in and not on login/register page, redirect to login
        if (!isLoggingIn) return '/login';
        return null;
      }

      // If logged in and trying to access login/register, redirect to home/admin
      if (isLoggingIn) {
        // Check role to redirect appropriately
        try {
          final profileResponse = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', session.user.id)
              .single();

          final role = profileResponse['role'] as String?;
          if (role == 'superadmin') {
            return '/admin';
          }
          return '/';
        } catch (e) {
          // If error fetching profile, default to home
          return '/';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'sales',
            builder: (context, state) => const SalesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final sale = state.extra as Map<String, dynamic>?;
                  return AddSaleScreen(saleToEdit: sale);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'expenses',
            builder: (context, state) => const ExpensesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final expense = state.extra as Map<String, dynamic>?;
                  return AddExpenseScreen(expenseToEdit: expense);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'products',
            builder: (context, state) => const ProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final product = state.extra as Map<String, dynamic>?;
                  return AddProductScreen(productToEdit: product);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddCategoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'employees',
            builder: (context, state) => const EmployeesScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final employee = state.extra as Map<String, dynamic>;
                  return EmployeeDetailScreen(employee: employee);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const SuperAdminScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
