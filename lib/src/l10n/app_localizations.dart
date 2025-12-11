import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'select_language': 'Select Language',
      'dashboard': 'Dashboard',
      'sales': 'Sales',
      'expenses': 'Expenses',
      'products': 'Products',
      'categories': 'Categories',
      'logout': 'Logout',
      'profile': 'Profile',
      'total_sales': 'Total Sales',
      'total_expenses': 'Total Expenses',
      'low_stock': 'Low Stock',
      'daily_profit': 'Daily Profit',
      'home': 'Home',
      'welcome': 'Welcome',
      'income': 'Income',
      'net_profit': 'Net Profit',
      'financial_summary': 'Financial Summary',
      'quick_access': 'Quick Access',
      'monthly': 'Monthly',
      'weekly': 'Weekly',
      'daily': 'Daily',
      'general': 'General',
      'low_stock_alert': 'products with low stock',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'date': 'Date',
      'amount': 'Amount',
      'quantity': 'Quantity',
      'description': 'Description',
      'comments': 'Comments',
      'required': 'Required',
      'invalid': 'Invalid',
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading',
      'new_sale': 'New Sale',
      'edit_sale': 'Edit Sale',
      'register_sale': 'Register Sale',
      'payment_method': 'Payment Method',
      'product_related': 'Related Product',
      'select_product': 'Select Product',
      'new_expense': 'New Expense',
      'edit_expense': 'Edit Expense',
      'register_expense': 'Register Expense',
      'type': 'Type',
      'provider': 'Provider',
      'attach_photo': 'Attach Photo',
      'photo_selected': 'Photo Selected',
      'new_product': 'New Product',
      'edit_product': 'Edit Product',
      'stock': 'Stock',
      'price': 'Price',
      'barcode': 'Barcode',
      'category': 'Category',
      'select_category': 'Select Category',
      'new_category': 'New Category',
      'edit_category': 'Edit Category',
      'name': 'Name',
      'confirm_delete': 'Confirm Delete',
      'delete_message': 'Are you sure you want to delete this item?',
      'total_balance': 'Total Balance',
      'export_excel': 'Export to Excel',
      'generating_file': 'Generating file',
      'exporting': 'Exporting',
      'no_sales': 'No sales registered',
      'no_expenses': 'No expenses registered',
      'no_products': 'No products registered',
      'no_categories': 'No categories registered',
      'save_changes': 'Save Changes',
      'email': 'Email',
      'password': 'Password',
      'login_button': 'Login',
      'register_link': 'Don\'t have an account? Register',
      'unexpected_error': 'Unexpected error',
      'login_subtitle': 'Sign in to MarketMove',
      'create_account_error': 'Error creating user',
      'business_id_required': 'Business ID is required',
      'account_created': 'Account created successfully. Welcome!',
      'create_account_title': 'Create Account',
      'join_marketmove': 'Join MarketMove today',
      'full_name': 'Full Name',
      'phone': 'Phone',
      'business_id_label': 'Business ID (Ask your boss)',
      'register_button': 'Register',
      'login_link': 'Already have an account? Login',
      'close': 'Close',
      'download': 'Download',
      'could_not_open_link': 'Could not open link',
      'payment_method_cash': 'Cash',
      'payment_method_card': 'Card',
      'payment_method_transfer': 'Transfer',
      'payment_method_other': 'Other',
      'profile_not_loaded': 'Profile not loaded',
      'upload_image_error': 'Error uploading image',
      'logout_error': 'Error logging out',
      'owner_created_success': 'Owner created successfully',
      'create_owner_error': 'Error creating owner',
      'owner_updated_success': 'Owner updated successfully',
      'update_error': 'Error updating',
      'owner_deleted_success': 'Owner deleted successfully',
      'delete_error': 'Error deleting',
      'delete_owner_title': 'Delete Owner',
      'delete_owner_confirmation':
          'Are you sure you want to delete this owner?',
      'create_new_owner_title': 'Create New Owner',
      'create_button': 'Create',
      'edit_owner_title': 'Edit Owner',
      'superadmin_panel': 'Superadmin Panel',
      'registered_users': 'Registered Users',
      'no_name': 'No Name',
      'new_owner_button': 'New Owner',
      'no_description': 'No description',
      'back_to_superadmin': 'Back to Superadmin Panel',
      'business_id': 'Business ID',
      'id_copied': 'ID copied to clipboard',
      'low_stock_threshold_setting':
          'Show alert when stock is less than or equal to',
      'employees': 'Employees',
      'no_employees': 'No employees registered',
      'no_employees_hint': 'Employees can register using your Business ID',
      'since': 'Since',
      'records': 'records',
      'recent_sales': 'Recent Sales',
      'recent_expenses': 'Recent Expenses',
    },
    'es': {
      'settings': 'Configuración',
      'language': 'Idioma',
      'select_language': 'Seleccionar Idioma',
      'dashboard': 'Panel Principal',
      'sales': 'Ventas',
      'expenses': 'Gastos',
      'products': 'Productos',
      'categories': 'Categorías',
      'logout': 'Cerrar Sesión',
      'profile': 'Perfil',
      'total_sales': 'Ventas Totales',
      'total_expenses': 'Gastos Totales',
      'low_stock': 'Stock Bajo',
      'daily_profit': 'Ganancias del día',
      'home': 'Inicio',
      'welcome': 'Bienvenido',
      'income': 'Ingresos',
      'net_profit': 'Beneficio Neto',
      'financial_summary': 'Resumen Financiero',
      'quick_access': 'Accesos Rápidos',
      'monthly': 'Mensual',
      'weekly': 'Semanal',
      'daily': 'Diario',
      'general': 'General',
      'low_stock_alert': 'productos con bajo stock',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'search': 'Buscar',
      'date': 'Fecha',
      'amount': 'Importe',
      'quantity': 'Cantidad',
      'description': 'Descripción',
      'comments': 'Comentarios',
      'required': 'Requerido',
      'invalid': 'Inválido',
      'success': 'Operación exitosa',
      'error': 'Error',
      'loading': 'Cargando...',
      'new_sale': 'Nueva Venta',
      'edit_sale': 'Editar Venta',
      'register_sale': 'Registrar Venta',
      'payment_method': 'Método de Pago',
      'product_related': 'Producto Relacionado',
      'select_product': 'Seleccionar Producto',
      'new_expense': 'Nuevo Gasto',
      'edit_expense': 'Editar Gasto',
      'register_expense': 'Registrar Gasto',
      'type': 'Tipo',
      'provider': 'Proveedor',
      'attach_photo': 'Adjuntar Foto',
      'photo_selected': 'Foto seleccionada',
      'new_product': 'Nuevo Producto',
      'edit_product': 'Editar Producto',
      'stock': 'Stock',
      'price': 'Precio',
      'barcode': 'Código de Barras',
      'category': 'Categoría',
      'select_category': 'Seleccionar Categoría',
      'new_category': 'Nueva Categoría',
      'edit_category': 'Editar Categoría',
      'name': 'Nombre',
      'confirm_delete': 'Confirmar eliminación',
      'delete_message': '¿Estás seguro de que quieres eliminar este elemento?',
      'total_balance': 'Balance Total',
      'export_excel': 'Exportar a Excel',
      'generating_file': 'Generando archivo...',
      'exporting': 'Exportando...',
      'no_sales': 'No hay ventas registradas',
      'no_expenses': 'No hay gastos registrados',
      'no_products': 'No hay productos registrados',
      'no_categories': 'No hay categorías registradas',
      'save_changes': 'Guardar Cambios',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'login_button': 'Iniciar Sesión',
      'register_link': '¿No tienes cuenta? Regístrate',
      'unexpected_error': 'Error inesperado',
      'login_subtitle': 'Inicia sesión en MarketMove',
      'create_account_error': 'Error al crear usuario',
      'business_id_required': 'El ID de negocio es requerido',
      'account_created': '¡Cuenta creada correctamente. Bienvenido!',
      'create_account_title': 'Crear Cuenta',
      'join_marketmove': 'Únete a MarketMove hoy',
      'full_name': 'Nombre completo',
      'phone': 'Teléfono',
      'business_id_label': 'ID del Negocio (Pídelo a tu jefe)',
      'register_button': 'Registrarse',
      'login_link': '¿Ya tienes cuenta? Inicia sesión',
      'close': 'Cerrar',
      'download': 'Descargar',
      'could_not_open_link': 'No se pudo abrir el enlace',
      'payment_method_cash': 'Efectivo',
      'payment_method_card': 'Tarjeta',
      'payment_method_transfer': 'Transferencia',
      'payment_method_other': 'Otro',
      'profile_not_loaded': 'Perfil no cargado',
      'upload_image_error': 'Error al subir imagen',
      'logout_error': 'Error al cerrar sesión',
      'owner_created_success': 'Dueño creado exitosamente',
      'create_owner_error': 'Error al crear dueño',
      'owner_updated_success': 'Dueño actualizado exitosamente',
      'update_error': 'Error al actualizar',
      'owner_deleted_success': 'Dueño eliminado exitosamente',
      'delete_error': 'Error al eliminar',
      'delete_owner_title': 'Eliminar Dueño',
      'delete_owner_confirmation':
          '¿Estás seguro de que quieres eliminar a este dueño?',
      'create_new_owner_title': 'Crear Nuevo Dueño',
      'create_button': 'Crear',
      'edit_owner_title': 'Editar Dueño',
      'superadmin_panel': 'Panel Superadmin',
      'registered_users': 'Usuarios Registrados',
      'no_name': 'Sin nombre',
      'new_owner_button': 'Nuevo Dueño',
      'no_description': 'Sin descripción',
      'back_to_superadmin': 'Volver al Panel Superadmin',
      'business_id': 'ID del Negocio',
      'id_copied': 'ID copiado al portapapeles',
      'low_stock_threshold_setting':
          'Mostrar alerta cuando el stock sea menor o igual a',
      'employees': 'Trabajadores',
      'no_employees': 'No hay empleados registrados',
      'no_employees_hint':
          'Los empleados pueden registrarse usando tu ID de Negocio',
      'since': 'Desde',
      'records': 'registros',
      'recent_sales': 'Ventas Recientes',
      'recent_expenses': 'Gastos Recientes',
    },
  };

  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get selectLanguage =>
      _localizedValues[locale.languageCode]!['select_language']!;
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard']!;
  String get sales => _localizedValues[locale.languageCode]!['sales']!;
  String get expenses => _localizedValues[locale.languageCode]!['expenses']!;
  String get products => _localizedValues[locale.languageCode]!['products']!;
  String get categories =>
      _localizedValues[locale.languageCode]!['categories']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get totalSales =>
      _localizedValues[locale.languageCode]!['total_sales']!;
  String get totalExpenses =>
      _localizedValues[locale.languageCode]!['total_expenses']!;
  String get lowStock => _localizedValues[locale.languageCode]!['low_stock']!;
  String get dailyProfit =>
      _localizedValues[locale.languageCode]!['daily_profit']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get income => _localizedValues[locale.languageCode]!['income']!;
  String get netProfit => _localizedValues[locale.languageCode]!['net_profit']!;
  String get financialSummary =>
      _localizedValues[locale.languageCode]!['financial_summary']!;
  String get quickAccess =>
      _localizedValues[locale.languageCode]!['quick_access']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get daily => _localizedValues[locale.languageCode]!['daily']!;
  String get general => _localizedValues[locale.languageCode]!['general']!;
  String get lowStockAlert =>
      _localizedValues[locale.languageCode]!['low_stock_alert']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get date => _localizedValues[locale.languageCode]!['date']!;
  String get amount => _localizedValues[locale.languageCode]!['amount']!;
  String get quantity => _localizedValues[locale.languageCode]!['quantity']!;
  String get description =>
      _localizedValues[locale.languageCode]!['description']!;
  String get comments => _localizedValues[locale.languageCode]!['comments']!;
  String get required => _localizedValues[locale.languageCode]!['required']!;
  String get invalid => _localizedValues[locale.languageCode]!['invalid']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get newSale => _localizedValues[locale.languageCode]!['new_sale']!;
  String get editSale => _localizedValues[locale.languageCode]!['edit_sale']!;
  String get registerSale =>
      _localizedValues[locale.languageCode]!['register_sale']!;
  String get paymentMethod =>
      _localizedValues[locale.languageCode]!['payment_method']!;
  String get productRelated =>
      _localizedValues[locale.languageCode]!['product_related']!;
  String get selectProduct =>
      _localizedValues[locale.languageCode]!['select_product']!;
  String get newExpense =>
      _localizedValues[locale.languageCode]!['new_expense']!;
  String get editExpense =>
      _localizedValues[locale.languageCode]!['edit_expense']!;
  String get registerExpense =>
      _localizedValues[locale.languageCode]!['register_expense']!;
  String get type => _localizedValues[locale.languageCode]!['type']!;
  String get provider => _localizedValues[locale.languageCode]!['provider']!;
  String get attachPhoto =>
      _localizedValues[locale.languageCode]!['attach_photo']!;
  String get photoSelected =>
      _localizedValues[locale.languageCode]!['photo_selected']!;
  String get newProduct =>
      _localizedValues[locale.languageCode]!['new_product']!;
  String get editProduct =>
      _localizedValues[locale.languageCode]!['edit_product']!;
  String get stock => _localizedValues[locale.languageCode]!['stock']!;
  String get price => _localizedValues[locale.languageCode]!['price']!;
  String get barcode => _localizedValues[locale.languageCode]!['barcode']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get selectCategory =>
      _localizedValues[locale.languageCode]!['select_category']!;
  String get newCategory =>
      _localizedValues[locale.languageCode]!['new_category']!;
  String get editCategory =>
      _localizedValues[locale.languageCode]!['edit_category']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get confirmDelete =>
      _localizedValues[locale.languageCode]!['confirm_delete']!;
  String get deleteMessage =>
      _localizedValues[locale.languageCode]!['delete_message']!;
  String get totalBalance =>
      _localizedValues[locale.languageCode]!['total_balance']!;
  String get exportExcel =>
      _localizedValues[locale.languageCode]!['export_excel']!;
  String get generatingFile =>
      _localizedValues[locale.languageCode]!['generating_file']!;
  String get exporting => _localizedValues[locale.languageCode]!['exporting']!;
  String get noSales => _localizedValues[locale.languageCode]!['no_sales']!;
  String get noExpenses =>
      _localizedValues[locale.languageCode]!['no_expenses']!;
  String get noProducts =>
      _localizedValues[locale.languageCode]!['no_products']!;
  String get noCategories =>
      _localizedValues[locale.languageCode]!['no_categories']!;
  String get saveChanges =>
      _localizedValues[locale.languageCode]!['save_changes']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get loginButton =>
      _localizedValues[locale.languageCode]!['login_button']!;
  String get registerLink =>
      _localizedValues[locale.languageCode]!['register_link']!;
  String get unexpectedError =>
      _localizedValues[locale.languageCode]!['unexpected_error']!;
  String get loginSubtitle =>
      _localizedValues[locale.languageCode]!['login_subtitle']!;
  String get createAccountError =>
      _localizedValues[locale.languageCode]!['create_account_error']!;
  String get businessIdRequired =>
      _localizedValues[locale.languageCode]!['business_id_required']!;
  String get accountCreated =>
      _localizedValues[locale.languageCode]!['account_created']!;
  String get createAccountTitle =>
      _localizedValues[locale.languageCode]!['create_account_title']!;
  String get joinMarketMove =>
      _localizedValues[locale.languageCode]!['join_marketmove']!;
  String get fullName => _localizedValues[locale.languageCode]!['full_name']!;
  String get phone => _localizedValues[locale.languageCode]!['phone']!;
  String get businessIdLabel =>
      _localizedValues[locale.languageCode]!['business_id_label']!;
  String get registerButton =>
      _localizedValues[locale.languageCode]!['register_button']!;
  String get loginLink => _localizedValues[locale.languageCode]!['login_link']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get download => _localizedValues[locale.languageCode]!['download']!;
  String get couldNotOpenLink =>
      _localizedValues[locale.languageCode]!['could_not_open_link']!;
  String get paymentMethodCash =>
      _localizedValues[locale.languageCode]!['payment_method_cash']!;
  String get paymentMethodCard =>
      _localizedValues[locale.languageCode]!['payment_method_card']!;
  String get paymentMethodTransfer =>
      _localizedValues[locale.languageCode]!['payment_method_transfer']!;
  String get paymentMethodOther =>
      _localizedValues[locale.languageCode]!['payment_method_other']!;
  String get profileNotLoaded =>
      _localizedValues[locale.languageCode]!['profile_not_loaded']!;
  String get uploadImageError =>
      _localizedValues[locale.languageCode]!['upload_image_error']!;
  String get logoutError =>
      _localizedValues[locale.languageCode]!['logout_error']!;
  String get ownerCreatedSuccess =>
      _localizedValues[locale.languageCode]!['owner_created_success']!;
  String get createOwnerError =>
      _localizedValues[locale.languageCode]!['create_owner_error']!;
  String get ownerUpdatedSuccess =>
      _localizedValues[locale.languageCode]!['owner_updated_success']!;
  String get updateError =>
      _localizedValues[locale.languageCode]!['update_error']!;
  String get ownerDeletedSuccess =>
      _localizedValues[locale.languageCode]!['owner_deleted_success']!;
  String get deleteError =>
      _localizedValues[locale.languageCode]!['delete_error']!;
  String get deleteOwnerTitle =>
      _localizedValues[locale.languageCode]!['delete_owner_title']!;
  String get deleteOwnerConfirmation =>
      _localizedValues[locale.languageCode]!['delete_owner_confirmation']!;
  String get createNewOwnerTitle =>
      _localizedValues[locale.languageCode]!['create_new_owner_title']!;
  String get createButton =>
      _localizedValues[locale.languageCode]!['create_button']!;
  String get editOwnerTitle =>
      _localizedValues[locale.languageCode]!['edit_owner_title']!;
  String get superadminPanel =>
      _localizedValues[locale.languageCode]!['superadmin_panel']!;
  String get registeredUsers =>
      _localizedValues[locale.languageCode]!['registered_users']!;
  String get noName => _localizedValues[locale.languageCode]!['no_name']!;
  String get newOwnerButton =>
      _localizedValues[locale.languageCode]!['new_owner_button']!;
  String get noDescription =>
      _localizedValues[locale.languageCode]!['no_description']!;
  String get backToSuperadmin =>
      _localizedValues[locale.languageCode]!['back_to_superadmin']!;
  String get businessId =>
      _localizedValues[locale.languageCode]!['business_id']!;
  String get idCopied => _localizedValues[locale.languageCode]!['id_copied']!;
  String get lowStockThresholdSetting =>
      _localizedValues[locale.languageCode]!['low_stock_threshold_setting']!;
  String get employees => _localizedValues[locale.languageCode]!['employees']!;
  String get noEmployees =>
      _localizedValues[locale.languageCode]!['no_employees']!;
  String get noEmployeesHint =>
      _localizedValues[locale.languageCode]!['no_employees_hint']!;
  String get since => _localizedValues[locale.languageCode]!['since']!;
  String get records => _localizedValues[locale.languageCode]!['records']!;
  String get recentSales =>
      _localizedValues[locale.languageCode]!['recent_sales']!;
  String get recentExpenses =>
      _localizedValues[locale.languageCode]!['recent_expenses']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
