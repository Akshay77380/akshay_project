// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 1;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as EmployeeRole,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeRoleAdapter extends TypeAdapter<EmployeeRole> {
  @override
  final int typeId = 0;

  @override
  EmployeeRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmployeeRole.productDesigner;
      case 1:
        return EmployeeRole.flutterDeveloper;
      case 2:
        return EmployeeRole.qaTester;
      case 3:
        return EmployeeRole.productOwner;
      default:
        return EmployeeRole.productDesigner;
    }
  }

  @override
  void write(BinaryWriter writer, EmployeeRole obj) {
    switch (obj) {
      case EmployeeRole.productDesigner:
        writer.writeByte(0);
        break;
      case EmployeeRole.flutterDeveloper:
        writer.writeByte(1);
        break;
      case EmployeeRole.qaTester:
        writer.writeByte(2);
        break;
      case EmployeeRole.productOwner:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
