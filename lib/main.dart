import 'package:desktop_search_a_holic/change_password.dart';
import 'package:desktop_search_a_holic/imports.dart';
import 'package:desktop_search_a_holic/addProduct.dart';
import 'package:desktop_search_a_holic/biCharts.dart';
import 'package:desktop_search_a_holic/editProduct.dart';
import 'package:desktop_search_a_holic/invoice.dart';
import 'package:desktop_search_a_holic/newOrder.dart';
import 'package:desktop_search_a_holic/product.dart';
import 'package:desktop_search_a_holic/profile.dart';
import 'package:desktop_search_a_holic/reports.dart';
import 'package:desktop_search_a_holic/sales.dart';
import 'package:desktop_search_a_holic/splash.dart';
import 'package:desktop_search_a_holic/uploadData.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Search A Holic',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/dashboard': (context) => const Dashboard(),
        '/profile': (context) => const Profile(),
        '/products': (context) => const Product(),
        '/addProduct': (context) => const AddProduct(),
        '/editProduct': (context) =>
            const EditProduct(productID: '1'), // Dummy productID
        '/invoices': (context) => const Invoice(),
        '/reports': (context) => const Reports(),
        '/biCharts': (context) => const BiCharts(),
        '/changePassword': (context) => const ChangePassword(),
        '/login': (context) => const Login(),
        '/newOrder': (context) => const NewOrder(),
        '/registration': (context) => const Registration(),
        '/sales': (context) => const Sales(),
        '/uploadData': (context) => const UploadData(),
      },
    );
  }
}

void createFilesAndFolders() async {
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
}
