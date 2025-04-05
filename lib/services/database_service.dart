import 'package:hive/hive.dart';
import '../models/employee.dart';

class DatabaseService {
  static const String _employeeBox = 'employees';

  Future<void> init() async {
    await Hive.openBox<Employee>(_employeeBox);
  }

  Future<List<Employee>> getEmployees() async {
    final box = Hive.box<Employee>(_employeeBox);
    return box.values.toList();
  }

  Future<void> addEmployee(Employee employee) async {
    final box = Hive.box<Employee>(_employeeBox);
    await box.put(employee.id, employee);
  }

  Future<void> updateEmployee(Employee employee) async {
    final box = Hive.box<Employee>(_employeeBox);
    await box.put(employee.id, employee);
  }

  Future<void> deleteEmployee(String id) async {
    final box = Hive.box<Employee>(_employeeBox);
    await box.delete(id);
  }

  Future<void> restoreEmployee(Employee employee) async {
    final box = await Hive.openBox<Employee>(_employeeBox);
    await box.put(employee.id, employee);
  }
}
