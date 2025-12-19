import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:myapp/models/transaction.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Text style for Clash Grotesk font
  static const TextStyle _clashGroteskStyle = TextStyle(
    fontFamily: 'ClashGrotesk',
    color: Colors.black,
    fontWeight: FontWeight.w400, // Default weight
    fontSize: 16,
  );

  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;

  my_category.Category? _selectedCategory;
  String _selectedType = 'expense';
  late DateTime _selectedDate;
  bool _isTypeDropdownOpen = false;
  bool _isCategoryDropdownOpen = false;

  bool get _isEditing => widget.transaction != null;
  List<my_category.Category> get _filteredCategories {
    final categories = Provider.of<CategoryProvider>(context).categories;
    return categories.where((cat) => cat.type == _selectedType).toList();
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _amountController = TextEditingController(text: t.amount.toString());
      _noteController = TextEditingController(text: t.note);
      _selectedType = t.type;
      _selectedDate = t.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedDate = DateTime.now();
    }
    _dateController = TextEditingController(text: _formatDate(_selectedDate));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditing && _selectedCategory == null) {
      final categoryProvider = Provider.of<CategoryProvider>(context);
      _selectedCategory = categoryProvider.getCategoryById(widget.transaction!.categoryId);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            fontFamily: 'ClashGrotesk',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // This makes the back button black
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              _label("Amount(₹)"),
              _inputField(
                controller: _amountController,
                hint: "Enter Amount",
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                iconPath: 'assets/icons/coin-unfill.svg',
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

              // Transaction Type
              _label("Transaction Type"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Selected Type Display
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isTypeDropdownOpen = !_isTypeDropdownOpen;
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
                              'assets/icons/receipt.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF757575),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedType == 'expense' 
                                  ? 'Expense' 
                                  : _selectedType == 'income' 
                                      ? 'Income' 
                                      : 'Select Transaction Type',
                              style: const TextStyle(
                                fontFamily: 'ClashGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedType.isNotEmpty)
                              SvgPicture.asset(
                                _selectedType == 'expense'
                                    ? 'assets/icons/expense.svg'
                                    : 'assets/icons/income.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  _selectedType == 'expense'
                                      ? const Color(0xFFFF3B30)
                                      : const Color(0xFF34C759),
                                  BlendMode.srcIn,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              _isTypeDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: const Color(0xFF9E9E9E),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Dropdown Options
                    if (_isTypeDropdownOpen) ...[
                      _buildTypeOption('expense', 'Expense', 'assets/icons/expense.svg', const Color(0xFFFF3B30)),
                      _buildTypeOption('income', 'Income', 'assets/icons/income.svg', const Color(0xFF34C759)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Category Dropdown
              _buildCategoryDropdown(),

              const SizedBox(height: 20),

              // Note
              _label("Note (optional)"),
              _inputField(
                controller: _noteController,
                hint: "Add a note",
                iconPath: 'assets/icons/note.svg',
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Date
              _label("Date"),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _inputField(
                    controller: _dateController,
                    hint: "Select date",
                    iconPath: 'assets/icons/calendar.svg',
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                      child: Text(
                        'Cancel',
                        style: const TextStyle(
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
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Update' : 'Save Transaction',
                        style: const TextStyle(
                          fontFamily: 'ClashGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = _filteredCategories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Category"),
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
                  if (categories.isNotEmpty) {
                    setState(() {
                      _isCategoryDropdownOpen = !_isCategoryDropdownOpen;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        style: const TextStyle(
                          fontFamily: 'ClashGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedCategory != null)
                        SvgPicture.asset(
                          _selectedCategory!.iconPath,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            _selectedCategory!.color,
                            BlendMode.srcIn,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isCategoryDropdownOpen 
                            ? Icons.keyboard_arrow_up 
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF9E9E9E),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              // Category options
              if (_isCategoryDropdownOpen && categories.isNotEmpty)
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
          _isCategoryDropdownOpen = false;
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
                  color: isSelected ? category.color : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category.color,
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
                category.color,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, String iconPath, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          _isTypeDropdownOpen = false;
          // Reset selected category when type changes
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: Colors.white,
        child: Row(
          children: [
            // Radio button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedType == value ? Colors.black : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: _selectedType == value
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'ClashGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Icon
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                color,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    DateTime currentDate = _selectedDate;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: _buildDatePickerContent(now, currentDate, (newDate) {
              setState(() {
                _selectedDate = newDate;
                _dateController.text = _formatDate(_selectedDate);
              });
              Navigator.of(context).pop();
            }),
          ),
        );
      },
    );
  }

  Widget _buildDatePickerContent(DateTime now, DateTime currentDate, Function(DateTime) onDateSelected) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Date',
                  style: const TextStyle(
                    fontFamily: 'ClashGrotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24, color: Color(0xFF666666)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Month/Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24, color: Color(0xFF666666)),
                  onPressed: () {
                    setModalState(() {
                      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
                    });
                  },
                ),
                Text(
                  '${_getMonthName(currentDate.month)} ${currentDate.year}',
                  style: const TextStyle(
                    fontFamily: 'ClashGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24, color: Color(0xFF666666)),
                  onPressed: () {
                    setModalState(() {
                      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            
            // Weekday Headers
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeekdayLabel(day: 'Sun'),
                _WeekdayLabel(day: 'Mon'),
                _WeekdayLabel(day: 'Tue'),
                _WeekdayLabel(day: 'Wed'),
                _WeekdayLabel(day: 'Thu'),
                _WeekdayLabel(day: 'Fri'),
                _WeekdayLabel(day: 'Sat'),
              ],
            ),
            
            // Calendar Grid
            _buildCalendarGrid(currentDate, now, onDateSelected),
            
            const SizedBox(height: 16),
            
            // Buttons Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: const TextStyle(
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
                    onPressed: () {
                      onDateSelected(currentDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'ClashGrotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarGrid(DateTime currentDate, DateTime now, Function(DateTime) onDateSelected) {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 6 = Saturday
    
    List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentDate.year, currentDate.month, day);
      final isSelected = _datesAreOnSameDay(date, _selectedDate);
      final isToday = _datesAreOnSameDay(date, now);
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
              _dateController.text = _formatDate(_selectedDate);
            });
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(12), // Added border radius
              border: isToday && !isSelected 
                  ? Border.all(color: Theme.of(context).primaryColor, width: 1) 
                  : null,
            ),
            alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(  // Removed 'const' from here
                  fontFamily: 'ClashGrotesk',
                  fontSize: 14,
                  fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : (isToday 
                          ? Theme.of(context).primaryColor 
                          : const Color(0xFF333333)),
                ),
              ),
            ),
          ),
        );
      
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: dayWidgets,
    );
  }

  bool _datesAreOnSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      final transaction = Transaction()
        ..id = _isEditing ? widget.transaction!.id : _uuid.v4()
        ..amount = amount
        ..categoryId = _selectedCategory!.id
        ..date = _selectedDate
        ..note = _noteController.text
        ..type = _selectedType;

      final provider = Provider.of<TransactionProvider>(context, listen: false);
      if (_isEditing) {
        provider.updateTransaction(transaction);
      } else {
        provider.addTransaction(transaction);
      }

      Navigator.of(context).pop();
    }
  }

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
}

class _WeekdayLabel extends StatelessWidget {
  final String day;

  const _WeekdayLabel({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        day,
        style: const TextStyle(
          fontFamily: 'ClashGrotesk',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}