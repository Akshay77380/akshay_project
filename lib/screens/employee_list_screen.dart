import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../bloc/employee/employee_bloc.dart';
import '../models/employee.dart';
import '../theme/app_text_styles.dart';
import 'add_edit_employee_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  bool isSnackBarVisible = false;

  void _showSnackBar(BuildContext context, Employee employee) {
    final employeeBloc = context.read<EmployeeBloc>();
    employeeBloc.add(DeleteEmployee(employee.id));

    setState(() {
      isSnackBarVisible = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:  Text(
            'Employee data has been deleted',
            style: AppTextStyles.bodyText.copyWith(color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.blue,
            onPressed: () {
              employeeBloc.add(RestoreEmployee(employee));
            },
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
      ).closed.then((_) {
        if (mounted) {
          setState(() {
            isSnackBarVisible = false;
          });
        }
      });
  }

  void _navigateToAddEditEmployeeScreen(
    Employee? employee,
    bool? isSnackBarVisibleParam,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditEmployeeScreen(employee: employee),
      ),
    );

    if (result == true) {
      setState(() {
        isSnackBarVisible = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isSnackBarVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Employee List',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<EmployeeBloc, EmployeeState>(
              builder: (context, state) {
                if (state is EmployeeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EmployeeLoaded) {
                  final now = DateTime.now();
                  final validEmployees =
                      state.employees
                          .where((e) => !e.startDate.isAfter(now))
                          .toList();

                  final currentEmployees =
                      validEmployees.where((e) {
                        if (e.endDate == null) return true;
                        return e.endDate!.isAfter(now) ||
                            (e.endDate!.year == now.year &&
                                e.endDate!.month == now.month &&
                                e.endDate!.day == now.day);
                      }).toList();

                  final previousEmployees =
                      validEmployees.where((e) {
                        return e.endDate != null &&
                            e.endDate!.isBefore(now) &&
                            !(e.endDate!.year == now.year &&
                                e.endDate!.month == now.month &&
                                e.endDate!.day == now.day);
                      }).toList();

                  if (validEmployees.isEmpty) {
                    return Center(
                      child: SvgPicture.asset(
                        'assets/images/no_data_found_img.svg',
                        width: 200,
                        height: 200,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (currentEmployees.isNotEmpty) ...[
                        _buildSectionHeader('Current Employees'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentEmployees.length,
                            itemBuilder:
                                (context, index) => _buildEmployeeItem(
                                  context,
                                  currentEmployees[index],
                                  DateFormat('d MMM, yyyy'),
                                ),
                          ),
                        ),
                      ],
                      if (previousEmployees.isNotEmpty) ...[
                        _buildSectionHeader('Previous Employees'),
                        Expanded(
                          child: ListView.builder(
                            itemCount: previousEmployees.length,
                            itemBuilder:
                                (context, index) => _buildEmployeeItem(
                                  context,
                                  previousEmployees[index],
                                  DateFormat('d MMM, yyyy'),
                                ),
                          ),
                        ),
                      ],
                    ],
                  );
                } else if (state is EmployeeError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodyText.copyWith(color: Colors.red),
                    ),
                  );
                }
                return const Center(child: Text('No data'));
              },
            ),
          ),
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, state) {
              if (state is! EmployeeLoaded) return const SizedBox.shrink();

              final now = DateTime.now();
              final validEmployees =
                  state.employees
                      .where((e) => !e.startDate.isAfter(now))
                      .toList();

              if (validEmployees.isEmpty) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30, right: 20),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditEmployeeScreen(),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                );
              }

              return Container(
                color: Colors.grey.shade200,
                height: MediaQuery.of(context).size.height * 0.1,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Swipe left to delete',
                      style: AppTextStyles.bodyTextSmall,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      transform: Matrix4.translationValues(
                        0,
                        isSnackBarVisible ? -50 : 0,
                        0,
                      ),
                      child: FloatingActionButton(
                        onPressed:
                            () => _navigateToAddEditEmployeeScreen(null, true),
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: AppTextStyles.headingSmall.copyWith(
          color: Colors.blue,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(
    BuildContext context,
    Employee employee,
    DateFormat dateFormat,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddEditEmployeeScreen(
                      employee: employee,
                      isEdited: true,
                    ),
              ),
            );
          },
          child: Slidable(
            key: Key(employee.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.4,
              children: [
                const Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 1,
                  child: SlidableAction(
                    onPressed: (_) => _showSnackBar(context, employee),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    autoClose: true,
                  ),
                ),
              ],
            ),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name, style: AppTextStyles.headingSmall),
                  const SizedBox(height: 6),
                  Text(
                    employee.role.name,
                    style: AppTextStyles.bodyTextSmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    employee.endDate == null
                        ? 'From ${dateFormat.format(employee.startDate)}'
                        : '${dateFormat.format(employee.startDate)} - ${dateFormat.format(employee.endDate!)}',
                    style: AppTextStyles.bodyTextSmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
      ],
    );
  }
}
