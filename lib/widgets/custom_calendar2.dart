import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';

class CustomCalendar2 extends StatefulWidget {
  final Function(DateTime?) onDateSelected;
  final DateTime? initialDate;
  final bool showNoDateOption;
  final Color? primaryColor;
  final Color? accentColor;
  final bool selectNoDateByDefault;
  final DateTime? minDate;

  const CustomCalendar2({
    Key? key,
    required this.onDateSelected,
    this.initialDate,
    this.showNoDateOption = true,
    this.primaryColor,
    this.accentColor,
    this.selectNoDateByDefault = true,
    this.minDate,
  }) : super(key: key);

  @override
  _CustomCalendarState2 createState() => _CustomCalendarState2();
}

class _CustomCalendarState2 extends State<CustomCalendar2> {
  late DateTime? _selectedDate;
  late DateTime _focusedDate;
  late bool _noDateSelected;
  final _dateFormat = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final now = DateTime.now();

    if (widget.selectNoDateByDefault || widget.initialDate == null) {
      _noDateSelected = true;
    } else {
      _noDateSelected = false;
    }

    if (widget.initialDate != null) {
      _focusedDate = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        1,
      );
    } else if (widget.minDate != null && now.isBefore(widget.minDate!)) {
      _focusedDate = DateTime(widget.minDate!.year, widget.minDate!.month, 1);
    } else {
      _focusedDate = DateTime(now.year, now.month, 1);
    }
  }

  void _selectDate(DateTime? date) {
    setState(() {
      if (date == null) {
        _noDateSelected = true;
        _selectedDate = null;
      } else {
        _noDateSelected = false;
        _selectedDate = date;
        if (_focusedDate.month != date.month ||
            _focusedDate.year != date.year) {
          _focusedDate = DateTime(date.year, date.month, 1);
        }
      }
    });
  }

  void _changeMonth(int delta) {
    final newFocusedDate = DateTime(
      _focusedDate.year,
      _focusedDate.month + delta,
      1,
    );
    if (widget.minDate != null) {
      final minMonth = DateTime(widget.minDate!.year, widget.minDate!.month, 1);
      if (newFocusedDate.isBefore(minMonth)) return;
    }
    setState(() {
      _focusedDate = newFocusedDate;
    });
  }

  List<DateTime> _getDaysInMonth() {
    final first = _focusedDate;
    final last = DateTime(first.year, first.month + 1, 0);
    return List.generate(
      last.day,
      (i) => DateTime(first.year, first.month, i + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth();
    final firstWeekday = daysInMonth.first.weekday % 7;
    final today = DateTime.now();

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showNoDateOption) ...[
              _buildQuickSelectRow([
                _buildQuickSelectButton(
                  label: "No Date",
                  date: null,
                  isSelected: _noDateSelected,
                ),
                _buildQuickSelectButton(
                  label: "Today",
                  date: today,
                  isSelected:
                      !_noDateSelected && isSameDay(_selectedDate, today),
                ),
              ]),
              const SizedBox(height: 20),
            ],
            _buildMonthNavigation(),
            const SizedBox(height: 20),
            _buildWeekdayHeaders(),
            const SizedBox(height: 8),
            _buildCalendarGrid(daysInMonth, firstWeekday, today),
            const SizedBox(height: 20),
            const Divider(thickness: 0.4, color: Colors.grey),
            const SizedBox(height: 12),
            _buildFooter(today),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectRow(List<Widget> buttons) {
    return Row(
      children:
          buttons
              .map(
                (button) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: button,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildQuickSelectButton({
    required String label,
    required DateTime? date,
    required bool isSelected,
  }) {
    final isNoDateButton = date == null;
    final isActuallySelected =
        isNoDateButton ? _noDateSelected : isSelected && !_noDateSelected;

    final isDisabled =
        date != null &&
        widget.minDate != null &&
        date.isBefore(widget.minDate!) &&
        !isSameDay(date, widget.minDate);

    return ElevatedButton(
      onPressed: isDisabled ? null : () => _selectDate(date),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isActuallySelected
                ? Colors.blue
                : isDisabled
                ? Colors.grey[200]
                : const Color(0xFFEDF8FF),
        foregroundColor:
            isActuallySelected
                ? Colors.white
                : isDisabled
                ? Colors.grey
                : Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: 13, color: isDisabled ? Colors.grey : null),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final canGoPrev =
        widget.minDate == null ||
        DateTime(
          _focusedDate.year,
          _focusedDate.month - 1,
          1,
        ).isAfter(DateTime(widget.minDate!.year, widget.minDate!.month - 1, 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: canGoPrev ? () => _changeMonth(-1) : null,
          child: Opacity(
            opacity: canGoPrev ? 1.0 : 0.3,
            child: Image.asset(
              'assets/icons/arrow_left.png',
              width: 18,
              height: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            DateFormat('MMMM yyyy').format(_focusedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          onTap: () => _changeMonth(1),
          child: Image.asset(
            'assets/icons/arrow_right.png',
            width: 18,
            height: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    return Row(
      children:
          ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCalendarGrid(
    List<DateTime> daysInMonth,
    int firstWeekday,
    DateTime today,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth.length + firstWeekday,
      itemBuilder: (context, index) {
        if (index < firstWeekday) return const SizedBox();

        final dayIndex = index - firstWeekday;
        final date = daysInMonth[dayIndex];
        final isSelected = !_noDateSelected && isSameDay(_selectedDate, date);
        final isBeforeMinDate =
            widget.minDate != null &&
            date.isBefore(widget.minDate!) &&
            !isSameDay(date, widget.minDate);
        final isDisabled = isBeforeMinDate;
        final isToday = isSameDay(date, today);

        return GestureDetector(
          onTap: isDisabled ? null : () => _selectDate(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
              border:
                  isToday && !isSelected
                      ? Border.all(color: Colors.blue, width: 1)
                      : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color:
                      isDisabled
                          ? Colors.grey[400]
                          : isSelected
                          ? Colors.white
                          : isToday
                          ? Colors.blue
                          : Colors.black,
                  fontWeight:
                      isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(DateTime today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
            Text(
              _noDateSelected ? 'No Date' : _dateFormat.format(_selectedDate!),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEDF8FF),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.015,
                  horizontal: MediaQuery.sizeOf(context).width * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(color: Colors.blue),
              ),
            ),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
            ElevatedButton(
              onPressed: () {
                widget.onDateSelected(_selectedDate);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.015,
                  horizontal: MediaQuery.sizeOf(context).width * 0.03,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Save',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
