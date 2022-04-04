import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ktmobileapp/screens/sale_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'enterprise_page.dart';
import 'login_page.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late String _name;
  late String _entname;
  late String _token;
  late int _entid;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getMembers() async {
    var url = Uri.parse(
        'https://kt-laravel-backend.herokuapp.com/api/members/$_entid');

    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalePage(),
                      ));
                }),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('สมาชิกในกลุ่ม'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: showMemberList(),
    );
  }

  showMemberList() {
    return FutureBuilder(
      future: getMembers(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List? farmers = jsonString['payload'];
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
                                    Text(
                                      item['address'].toString(),
                                      softWrap: true,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.phone),
                                    Text(
                                      item['tel'].toString(),
                                      softWrap: true,
                                      style: TextStyle(color: Colors.grey[700]),
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
                                    Text(
                                      item['growing_area'].toString() + ' ไร่',
                                      style: TextStyle(color: Colors.grey[700]),
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
