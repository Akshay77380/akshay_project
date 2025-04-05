import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';

class CustomCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? initialDate;

  const CustomCalendar({
    Key? key,
    required this.onDateSelected,
    this.initialDate,
  }) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  final _dateFormat = DateFormat('d MMM yyyy');
  late String _currentWeekdayName;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _currentWeekdayName = DateFormat('EEEE').format(DateTime.now());
  }

  void _selectDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      _selectedDate = normalizedDate;
      if (_focusedDate.month != normalizedDate.month ||
          _focusedDate.year != normalizedDate.year) {
        _focusedDate = DateTime(normalizedDate.year, normalizedDate.month, 1);
      }
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
    });
  }

  DateTime _getNextMonday() {
    final today = DateTime.now();
    return today.add(Duration(days: (8 - today.weekday) % 7));
  }

  DateTime _getNextTuesday() {
    final today = DateTime.now();
    int daysUntilNextTuesday = (2 - today.weekday + 7) % 7;
    daysUntilNextTuesday = daysUntilNextTuesday == 0 ? 7 : daysUntilNextTuesday;
    return today.add(Duration(days: daysUntilNextTuesday));
  }

  DateTime _getNextWeek() {
    return DateTime.now().add(const Duration(days: 7));
  }

  List<DateTime> _getDaysInMonth() {
    final first = _focusedDate;
    final last = DateTime(first.year, first.month + 1, 0);
    final daysInMonth = last.day;

    return List.generate(
      daysInMonth,
      (i) => DateTime(first.year, first.month, i + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final daysInMonth = _getDaysInMonth();
    final firstWeekday = daysInMonth.first.weekday % 7;
    final today = DateTime.now();
    final nextTuesday = _getNextTuesday();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: size.width * 0.02,
              runSpacing: size.width * 0.02,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildQuickSelectButton("Today", today)),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: _buildQuickSelectButton(
                        "Next Monday",
                        _getNextMonday(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildQuickSelectButton(
                        "Next Tuesday",
                        nextTuesday,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: _buildQuickSelectButton(
                        "After 1 week",
                        _getNextWeek(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _changeMonth(-1),
                  child: Image.asset(
                    'assets/icons/arrow_left.png',
                    width: size.width * 0.05,
                    height: size.width * 0.05,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedDate),
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _changeMonth(1),
                  child: Image.asset(
                    'assets/icons/arrow_right.png',
                    width: size.width * 0.05,
                    height: size.width * 0.05,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              children:
                  ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: AppTextStyles.label.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: size.height * 0.01),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInMonth.length + firstWeekday,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return SizedBox();

                final dayIndex = index - firstWeekday;
                final date = daysInMonth[dayIndex];
                final isSelected = isSameDay(_selectedDate, date);
                final isToday = isSameDay(date, today);

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      shape: BoxShape.circle,
                      border:
                          isToday && !isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style:
                            isSelected
                                ? AppTextStyles.button.copyWith(
                                  color: Colors.white,
                                )
                                : AppTextStyles.button,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
              child: Divider(thickness: 0.4, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      _dateFormat.format(_selectedDate),
                      style: AppTextStyles.bodyTextSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntrinsicWidth(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFEDF8FF),
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    IntrinsicWidth(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onDateSelected(_selectedDate);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.015,
                            horizontal: size.width * 0.03,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final after1WeekDate = normalizedToday.add(Duration(days: 7));

    final isAfter1Week =
        normalizedSelected.isAtSameMomentAs(after1WeekDate) ||
        normalizedSelected.isAfter(after1WeekDate);
    final isSelected =
        isSameDay(_selectedDate, date) ||
        (label.startsWith("After 1 week") && isAfter1Week);

    return ElevatedButton(
      onPressed: () => _selectDate(date),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.blue : Colors.blue.withOpacity(0.2),
        foregroundColor: isSelected ? Colors.white : Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
      child: Text(
        label,
        style:
            isSelected
                ? AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                )
                : AppTextStyles.label.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
