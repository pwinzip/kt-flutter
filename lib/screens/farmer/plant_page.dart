import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ktmobileapp/screens/login_page.dart';
import 'package:ktmobileapp/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/farmer_drawer.dart';
import '../../services/auth_service.dart';

class PlantPage extends StatefulWidget {
  const PlantPage({Key? key}) : super(key: key);

  @override
  State<PlantPage> createState() => _PlantPageState();
}

class _PlantPageState extends State<PlantPage> {
  // late int _id;
  late String _username;
  late int _farmerid;
  late String _enterprisename;
  late String _agentname;
  late String _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      // _id = prefs.getInt('userid')!;
      _farmerid = prefs.getInt('farmerid')!;
      _enterprisename = prefs.getString("enterprisename")!;
      _agentname = prefs.getString("agentname")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getPlantList() async {
    var response = await getAllPlants(_farmerid, _token);

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
        title: const Text('รายการปลูกพืชกระท่อม'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.person),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 1, child: Text('ข้อมูลส่วนตัว')),
                const PopupMenuItem(value: 2, child: Text('ออกจากระบบ')),
              ];
            },
            onSelected: (value) async {
              if (value == 2) {
                var response = await logout(_token);
                if (response.statusCode == 200) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ));
                }
              } else if (value == 1) {
                print('Go to profile');
              }
            },
          ),
        ],
      ),
      drawer:
          createFarmerDrawer(context, _username, _enterprisename, _agentname),
      body: showPlantList(),
    );
  }

  showPlantList() {
    return FutureBuilder(
      future: getPlantList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List? plants = jsonString['payload'];

          if (plants!.isEmpty) {
            myList = [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('ไม่พบข้อมูล'),
              )
            ];
          } else {
            myList = [
              Column(
                children: plants.map((item) {
                  DateTime parsedCreatedDate =
                      DateTime.parse(item['created_at']);
                  DateTime parsedDateSale =
                      DateTime.parse(item['date_for_sale']);
                  var createdDate =
                      DateFormat('dd/MM/yyyy').format(parsedCreatedDate);
                  var dateForSale =
                      DateFormat('dd/MM/yyyy').format(parsedDateSale);
                  return Container(
                    padding: const EdgeInsets.all(4),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              'ข้อมูล ณ วันที่ ' + createdDate.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('คงอยู่ '),
                                      Text(item['remain_plant'].toString() +
                                          ' ต้น'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('ปลูกเพิ่ม '),
                                      Text(item['addon_plant'].toString() +
                                          ' ต้น'),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('วันที่เก็บได้ '),
                                      Text(dateForSale.toString()),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Text('ปริมาณที่จะเก็บได้ '),
                                      Text(
                                          item['quantity_for_sale'].toString() +
                                              ' กิโลกรัม'),
                                    ],
                                  ),
                                ),
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
}
