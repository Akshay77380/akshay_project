import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
enum EmployeeRole {
  @HiveField(0)
  productDesigner,
  @HiveField(1)
  flutterDeveloper,
  @HiveField(2)
  qaTester,
  @HiveField(3)
  productOwner,
}

extension EmployeeRoleExtension on EmployeeRole {
  String get name {
    switch (this) {
      case EmployeeRole.productDesigner:
        return 'Product Designer';
      case EmployeeRole.flutterDeveloper:
        return 'Flutter Developer';
      case EmployeeRole.qaTester:
        return 'QA Tester';
      case EmployeeRole.productOwner:
        return 'Product Owner';
    }
  }
}

@HiveType(typeId: 1)
class Employee extends Equatable with HiveObjectMixin {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final EmployeeRole role;
  @HiveField(3)
  final DateTime startDate;
  @HiveField(4)
  final DateTime? endDate;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.startDate,
    this.endDate,
  });

  bool get isCurrent => endDate == null;

  @override
  List<Object?> get props => [id, name, role, startDate, endDate];

  Employee copyWith({
    String? id,
    String? name,
    EmployeeRole? role,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}