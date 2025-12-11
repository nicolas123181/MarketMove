import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/product_model.dart';
import '../../l10n/app_localizations.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? saleToEdit;

  const AddSaleScreen({super.key, this.saleToEdit});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController(); // Optional now
  final _quantityController = TextEditingController(text: '1');
  final _commentsController = TextEditingController();

  String? _selectedProductId;
  String _selectedPaymentMethod = 'Efectivo';
  List<Product> _products = [];
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Otro',
  ];

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (widget.saleToEdit != null) {
      _amountController.text = widget.saleToEdit!['amount'].toString();
      _descriptionController.text = widget.saleToEdit!['description'] ?? '';
      _quantityController.text =
          widget.saleToEdit!['quantity']?.toString() ?? '1';
      _commentsController.text = widget.saleToEdit!['comments'] ?? '';
      _selectedProductId = widget.saleToEdit!['product_id'];
      _selectedPaymentMethod =
          widget.saleToEdit!['payment_method'] ?? 'Efectivo';
      if (widget.saleToEdit!['date'] != null) {
        _selectedDate = DateTime.parse(widget.saleToEdit!['date']);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: l10n.locale,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final response = await Supabase.instance.client
          .from('products')
          .select()
          .order('name', ascending: true);

      if (mounted) {
        setState(() {
          _products = (response as List)
              .map((e) => Product.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  void _updateAmount() {
    if (_selectedProductId != null) {
      final product = _products.firstWhere((p) => p.id == _selectedProductId);
      final qty = int.tryParse(_quantityController.text) ?? 1;
      setState(() {
        _amountController.text = (product.price * qty).toStringAsFixed(2);
      });
    }
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = ref.read(profileProvider).value;
      if (profile == null) throw Exception(l10n.profileNotLoaded);

      // Combine selected date with current time
      final now = DateTime.now();
      final finalDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      final data = {
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'business_id': profile.businessId,
        'amount': double.parse(_amountController.text.trim()),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'product_id': _selectedProductId,
        'quantity': int.parse(_quantityController.text.trim()),
        'payment_method': _selectedPaymentMethod,
        'comments': _commentsController.text.trim().isEmpty
            ? null
            : _commentsController.text.trim(),
        'date': finalDate.toIso8601String(),
      };

      if (widget.saleToEdit != null) {
        await Supabase.instance.client
            .from('sales')
            .update(data)
            .eq('id', widget.saleToEdit!['id']);
      } else {
        await Supabase.instance.client.from('sales').insert(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.success)));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.saleToEdit != null;
    final l10n = AppLocalizations.of(context);

    final Map<String, String> paymentMethodDisplay = {
      'Efectivo': l10n.paymentMethodCash,
      'Tarjeta': l10n.paymentMethodCard,
      'Transferencia': l10n.paymentMethodTransfer,
      'Otro': l10n.paymentMethodOther,
    };

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? l10n.editSale : l10n.newSale)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Selection
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.date,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Selection
              DropdownButtonFormField<String>(
                value: _selectedProductId,
                decoration: InputDecoration(
                  labelText: l10n.selectProduct,
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: product.id,
                    child: Text('${product.name} (€${product.price})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
                    _updateAmount();
                  });
                },
                hint: Text(l10n.selectProduct),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: l10n.quantity,
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateAmount(),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return l10n.required;
                        if (int.tryParse(value) == null) return l10n.invalid;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        prefixIcon: const Icon(Icons.euro),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return l10n.required;
                        if (double.tryParse(value) == null) return l10n.invalid;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: l10n.paymentMethod,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(paymentMethodDisplay[method] ?? method),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _commentsController,
                decoration: InputDecoration(
                  labelText: l10n.comments,
                  prefixIcon: const Icon(Icons.comment),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveSale,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? l10n.saveChanges : l10n.registerSale,
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
