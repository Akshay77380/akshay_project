import 'package:bloc/bloc.dart';
import 'package:employee_manager/screens/employee_list_screen.dart';
import 'package:hive/hive.dart';
import '../../services/database_service.dart';
import '../../models/employee.dart';
import 'package:equatable/equatable.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final DatabaseService databaseService;

  EmployeeBloc({required this.databaseService}) : super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
    on<SetEmployeeEndDate>(_onSetEmployeeEndDate);
    on<RestoreEmployee>(_onRestoreEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final box = await Hive.openBox<Employee>('employees');
      final employees = box.values.toList();
      if (employees.isEmpty) {
        emit(EmployeeLoaded(box.values.toList()));
      } else {
        emit(EmployeeLoaded(employees));
      }
    } catch (e) {
      emit(EmployeeError('Failed to load employees: ${e.toString()}'));
    }
  }

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      try {
        await databaseService.addEmployee(event.employee);
        final employees = await databaseService.getEmployees();
        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError('Failed to add employee'));
      }
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      try {
        await databaseService.updateEmployee(event.employee);
        final employees = await databaseService.getEmployees();
        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError('Failed to update employee'));
      }
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      try {
        await databaseService.deleteEmployee(event.id);
        final employees = await databaseService.getEmployees();
        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError('Failed to delete employee'));
      }
    }
  }

  Future<void> _onSetEmployeeEndDate(
    SetEmployeeEndDate event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      try {
        final employees = (state as EmployeeLoaded).employees;
        final employee = employees.firstWhere((e) => e.id == event.id);
        final updatedEmployee = employee.copyWith(endDate: event.endDate);
        await databaseService.updateEmployee(updatedEmployee);
        final updatedEmployees = await databaseService.getEmployees();
        emit(EmployeeLoaded(updatedEmployees));
      } catch (e) {
        emit(EmployeeError('Failed to update employment date'));
      }
    }
  }

  Future<void> _onRestoreEmployee(
    RestoreEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      try {
        await databaseService.restoreEmployee(event.employee);
        final employees = await databaseService.getEmployees();

        emit(EmployeeLoaded(employees));
      } catch (e) {
        emit(EmployeeError('Failed to restore employee'));
      }
    }
  }
}
