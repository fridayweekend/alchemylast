import 'commerce/commerce_prototype_store.dart';
import 'package:flutter/material.dart';

import 'data/progress_store.dart';
import 'data/mock_data.dart';
import 'pages.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadCourseCatalogue();
  await loadProgress();
  await CommercePrototypeStore.instance.load();
  runApp(const MtAlchemyApp());
}

class MtAlchemyApp extends StatelessWidget {
  const MtAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MT Alchemy',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      onGenerateRoute: buildRoute,
    );
  }
}
