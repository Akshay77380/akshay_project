import 'package:employee_manager/screens/employee_list_screen.dart';
import 'package:employee_manager/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'bloc/employee/employee_bloc.dart';
import 'models/employee.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(EmployeeRoleAdapter());
  await Hive.openBox<Employee>('employees');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => DatabaseService())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) => EmployeeBloc(
                  databaseService: context.read<DatabaseService>(),
                )..add(LoadEmployees()),
          ),
        ],
        child: MaterialApp(
          title: 'Employee Management',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          theme: AppTheme.lightTheme,
          home: const EmployeeListScreen(),
        ),
      ),
    );
  }
}
