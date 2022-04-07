import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_page.dart';
import 'admin_add_member.dart';

class AdminShowMembers extends StatefulWidget {
  const AdminShowMembers(
      {Key? key, this.entid, this.entname, this.agentname, this.tel})
      : super(key: key);

  final int? entid;
  final String? entname;
  final String? agentname;
  final String? tel;

  @override
  State<AdminShowMembers> createState() => _AdminShowMembersState();
}

class _AdminShowMembersState extends State<AdminShowMembers> {
  String? _username;
  String? _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _token = prefs.getString("token")!;
    });
  }

  Future<String?> getEnterpriseMemberList() async {
    var response = await getAllEnterpriseMembers(widget.entid, _token);

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
        title: const Text('รายชื่อเกษตรกรในกลุ่ม'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                enterpriseName(),
                agentInfo(),
                const SizedBox(height: 12),
                addMemberBtn(context),
                const SizedBox(height: 12),
                showMemberList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding agentInfo() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.person_pin_outlined),
          const SizedBox(width: 12),
          Text(
            widget.agentname!,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(width: 24),
          const Icon(Icons.phone_android),
          const SizedBox(width: 12),
          Text(
            widget.tel!,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Padding enterpriseName() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        widget.entname!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Row addMemberBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
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
                    builder: (context) =>
                        AdminAddMember(enterpriseId: widget.entid),
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
                      'เพิ่มสมาชิกเกษตรกร',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget showMemberList() {
    return FutureBuilder(
      future: getEnterpriseMemberList(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          print(snapshot.data.toString());
          List? members = jsonDecode(snapshot.data.toString());

          if (members!.isEmpty) {
            myList = [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('ไม่พบข้อมูล'),
              )
            ];
          } else {
            myList = [
              Column(
                children: members.map((item) {
                  return ListTile(
                    title: Text(item['user']['name']),
                    subtitle: Text(item['user']['tel']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.lightBlue,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                        ),
                      ],
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
    //     title: const Text("นายสมศักดิ์ คงทน"),
    //     subtitle: const Text("0893251489"),
    //     trailing: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         IconButton(
    //           onPressed: () {},
    //           icon: const Icon(
    //             Icons.info_outline,
    //             color: Colors.lightBlue,
    //           ),
    //         ),
    //         IconButton(
    //           onPressed: () {},
    //           icon: const Icon(
    //             Icons.edit,
    //             color: Colors.orange,
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
