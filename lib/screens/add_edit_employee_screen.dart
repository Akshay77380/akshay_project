import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/employee/employee_bloc.dart';
import '../models/employee.dart';
import '../widgets/custom_calendar.dart';
import '../widgets/custom_calendar2.dart';
import '../theme/app_text_styles.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;
  final bool? isEdited;

  const AddEditEmployeeScreen({super.key, this.employee, this.isEdited});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  EmployeeRole? _selectedRole;
  DateTime? _selectedDate;
  DateTime? _endDate;
  bool _isEdited = false;
  late Employee? _employee;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _selectedRole = widget.employee?.role;
    _selectedDate = widget.employee?.startDate;
    _endDate = widget.employee?.endDate;
    _isEdited = widget.isEdited ?? false;
    _employee = widget.employee;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            _isEdited ? "Edit Employee Details" : "Add Employee Details",
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
          ),
          actions:
              _isEdited
                  ? [
                    IconButton(
                      onPressed: _deleteEmployee,
                      icon: Image.asset(
                        'assets/icons/delete_icon.png',
                        width: size.width * 0.06,
                        height: size.width * 0.06,
                      ),
                    ),
                  ]
                  : null,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height * 0.02),
                          _buildNameField(theme),
                          SizedBox(height: size.height * 0.03),
                          _buildRoleSelector(theme, size),
                          SizedBox(height: size.height * 0.03),
                          _buildDateRow(theme, size),
                          SizedBox(height: size.height * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomActions(theme, size),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Employee name',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Image.asset(
            'assets/icons/person_icon.png',
            width: 20,
            height: 20,
            color: theme.primaryColor,
          ),
        ),
        labelStyle: AppTextStyles.label.copyWith(fontSize: 16),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cursorColor: theme.primaryColor,
      style: AppTextStyles.bodyText,
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Please enter employee name'
                  : null,
    );
  }

  Widget _buildRoleSelector(ThemeData theme, Size size) {
    return GestureDetector(
      onTap: () async {
        EmployeeRole? selected = await _showRoleSelectionBottomSheet(context);
        if (selected != null) {
          setState(() => _selectedRole = selected);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.018,
        ),
        child: Row(
          children: [
            Image.asset('assets/icons/role_icon.png', width: 28, height: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedRole?.name ?? 'Select Role',
                style: AppTextStyles.bodyText.copyWith(
                  color: _selectedRole != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(ThemeData theme, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: _showCalendarDialog,
            child: _buildDateBox(
              theme,
              iconPath: 'assets/icons/calendar_icon.png',
              text:
                  _selectedDate != null
                      ? DateFormat('dd MMM, yyyy').format(_selectedDate!)
                      : 'Today',
              size: size,
            ),
          ),
        ),
        Image.asset('assets/icons/arrow_icon.png', width: 45, height: 10),
        Flexible(
          child: GestureDetector(
            onTap: _showCalendarDialog2,
            child: _buildDateBox(
              theme,
              iconPath: 'assets/icons/calendar_icon.png',
              text:
                  _endDate != null
                      ? DateFormat('dd MMM, yyyy').format(_endDate!)
                      : 'No Date',
              isPlaceholder: _endDate == null,
              size: size,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateBox(
    ThemeData theme, {
    required String iconPath,
    required String text,
    bool isPlaceholder = false,
    required Size size,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.018,
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 25, height: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyTextSmall.copyWith(
                color: isPlaceholder ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              side: BorderSide(color: theme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonText.copyWith(color: Colors.blue),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _saveEmployee,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Save', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomCalendar(
              initialDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
          ),
    );
  }

  void _showCalendarDialog2() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomCalendar2(
              initialDate: _endDate,
              onDateSelected: (date) => setState(() => _endDate = date),
              primaryColor: Colors.blue,
              showNoDateOption: true,
              selectNoDateByDefault: _endDate == null,
              minDate: _selectedDate,
            ),
          ),
    );
  }

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      _showSnackBar('Please select a role');
      return;
    }
    if (_selectedDate == null) {
      _showSnackBar('Please select a start date');
      return;
    }
    if (_endDate != null && _endDate!.isBefore(_selectedDate!)) {
      _showSnackBar('End date must be after start date');
      return;
    }

    final employee = Employee(
      id:
          widget.employee?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      role: _selectedRole!,
      startDate: _selectedDate!,
      endDate: _endDate,
    );

    if (_isEdited) {
      context.read<EmployeeBloc>().add(UpdateEmployee(employee));
    } else {
      context.read<EmployeeBloc>().add(AddEmployee(employee));
    }

    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteEmployee() {
    if (_employee == null) return;

    final bloc = context.read<EmployeeBloc>();
    bloc.add(DeleteEmployee(_employee!.id));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Employee data has been deleted',
            style: AppTextStyles.bodyText.copyWith(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.blue,
            onPressed: () => bloc.add(RestoreEmployee(_employee!)),
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            top:
                MediaQuery.of(context).size.height -
                kBottomNavigationBarHeight +
                18,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      );

    Navigator.pop(context, true);
  }

  Future<EmployeeRole?> _showRoleSelectionBottomSheet(BuildContext context) {
    return showModalBottomSheet<EmployeeRole>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: EmployeeRole.values.length,
            separatorBuilder: (_, __) => const Divider(thickness: 0.4),
            itemBuilder: (_, index) {
              final role = EmployeeRole.values[index];
              return ListTile(
                title: Center(
                  child: Text(
                    role.name,
                    style: AppTextStyles.bodyText.copyWith(color: Colors.black),
                  ),
                ),
                onTap: () => Navigator.pop(context, role),
              );
            },
          ),
        );
      },
    );
  }
}
