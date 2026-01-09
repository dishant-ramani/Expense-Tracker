import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/models/budget.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/providers/budget_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  
  late TextEditingController _amountController;
  my_category.Category? _selectedCategory;
  
  bool _isDropdownOpen = false;
  bool get _isEditing => widget.budget != null;
  
  List<my_category.Category> _getFilteredCategories(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context, listen: false).categories;
    return categories.where((cat) => cat.type == 'expense').toList();
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    
    if (_isEditing) {
      _amountController.text = widget.budget!.amount.toString();
      // In a real app, you would load the category by ID here
      // For now, we'll create a temporary category for display
      _selectedCategory = my_category.Category()
        ..id = widget.budget!.categoryId
        ..name = widget.budget!.category
        ..type = 'expense'
        ..iconCodePoint = widget.budget!.iconCodePoint
        ..colorValue = Colors.grey.value
        ..iconPath = '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Label widget for consistent styling
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'ClashGrotesk',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  // Input field widget for consistent styling
  Widget _inputField({
    required TextEditingController? controller,
    required String hint,
    String? iconPath,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'ClashGrotesk',
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'ClashGrotesk',
          color: Color(0xFF9E9E9E),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        prefixIcon: iconPath != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF757575),
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _getFilteredCategories(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Category'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Column(
            children: [
              // Selected category display
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/category.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF757575),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategory?.name ?? 'Select Category',
                        style: TextStyle(
                          fontFamily: 'ClashGrotesk',
                          fontSize: 16,
                          color: _selectedCategory != null ? Colors.black : const Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedCategory != null)
                        SvgPicture.asset(
                          _selectedCategory!.iconPath,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Color(_selectedCategory!.colorValue),
                            BlendMode.srcIn,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF9E9E9E),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Category options
              if (_isDropdownOpen && categories.isNotEmpty)
                ..._buildCategoryOptions(categories),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryOptions(List<my_category.Category> categories) {
    return categories.map((category) {
      final isSelected = _selectedCategory?.id == category.id;
      return Column(
        children: [
          _buildCategoryOption(category, isSelected),
          if (categories.indexOf(category) < categories.length - 1)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F1F1),
              indent: 20,
              endIndent: 20,
            ),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryOption(my_category.Category category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _isDropdownOpen = false;
        });
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            // Radio button with category color
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Color(category.colorValue) : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(category.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Category name
            Text(
              category.name,
              style: TextStyle(
                fontFamily: 'ClashGrotesk',
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Category icon with category color
            SvgPicture.asset(
              category.iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Color(category.colorValue),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        title: Text(
          _isEditing ? 'Edit Budget' : 'Add Budget',
          style: const TextStyle(
            fontFamily: 'ClashGrotesk',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Field
                _label('Budget Amount (₹)'),
                _inputField(
                  controller: _amountController,
                  hint: 'Enter amount',
                  iconPath: 'assets/icons/coin-unfill.svg',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                _buildCategoryDropdown(),
                
                const SizedBox(height: 20),
                
                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isEditing ? 'Update' : 'Save',
                          style: const TextStyle(
                            fontFamily: 'ClashGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);

      if (_isEditing) {
        final updatedBudget = Budget(
          id: widget.budget!.id,
          category: _selectedCategory!.name,
          amount: amount,
          iconCodePoint: _selectedCategory!.iconCodePoint,
          categoryId: _selectedCategory!.id,
        );
        Provider.of<BudgetProvider>(context, listen: false)
            .updateBudget(updatedBudget);
      } else {
        final newBudget = Budget(
          id: _uuid.v4(),
          category: _selectedCategory!.name,
          amount: amount,
          iconCodePoint: _selectedCategory!.iconCodePoint,
          categoryId: _selectedCategory!.id,
        );
        Provider.of<BudgetProvider>(context, listen: false)
            .addBudget(newBudget);
      }
      Navigator.pop(context);
    } else if (_selectedCategory == null) {
      // Show error if no category is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
    }
  }
}
