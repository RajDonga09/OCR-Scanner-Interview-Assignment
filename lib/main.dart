import 'package:ocr_interview_assignment/dependency.dart';

import 'features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await configureDependencies();
  runApp(const OcrApp());
}

class OcrApp extends StatelessWidget {
  const OcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
