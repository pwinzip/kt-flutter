import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktmobileapp/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../components/enterprise_drawer.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  String? _username;
  String? _entname;
  int? _entid;
  String? _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getSales() async {
    var url = Uri.parse(apiURL + 'sales/$_entid');

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
        automaticallyImplyLeading: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined)),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.logout),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 2, child: Text('ออกจากระบบ')),
              ];
            },
            onSelected: (value) async {
              if (value == 2) {
                var response = await logout(_token!);
                if (response.statusCode == 200) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ));
                }
              }
            },
          ),
        ],
      ),
      drawer: createEnterpriseDrawer(context, _username!, _entname!),
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
            child: Text(_username!),
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
}
