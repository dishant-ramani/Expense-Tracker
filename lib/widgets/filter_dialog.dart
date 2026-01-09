// Add this at the top of the file with other imports
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/transaction_provider.dart';
import 'package:myapp/providers/category_provider.dart';
import 'package:myapp/models/category.dart' as my_category;
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class _WeekdayLabel extends StatelessWidget {
  final String day;

  const _WeekdayLabel({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        day,
        style: const TextStyle(
          fontFamily: 'ClashGrotesk',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final String? initialDateFilterType;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialCategoryId;
  final String? initialTransactionType;

  const FilterDialog({
    Key? key,
    this.initialDateFilterType = 'all',
    this.initialStartDate,
    this.initialEndDate,
    this.initialCategoryId,
    this.initialTransactionType,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _dateFilterType;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;
  String? _selectedTransactionType;
  bool _isCategoryDropdownOpen = false;
  bool _isDateRangeDropdownOpen = false;
  final List<Map<String, dynamic>> _dateRangeOptions = [
    {'label': 'All Time', 'value': 'all'},
    {'label': 'This Week', 'value': 'this_week'},
    {'label': 'This Month', 'value': 'this_month'},
    {'label': 'Last Month', 'value': 'last_month'},
    {'label': 'This Year', 'value': 'this_year'},
    {'label': 'Custom', 'value': 'custom'},
  ];
  final LayerLink _dateRangeLink = LayerLink();
  OverlayEntry? _dateRangeOverlayEntry;

  @override
  void initState() {
    super.initState();
    _dateFilterType = widget.initialDateFilterType ?? 'all';
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedCategoryId = widget.initialCategoryId;
    _selectedTransactionType = widget.initialTransactionType;
    _isCategoryDropdownOpen = false;
  }

  void _showDatePickerDialog(BuildContext context, bool isStart) {
    final initialDate = isStart ? _startDate : _endDate;
    final now = DateTime.now();
    final currentDate = initialDate ?? now;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: _buildDatePickerContent(now, currentDate, (newDate) {
              setState(() {
                if (isStart) {
                  _startDate = newDate;
                  if (_endDate != null && _endDate!.isBefore(newDate)) {
                    _endDate = null;
                  }
                } else {
                  _endDate = newDate;
                }
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
                const Text(
                  'Select Date',
                  style: TextStyle(
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
            const SizedBox(height: 4),
            
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
            
            const SizedBox(height: 4),
            
            // Today Button
            TextButton(
              onPressed: () {
                onDateSelected(now);
              },
              child: const Text(
                'Today',
                style: TextStyle(
                  fontFamily: 'ClashGrotesk',
                  color: Color(0xFF3A57E8),
                  fontWeight: FontWeight.w500,
                ),
              ),
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
      final isStartDate = _startDate != null && _datesAreOnSameDay(date, _startDate!);
      final isEndDate = _endDate != null && _datesAreOnSameDay(date, _endDate!);
      final isInRange = _startDate != null && _endDate != null &&
          date.isAfter(_startDate!) && date.isBefore(_endDate!);
      final isToday = _datesAreOnSameDay(date, now);
      
      dayWidgets.add(
        GestureDetector(
          onTap: () {
            onDateSelected(date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isStartDate || isEndDate 
                  ? const Color(0xFF3A57E8) 
                  : (isInRange ? const Color(0x1A3A57E8) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isToday 
                  ? Border.all(color: const Color(0xFF3A57E8), width: 1) 
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: 'ClashGrotesk',
                fontSize: 14,
                fontWeight: isStartDate || isEndDate || isToday ? FontWeight.w600 : FontWeight.normal,
                color: isStartDate || isEndDate 
                    ? Colors.white 
                    : (isToday ? const Color(0xFF3A57E8) : const Color(0xFF333333)),
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
      childAspectRatio: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  date != null 
                    ? DateFormat('MMM d, yyyy').format(date)
                    : 'Select Date',
                  style: TextStyle(
                    color: date != null ? Colors.black87 : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _dateFilterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _dateFilterType = value;
          if (value != 'custom') {
            final now = DateTime.now();
            switch (value) {
              case 'this_week':
                _startDate = now.subtract(Duration(days: now.weekday - 1));
                _endDate = now.add(Duration(days: 7 - now.weekday));
                break;
              case 'this_month':
                _startDate = DateTime(now.year, now.month, 1);
                _endDate = DateTime(now.year, now.month + 1, 0);
                break;
              case 'last_month':
                _startDate = DateTime(now.year, now.month - 1, 1);
                _endDate = DateTime(now.year, now.month, 0);
                break;
              case 'this_year':
                _startDate = DateTime(now.year, 1, 1);
                _endDate = DateTime(now.year, 12, 31);
                break;
              case 'all':
              default:
                _startDate = null;
                _endDate = null;
                break;
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A57E8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String? value) {
    final isSelected = _selectedTransactionType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransactionType = isSelected ? null : value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A57E8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showDateRangeDropdown() {
    if (_dateRangeOverlayEntry != null) return;

    _dateRangeOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _dateRangeLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _dateRangeOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _dateFilterType == option['value'];
                  
                  return Column(
                    children: [
                      if (index > 0)
                        Container(
                          height: 1,
                          color: const Color(0xFFF0F0F0),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _dateFilterType = option['value'];
                            _isDateRangeDropdownOpen = false;
                            _updateDateRange(option['value']);
                          });
                          _hideDateRangeDropdown();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Center(
                            child: Text(
                              option['label'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? const Color(0xFF3A57E8) : const Color(0xFF333333),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dateRangeOverlayEntry!);
  }

  void _hideDateRangeDropdown() {
    _dateRangeOverlayEntry?.remove();
    _dateRangeOverlayEntry = null;
    if (mounted) {
      setState(() {
        _isDateRangeDropdownOpen = false;
      });
    }
  }

  void _updateDateRange(String value) {
    final now = DateTime.now();
    switch (value) {
      case 'this_week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'this_month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'last_month':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 'this_year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'all':
      default:
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  @override
  void dispose() {
    _hideDateRangeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Transactions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Date Range Section
            Text(
              'Date Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                // Date range dropdown button
                CompositedTransformTarget(
                  link: _dateRangeLink,
                  child: GestureDetector(
                    onTap: () {
                      if (_isDateRangeDropdownOpen) {
                        _hideDateRangeDropdown();
                      } else {
                        _isCategoryDropdownOpen = false;
                        _showDateRangeDropdown();
                        setState(() {
                          _isDateRangeDropdownOpen = true;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/calendar.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF757575),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _dateRangeOptions.firstWhere(
                                (option) => option['value'] == _dateFilterType,
                                orElse: () => _dateRangeOptions.first,
                              )['label'],
                              style: const TextStyle(
                                fontFamily: 'ClashGrotesk',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _isDateRangeDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF9E9E9E),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Dropdown menu (positioned absolutely)
                if (_isDateRangeDropdownOpen)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 56, // Adjust based on your layout
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _dateRangeOptions.map((option) {
                            final isSelected = _dateFilterType == option['value'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _dateFilterType = option['value'];
                                  _isDateRangeDropdownOpen = false;
                                  
                                  // Handle date range selection
                                  if (_dateFilterType != 'custom') {
                                    final now = DateTime.now();
                                    switch (_dateFilterType) {
                                      case 'this_week':
                                        _startDate = now.subtract(Duration(days: now.weekday - 1));
                                        _endDate = now.add(Duration(days: 7 - now.weekday));
                                        break;
                                      case 'this_month':
                                        _startDate = DateTime(now.year, now.month, 1);
                                        _endDate = DateTime(now.year, now.month + 1, 0);
                                        break;
                                      case 'last_month':
                                        _startDate = DateTime(now.year, now.month - 1, 1);
                                        _endDate = DateTime(now.year, now.month, 0);
                                        break;
                                      case 'this_year':
                                        _startDate = DateTime(now.year, 1, 1);
                                        _endDate = DateTime(now.year, 12, 31);
                                        break;
                                      case 'all':
                                      default:
                                        _startDate = null;
                                        _endDate = null;
                                        break;
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFF5F7FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF3A57E8) : const Color(0xFFE0E0E0),
                                          width: isSelected ? 6 : 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      option['label'],
                                      style: TextStyle(
                                        fontFamily: 'ClashGrotesk',
                                        fontSize: 14,
                                        color: isSelected ? const Color(0xFF3A57E8) : const Color(0xFF333333),
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_dateFilterType == 'custom') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label: 'Start date',
                      date: _startDate,
                      onTap: () => _showDatePickerDialog(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label: 'End date',
                      date: _endDate,
                      onTap: () => _showDatePickerDialog(context, false),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            
            // Transaction Type Section
            Text(
              'Transaction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypeChip('All', null),
                  const SizedBox(width: 8),
                  _buildTypeChip('Income', 'income'),
                  const SizedBox(width: 8),
                  _buildTypeChip('Expense', 'expense'),
                ],
              ),
            ),

            const SizedBox(height: 4),
            
            // Category Section
            Text(
              'Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
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
                        _isCategoryDropdownOpen = !_isCategoryDropdownOpen;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            _selectedCategoryId != null 
                              ? categories.firstWhere((c) => c.id == _selectedCategoryId).name 
                              : 'All Categories',
                            style: const TextStyle(
                              fontFamily: 'ClashGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedCategoryId != null)
                            SvgPicture.asset(
                              categories.firstWhere((c) => c.id == _selectedCategoryId).iconPath,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Color(categories.firstWhere((c) => c.id == _selectedCategoryId).colorValue),
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
            const SizedBox(height: 4),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_dateFilterType == 'custom' && (_startDate == null || _endDate == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both start and end dates for custom range')),
                        );
                        return;
                      }
                      
                      Navigator.of(context).pop({
                        'dateFilterType': _dateFilterType,
                        'startDate': _startDate,
                        'endDate': _endDate,
                        'categoryId': _selectedCategoryId,
                        'transactionType': _selectedTransactionType,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A57E8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryOptions(List<my_category.Category> categories) {
    return [
      // All Categories option
      _buildCategoryOption(null, 'All Categories', false, null, null),
      const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF1F1F1),
        indent: 20,
        endIndent: 20,
      ),
      // Category options in a fixed height scrollable container
      SizedBox(
        height: 5 * 38.0, // Reduced height for 5 items (48.0 per item)
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategoryId == category.id;
            return Column(
              children: [
                _buildCategoryOption(
                  category.id,
                  category.name,
                  isSelected,
                  category.iconPath,
                  category.colorValue,
                ),
                if (index < categories.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F1F1),
                    indent: 20,
                    endIndent: 20,
                  ),
              ],
            );
          },
        ),
      ),
    ];
  }

  Widget _buildCategoryOption(
    String? categoryId,
    String label,
    bool isSelected,
    String? iconPath,
    int? colorValue,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = isSelected ? null : categoryId;
          _isCategoryDropdownOpen = false;
        });
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced padding
        child: Row(
          children: [
            // Radio button with category color
            Container(
              width: 20, // Slightly smaller radio button
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected && colorValue != null 
                      ? Color(colorValue) 
                      : const Color(0xFFE0E0E0),
                  width: 1.5, // Slightly thinner border
                ),
              ),
              child: isSelected && colorValue != null
                  ? Center(
                      child: Container(
                        width: 10, // Smaller inner circle
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12), // Reduced spacing
            // Category name
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ClashGrotesk',
                fontSize: 14, // Smaller font size
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (iconPath != null && colorValue != null) ...[
              const Spacer(),
              // Category icon with category color
              SvgPicture.asset(
                iconPath,
                width: 18, // Smaller icon
                height: 18,
                colorFilter: ColorFilter.mode(
                  Color(colorValue),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}