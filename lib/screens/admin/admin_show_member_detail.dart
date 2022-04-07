import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class AdminMemberDetail extends StatefulWidget {
  const AdminMemberDetail({Key? key}) : super(key: key);

  @override
  State<AdminMemberDetail> createState() => _AdminMemberDetailState();
}

class _AdminMemberDetailState extends State<AdminMemberDetail> {
  String? _username;
  String? _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _token = prefs.getString("token")!;
    });
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
        title: const Text('ข้อมูลเกษตรกร'),
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
          child: Column(),
        ),
      ),
    );
  }
}
