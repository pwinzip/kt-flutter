import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_page.dart';

class AdminAddEnterprise extends StatefulWidget {
  const AdminAddEnterprise({Key? key}) : super(key: key);

  @override
  State<AdminAddEnterprise> createState() => _AdminAddEnterpriseState();
}

class _AdminAddEnterpriseState extends State<AdminAddEnterprise> {
  String? _username;
  String? _token;

  final _enterpriseFormKey = GlobalKey<FormState>();

  final TextEditingController _entNo = TextEditingController();
  final TextEditingController _entName = TextEditingController();
  final TextEditingController _entAddress = TextEditingController();
  final TextEditingController _entAgentName = TextEditingController();
  final TextEditingController _entAgentTel = TextEditingController();
  final TextEditingController _entAgentPassword = TextEditingController();

  bool _entStatus = true;

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
        title: const Text('ผู้ดูแลระบบ'),
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
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          margin: const EdgeInsets.all(8),
          child: ListView(
            children: [
              addInputForm(),
              saveFormBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addInputForm() {
    return Form(
        key: _enterpriseFormKey,
        child: Column(
          children: [
            entNoTextInput(),
            entNameTextInput(),
            entAddressTextInput(),
            entAgentNameTextInput(),
            entAgentTelTextInput(),
            entAgentPasswordTextInput(),
            switchStatus(),
          ],
        ));
  }

  Widget entNoTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entNo,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่รหัสกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration: createInputDecoration("รหัสกลุ่มวิสาหกิจ"),
      ),
    );
  }

  Widget entNameTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entName,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ชื่อกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration: createInputDecoration("ชื่อกลุ่มวิสาหกิจ"),
      ),
    );
  }

  Widget entAddressTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entAddress,
        minLines: 2,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ที่อยู่ของกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration: createInputDecoration("ที่อยู่กลุ่มวิสาหกิจ"),
      ),
    );
  }

  Widget entAgentNameTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entAgentName,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ชื่อ-นามสกุลของตัวแทนกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration: createInputDecoration("ชื่อ-นามสกุลของตัวแทนกลุ่มวิสาหกิจ"),
      ),
    );
  }

  Widget entAgentTelTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entAgentTel,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่เบอร์โทรศัพท์ของตัวแทนกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration:
            createInputDecoration("เบอร์โทรศัพท์ของตัวแทนกลุ่มวิสาหกิจ"),
      ),
    );
  }

  Widget entAgentPasswordTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _entAgentPassword,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่รหัสผ่านของตัวแทนกลุ่มวิสาหกิจ";
          }
          return null;
        },
        decoration: createInputDecoration("รหัสผ่านของตัวแทนกลุ่มวิสาหกิจ"),
      ),
    );
  }

  InputDecoration createInputDecoration(String labelText) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.green),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: Colors.red),
      ),
      label: Text(
        labelText,
        style: TextStyle(color: Colors.green[800]),
      ),
    );
  }

  SwitchListTile switchStatus() {
    return SwitchListTile(
        title: const Text('สถานะ'),
        value: _entStatus,
        onChanged: (value) {
          setState(() {
            _entStatus = value;
          });
        });
  }

  Widget saveFormBtn() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: saveBtn(),
          ),
        ],
      ),
    );
  }

  Widget saveBtn() {
    return SizedBox(
      height: 40,
      width: 150,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.save),
            Text('บันทึกข้อมูล'),
          ],
        ),
        onPressed: () async {
          if (_enterpriseFormKey.currentState!.validate()) {
            var json = jsonEncode({
              "registNo": _entNo.text,
              "enterpriseName": _entName.text,
              "enterpriseAddress": _entAddress.text,
              "agentName": _entAgentName.text,
              "agentTel": _entAgentTel.text,
              "agentPassword": _entAgentPassword.text,
              "isActive": _entStatus ? 1 : 0,
            });
            var response = await addEnterprise(json, _token);
            print(response.statusCode);

            if (response.statusCode == 200) {
              print("successful");
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
