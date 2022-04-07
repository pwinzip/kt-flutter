import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ktmobileapp/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import '../../components/enterprise_drawer.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late String _username;
  late String _entname;
  late String _token;
  late int _entid;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getMembersList() async {
    var response = await getMembers(_entid, _token);

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
        title: const Text('สมาชิกในกลุ่ม'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.person),
            itemBuilder: (context) {
              return [
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
              }
            },
          ),
        ],
      ),
      drawer: createEnterpriseDrawer(context, _username, _entname),
      body: showMemberList(),
    );
  }

  showMemberList() {
    return FutureBuilder(
      future: getMembersList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List? farmers = jsonString['payload'];
          print(snapshot.data.toString());
          myList = [
            Column(
              children: farmers!.map((item) {
                // DateTime parsedCreatedDate = DateTime.parse(item['created_at']);
                // var createdDate =
                //     DateFormat('dd/MM/yyyy').format(parsedCreatedDate);

                return Container(
                  padding: const EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${item['name']}',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.phone),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '${item['tel']}',
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.place),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        item['address'].toString(),
                                        softWrap: true,
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.area_chart),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        item['area'].toString() + ' ไร่',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.local_florist_outlined),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        item['remain'].toString() + ' ต้น',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ),
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
            child: Text(_username),
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
