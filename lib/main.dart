import 'package:flutter/material.dart';
import 'package:menbarc/fragments/dosingRatesPage.dart';
import 'package:menbarc/widgets/createDrawerBodyItem.dart';
import 'package:menbarc/widgets/createDrawerHeader.dart';
import 'package:package_info/package_info.dart';
import 'fragments/flowCalculatorPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menbarc Design Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeDrawerNavigationPage(title:'Menbarc Design Calculator'),
    );
  }
}

class HomeDrawerNavigationPage extends StatefulWidget {
  final String title;

  const HomeDrawerNavigationPage({Key key, this.title}) : super(key: key);
  @override
  State createState() {
    return _HomeDrawerNavigationPageState();
  }
}

class _HomeDrawerNavigationPageState extends State<HomeDrawerNavigationPage> {
  List<PageItem> pages = [
    PageItem("Flow Calculator", Icons.account_tree_outlined, flowCalculatorPage()),
    PageItem("Dosing Rates", Icons.ballot_outlined, dosingRatesPage()),
  ];

  int pageIndex = 0;

  String version = ""; //initialized to this string, so its not empty on start

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String packageName = packageInfo.packageName;
    String buildNumber = packageInfo.buildNumber;

    return '''$version''';
  }

  _HomeDrawerNavigationPageState() {
    getAppVersion().then((value) {
      setState(() {
        version = value;
      });
    }); // this is async, so it completes a bit later
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        appBar: AppBar(
          title: Text(pages[pageIndex].title),
        ),
        drawer: navigationDrawer(),
        body: Center(child: pages[pageIndex].widget));
  }

  Widget navigationDrawer() {
    List<Widget> drawerBodyItems = [];
    drawerBodyItems.add(createDrawerHeader(widget.title));
    for (int i = 0; i < pages.length; i++) {
      PageItem pageItem = pages[i];
      drawerBodyItems.add(createDrawerBodyItem(
          icon: pageItem.nav_icon,
          text: pageItem.title,
          onTap: () {
            setState(() {
              pageIndex = i;
            });
            Navigator.pop(context);
          }
      ));
    }
    drawerBodyItems.add(ListTile(
      title: Text('App version '+version),
      onTap: () {},
    ));
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: drawerBodyItems,
      ),
    );
  }
}

class PageItem {
  String title;
  IconData nav_icon;
  Widget widget;

  PageItem(this.title, this.nav_icon, this.widget);
}

