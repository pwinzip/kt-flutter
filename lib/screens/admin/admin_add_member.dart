import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/admin_drawer.dart';
import '../../services/auth_service.dart';
import '../../services/backend_service.dart';
import '../login_page.dart';

class AdminAddMember extends StatefulWidget {
  const AdminAddMember({Key? key, this.enterpriseId}) : super(key: key);

  final int? enterpriseId;

  @override
  State<AdminAddMember> createState() => _AdminAddMemberState();
}

class _AdminAddMemberState extends State<AdminAddMember> {
  String? _username;
  String? _token;

  final _memberFormKey = GlobalKey<FormState>();

  final TextEditingController _memberName = TextEditingController();
  final TextEditingController _memberAddress = TextEditingController();
  final TextEditingController _memberLat = TextEditingController();
  final TextEditingController _memberLong = TextEditingController();
  final TextEditingController _memberReceived = TextEditingController();
  final TextEditingController _memberArea = TextEditingController();
  final TextEditingController _memberTel = TextEditingController();
  final TextEditingController _memberPassword = TextEditingController();

  bool _memberStatus = true;

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
        key: _memberFormKey,
        child: Column(
          children: [
            const Text(
              "ข้อมูลส่วนตัว",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            memberNameTextInput(),
            memberAddressTextInput(),
            memberTelTextInput(),
            memberPasswordTextInput(),
            // memberEnterpriseDropdown(),
            const Divider(),
            const Text(
              "พิกัดแปลงปลูก",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
            memberLatTextInput(),
            memberLongTextInput(),
            memberAreaTextInput(),
            const Divider(),
            memberReceivedTextInput(),
            switchStatus(),
          ],
        ));
  }

  Widget memberNameTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberName,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ชื่อ-นามสกุล";
          }
          return null;
        },
        decoration: createInputDecoration("ชื่อ-นามสกุล"),
      ),
    );
  }

  Widget memberAddressTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberAddress,
        minLines: 2,
        maxLines: 3,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ที่อยู่";
          }
          return null;
        },
        decoration: createInputDecoration("ที่อยู่"),
      ),
    );
  }

  Widget memberAreaTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberArea,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่จำนวนพื้นที่ปลูก";
          }
          return null;
        },
        decoration: createInputDecoration("จำนวนพื้นที่ปลูก", "ไร่"),
      ),
    );
  }

  Widget memberLatTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberLat,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ละติจูดของแปลง";
          }
          return null;
        },
        decoration: createInputDecoration("ละติจูดของแปลง"),
      ),
    );
  }

  Widget memberLongTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberLong,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่ลองติจูดของแปลง";
          }
          return null;
        },
        decoration: createInputDecoration("ลองติจูดของแปลง"),
      ),
    );
  }

  Widget memberReceivedTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberReceived,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่จำนวนต้นที่ได้รับสนับสนุน";
          }
          return null;
        },
        decoration: createInputDecoration("จำนวนต้นที่ได้รับสนับสนุน", "ต้น"),
      ),
    );
  }

  Widget memberTelTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberTel,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่เบอร์โทรศัพท์ของเกษตรกร";
          }
          return null;
        },
        decoration: createInputDecoration("เบอร์โทรศัพท์ของเกษตรกร"),
      ),
    );
  }

  Widget memberPasswordTextInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _memberPassword,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value!.isEmpty) {
            return "กรุณาใส่รหัสผ่านของเกษตรกร";
          }
          return null;
        },
        decoration: createInputDecoration("ตั้งรหัสผ่านของเกษตรกร"),
      ),
    );
  }

  InputDecoration createInputDecoration(String labelText,
      [String suffText = ""]) {
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
      suffixText: suffText,
    );
  }

  SwitchListTile switchStatus() {
    return SwitchListTile(
        title: const Text('สถานะ'),
        value: _memberStatus,
        onChanged: (value) {
          setState(() {
            _memberStatus = value;
          });
        });
  }

  Widget saveFormBtn() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
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
            SizedBox(width: 4),
            Text('บันทึกข้อมูล'),
          ],
        ),
        onPressed: () async {
          if (_memberFormKey.currentState!.validate()) {
            var json = jsonEncode({
              "farmerName": _memberName.text,
              "farmerTel": _memberTel.text,
              "farmerPassword": _memberPassword.text,
              "farmerAddress": _memberAddress.text,
              "farmerArea": _memberArea.text,
              "farmerLat": _memberLat.text,
              "farmerLong": _memberLong.text,
              "farmerReceived": _memberReceived.text,
              "enterpriseId": widget.enterpriseId,
              "isActive": _memberStatus ? 1 : 0,
            });
            var response = await addFarmer(json, _token);
            print(response.statusCode);

            if (response.statusCode == 200) {
              print("successful");
              Navigator.pop(context);
            } else if (response.statusCode == 422) {
              print("Farmer Tel already exists");
            }
          }
        },
      ),
    );
  }
}
