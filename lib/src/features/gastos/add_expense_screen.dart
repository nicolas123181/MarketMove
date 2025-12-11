import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/product_model.dart';
import '../../l10n/app_localizations.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _commentsController = TextEditingController();
  final _typeController = TextEditingController();
  final _providerController = TextEditingController();

  String? _selectedProductId;
  String _selectedPaymentMethod = 'Efectivo';
  List<Product> _products = [];
  XFile? _selectedImage;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _paymentMethods = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (widget.expenseToEdit != null) {
      _amountController.text = widget.expenseToEdit!['amount'].toString();
      _descriptionController.text = widget.expenseToEdit!['description'] ?? '';
      _quantityController.text =
          widget.expenseToEdit!['quantity']?.toString() ?? '1';
      _commentsController.text = widget.expenseToEdit!['comments'] ?? '';
      _typeController.text = widget.expenseToEdit!['type'] ?? '';
      _providerController.text = widget.expenseToEdit!['provider'] ?? '';
      _selectedProductId = widget.expenseToEdit!['product_id'];
      _selectedPaymentMethod =
          widget.expenseToEdit!['payment_method'] ?? 'Efectivo';
      if (widget.expenseToEdit!['date'] != null) {
        _selectedDate = DateTime.parse(widget.expenseToEdit!['date']);
      }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    ); // Or gallery
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = ref.read(profileProvider).value;
      if (profile == null) throw Exception(l10n.profileNotLoaded);

      String? photoUrl;
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'expenses/$fileName';
        // Try to upload
        try {
          final bytes = await _selectedImage!.readAsBytes();
          await Supabase.instance.client.storage
              .from('expenses')
              .uploadBinary(
                path,
                bytes,
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
          photoUrl = Supabase.instance.client.storage
              .from('expenses')
              .getPublicUrl(path);
        } catch (e) {
          debugPrint('Error uploading image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.uploadImageError}: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }

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
        'type': _typeController.text.trim().isEmpty
            ? null
            : _typeController.text.trim(),
        'provider': _providerController.text.trim().isEmpty
            ? null
            : _providerController.text.trim(),
        'photo_url': photoUrl,
        'date': _selectedDate.toIso8601String(),
      };

      if (widget.expenseToEdit != null) {
        await Supabase.instance.client
            .from('expenses')
            .update(data)
            .eq('id', widget.expenseToEdit!['id']);
      } else {
        await Supabase.instance.client.from('expenses').insert(data);
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
    _typeController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    final l10n = AppLocalizations.of(context);

    final Map<String, String> paymentMethodDisplay = {
      'Efectivo': l10n.paymentMethodCash,
      'Tarjeta': l10n.paymentMethodCard,
      'Transferencia': l10n.paymentMethodTransfer,
      'Otro': l10n.paymentMethodOther,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editExpense : l10n.newExpense),
      ),
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
                  labelText: l10n.productRelated,
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                items: _products.map((product) {
                  return DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductId = value;
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
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: l10n.type,
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _providerController,
                decoration: InputDecoration(
                  labelText: l10n.provider,
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.required;
                  return null;
                },
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
              const SizedBox(height: 16),

              // Photo Picker
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.attachPhoto),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.check_circle, color: Colors.green),
                    Text(l10n.photoSelected),
                  ],
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveExpense,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? l10n.saveChanges : l10n.registerExpense,
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
