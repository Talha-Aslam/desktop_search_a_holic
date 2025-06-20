import 'package:desktop_search_a_holic/change_password.dart';
import 'package:desktop_search_a_holic/chatBot.dart';
import 'package:desktop_search_a_holic/imports.dart';
import 'package:desktop_search_a_holic/addProduct.dart';
import 'package:desktop_search_a_holic/editProduct.dart';
import 'package:desktop_search_a_holic/invoice.dart';
import 'package:desktop_search_a_holic/newOrder.dart';
import 'package:desktop_search_a_holic/pos_enhanced.dart' as enhanced;
import 'package:desktop_search_a_holic/product.dart';
import 'package:desktop_search_a_holic/profile.dart';
import 'package:desktop_search_a_holic/reports.dart';
import 'package:desktop_search_a_holic/sales.dart';
import 'package:desktop_search_a_holic/settings_page.dart';
import 'package:desktop_search_a_holic/splash.dart';
import 'package:desktop_search_a_holic/theme_provider.dart';
import 'package:desktop_search_a_holic/uploadData.dart';
import 'package:desktop_search_a_holic/backup_history_page.dart';
import 'package:desktop_search_a_holic/auto_backup_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await createFilesAndFolders();

  // Initialize auto backup service
  await AutoBackupService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Desktop Search A Holic',
      theme: themeProvider.themeData,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/profile': (context) => const Profile(),
        '/products': (context) => const Product(),
        '/addProduct': (context) => const AddProduct(),
        '/editProduct': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final productId = arguments?['productId'] as String? ?? '';
          return EditProduct(productID: productId);
        },
        '/invoices': (context) => const Invoice(),
        '/reports': (context) => const Reports(),
        '/chatBot': (context) => ChatBotPage(),
        '/changePassword': (context) => const ChangePassword(),
        '/login': (context) => const Login(),
        '/newOrder': (context) => const NewOrder(),
        '/registration': (context) => const Registration(),
        '/sales': (context) => const Sales(),
        '/uploadData': (context) => const UploadData(),
        '/settings': (context) => const SettingsPage(),
        '/pos': (context) => const enhanced.POS(),
        '/backup-history': (context) => const BackupHistoryPage(),
      },
    );
  }
}

Future<void> createFilesAndFolders() async {
  try {
    // Check if we're running on web platform
    if (kIsWeb) {
      print('Running on web platform - file operations are limited');
      return;
    }

    // Creating A Folder in the Document Directory
    Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    String path = directory.path;
    Directory folder = Directory('$path/SeachAHolic');

    // IF There is No Folder in the Document Directory
    if (!folder.existsSync()) {
      folder.create();
      print('Folder created at ${folder.path}');
    } else {
      print('Folder already exists at ${folder.path}');
    }

    // List of files to create
    List<String> filesToCreate = ['products.csv', 'user.json', 'logs.txt'];

    for (String fileName in filesToCreate) {
      File file = File('${folder.path}/$fileName');
      if (!file.existsSync()) {
        await file.create();
        print("$fileName File Created");
      }
    }
  } catch (e) {
    print('Error creating files and folders: $e');
    // Continue app execution even if file creation fails
  }
}
