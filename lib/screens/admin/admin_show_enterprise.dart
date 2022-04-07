import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_page.dart';
import 'admin_add_enterprise.dart';
import 'admin_show_member.dart';

class AdminShowEnterprise extends StatefulWidget {
  const AdminShowEnterprise({Key? key}) : super(key: key);

  @override
  State<AdminShowEnterprise> createState() => _AdminShowEnterpriseState();
}

class _AdminShowEnterpriseState extends State<AdminShowEnterprise> {
  String? _username;
  String? _token;

  bool isLoading = true;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getEnterpriseList() async {
    var response = await getAllEnterprises(_token);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ดูรายชื่อกลุ่มวิสาหกิจ'),
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
      drawer: createAdminDrawer(context, _username!),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                addEnterpriseBtn(context),
                const SizedBox(height: 12),
                showEnterpriseList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addEnterpriseBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAddEnterprise(),
                  )).then((value) {
                setState(() {});
              });
            },
            child: Row(
              children: const [
                Icon(Icons.add, color: Colors.white),
                Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      'เพิ่มกลุ่มวิสาหกิจ',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget showEnterpriseList() {
    return FutureBuilder(
      future: getEnterpriseList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          List? enterprises = jsonDecode(snapshot.data.toString());

          if (enterprises!.isEmpty) {
            myList = [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('ไม่พบข้อมูล'),
              )
            ];
          } else {
            myList = [
              Column(
                children: enterprises.map((item) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(item['enterprise']['regist_no'] +
                          ": " +
                          item['enterprise']['enterprise_name']),
                      subtitle: Text(item['agent']['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminShowMembers(
                                        entid: item['enterprise']['id'],
                                        entname: item['enterprise']
                                            ['enterprise_name'],
                                        agentname: item['agent']['name'],
                                        tel: item['agent']['tel']),
                                  )).then((value) {
                                setState(() {});
                              });
                            },
                            icon: const Icon(
                              Icons.remove_red_eye_rounded,
                              color: Colors.lightBlue,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.lightGreen,
                            ),
                          ),
                        ],
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

    // myList.add(
    //   ListTile(
    //     title: const Text("วิสาหกิจชุมชนกระท่อมสมุนไพร"),
    //     subtitle: const Text("นางปราณี สวยงาม"),
    //     trailing: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         IconButton(
    //           onPressed: () {
    //             Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) => const AdminShowMembers(entid: 1),
    //                 ));
    //           },
    //           icon: const Icon(
    //             Icons.remove_red_eye_rounded,
    //             color: Colors.lightBlue,
    //           ),
    //         ),
    //         IconButton(
    //           onPressed: () {},
    //           icon: const Icon(
    //             Icons.edit,
    //             color: Colors.lightGreen,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    // return Center(
    //   child: Column(children: myList),
    // );
  }
}
