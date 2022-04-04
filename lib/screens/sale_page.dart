import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'enterprise_page.dart';
import 'login_page.dart';
import 'member_page.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  late String _name;
  late String _entname;
  late int _entid;
  late String _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getSales() async {
    var url =
        Uri.parse('https://kt-laravel-backend.herokuapp.com/api/sales/$_entid');

    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    print(response.statusCode);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการต้องการขายพืชกระท่อม'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            createDrawerHeader(),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('แจ้งความต้องการขาย'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnterprisePage(),
                    ));
              },
            ),
            ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('รายการแจ้งความต้องการขาย'),
                onTap: () {}),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('สมาชิกในกลุ่ม'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberPage(),
                    ));
              },
            ),
          ],
        ),
      ),
      body: showSaleList(),
    );
  }

  showSaleList() {
    return FutureBuilder(
      future: getSales(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List? sales = jsonString['payload'];

          if (sales!.isEmpty) {
            myList = [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('ไม่พบข้อมูล'),
              )
            ];
          } else {
            myList = [
              Column(
                children: sales.map((item) {
                  DateTime parsedCreatedDate =
                      DateTime.parse(item['created_at']);
                  DateTime parsedSellDate =
                      DateTime.parse(item['date_for_sell']);
                  var createdDate =
                      DateFormat('dd/MM/yyyy').format(parsedCreatedDate);
                  var sellDate =
                      DateFormat('dd/MM/yyyy').format(parsedSellDate);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(createdDate.toString()),
                            Column(
                              children: [
                                const Text('วันที่ต้องการขาย'),
                                Text(sellDate.toString()),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('จำนวนที่ต้องการขาย'),
                                Text(item['quantity_for_sell'].toString() +
                                    ' กิโลกรัม'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ];
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          myList = [
            const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('อยู่ระหว่างประมวลผล'),
            )
          ];
        }

        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  DrawerHeader createDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 36.0,
            left: 16.0,
            child: Text(_name),
          ),
          Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text('กลุ่มที่ดูแล: $_entname'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    var url = Uri.parse('https://kt-laravel-backend.herokuapp.com/api/logout');
    var response = await http.post(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
    }
  }
}
