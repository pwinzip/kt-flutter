import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_page.dart';
import 'admin_show_enterprise.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? _username;
  String? _token;
  String? _amountEnterprise;
  String? _amountFarmer;

  bool isLoading = true;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _token = prefs.getString("token")!;
    });

    var response = await getAmountMember(_token);
    setState(() {
      _amountEnterprise =
          jsonDecode(response.body)['countEnterprise'].toString();
      _amountFarmer = jsonDecode(response.body)['countFarmer'].toString();
      isLoading = false;
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
        title: const Text('ผู้ดูแลระบบ'),
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
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(8),
          child: isLoading
              ? const Text('loading')
              : ListView(
                  children: [
                    summaryCard(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget summaryCard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          adminCard('จำนวนกลุ่มวิสาหกิจ', _amountEnterprise, 'กลุ่ม', true),
          adminCard('จำนวนเกษตรกร', _amountFarmer, 'คน', false),
        ],
      ),
    );
  }

  Widget adminCard(String str, String? amount, String unit, bool isAdd,
      [String addText = 'เพิ่มกลุ่มวิสาหกิจ']) {
    return Card(
      color: Colors.green[100],
      child: Container(
        width: 160,
        height: 140,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(str,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: Colors.blue[900],
                )),
            const SizedBox(height: 16),
            Text(
              amount!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            // const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(unit)],
            ),
            isAdd
                ? TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminShowEnterprise(),
                          ));
                    },
                    child: Text(
                      'เพิ่มกลุ่มวิสาหกิจ',
                      style: TextStyle(color: Colors.blue[600]),
                    ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
