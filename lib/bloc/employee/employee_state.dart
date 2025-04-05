part of 'employee_bloc.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;

  const EmployeeLoaded(this.employees);

  @override
  List<Object> get props => [employees];
}

class EmployeeOperationSuccess extends EmployeeState {
  final String message;

  const EmployeeOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object> get props => [message];
}

class EmployeeAddSuccess extends EmployeeState {
  final Employee employee;

  const EmployeeAddSuccess(this.employee);

  @override
  List<Object> get props => [employee];
}

class EmployeeUpdateSuccess extends EmployeeState {
  final Employee employee;

  const EmployeeUpdateSuccess(this.employee);

  @override
  List<Object> get props => [employee];
}

class EmployeeDeleteSuccess extends EmployeeState {
  final String id;

  const EmployeeDeleteSuccess(this.id);

  @override
  List<Object> get props => [id];
}