import 'package:flutter/material.dart';

import 'app_widget.dart';
import 'core/database/app_database.dart';
import 'core/session/app_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;
  await AppSession.restore();
  runApp(const SmartCrmApp());
}
