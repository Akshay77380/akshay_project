part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final Employee employee;

  const AddEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final Employee employee;

  const UpdateEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;

  const DeleteEmployee(this.id);

  @override
  List<Object> get props => [id];
}

class RestoreEmployee extends EmployeeEvent {
  final Employee employee;
  const RestoreEmployee(this.employee);
  @override
  List<Object> get props => [employee];
}

class SetEmployeeEndDate extends EmployeeEvent {
  final String id;
  final DateTime? endDate;

  const SetEmployeeEndDate(this.id, this.endDate);

  @override
  List<Object> get props => [id, endDate ?? DateTime.now()];
}

class EditEmployee extends EmployeeEvent {
  final Employee employee;

  const EditEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}
