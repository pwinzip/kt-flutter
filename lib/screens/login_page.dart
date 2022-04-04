import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:ktmobileapp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_page.dart';
import 'enterprise_page.dart';
import 'farmer_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _telController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String? errText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          // width: MediaQuery.of(context).size.width,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/balloon-lg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Color.fromARGB(150, 255, 255, 255),
              ),
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      logo(),
                      telInput(),
                      passwordInput(),
                      formBtn(),
                      customerText(),
                      errText != null
                          ? Text(
                              errText!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : const Text(''),
                      notifyText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  telInput() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: TextFormField(
        controller: _telController,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่เบอร์โทรศัพท์';
          }
          return null;
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
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
          prefixIcon: const Icon(
            Icons.phone_android,
            color: Colors.green,
          ),
          label: Text(
            'เบอร์โทรศัพท์',
            style: TextStyle(color: Colors.green[800]),
          ),
        ),
      ),
    );
  }

  passwordInput() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: TextFormField(
        obscureText: true,
        controller: _passController,
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่รหัสผ่าน';
          }
          return null;
        },
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
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
          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.green,
          ),
          label: Text(
            'รหัสผ่าน',
            style: TextStyle(color: Colors.green[800]),
          ),
        ),
      ),
    );
  }

  formBtn() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: loginBtn(),
          ),
        ],
      ),
    );
  }

  loginBtn() {
    return SizedBox(
      height: 40,
      width: 130,
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
            Text('เข้าสู่ระบบ'),
            Icon(Icons.login),
          ],
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var response =
                await login(_telController.text, _passController.text);

            print(response.statusCode);
            print(response.body);

            if (response.statusCode == 200) {
              setState(() {
                errText = null;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var useridJson = jsonDecode(response.body)['user']['id'];
              var nameJson = jsonDecode(response.body)['user']['name'];
              var roleJson = jsonDecode(response.body)['user']['role'];
              var tokenJson = jsonDecode(response.body)['token'];

              await prefs.setInt('userid', useridJson);
              await prefs.setString('username', nameJson);
              await prefs.setString('token', tokenJson);

              if (roleJson == 2) {
                var farmeridJson = jsonDecode(response.body)['farmer']['id'];
                var entnameJson =
                    jsonDecode(response.body)['enterprise']['enterprise_name'];
                var agentnameJson = jsonDecode(response.body)['agent']['name'];

                await prefs.setInt('farmerid', farmeridJson);
                await prefs.setString('enterprisename', entnameJson);
                await prefs.setString('agentname', agentnameJson);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerPage(),
                  ),
                );
              } else if (roleJson == 1) {
                var entidJson = jsonDecode(response.body)['enterprise']['id'];
                var entnameJson =
                    jsonDecode(response.body)['enterprise']['enterprise_name'];
                await prefs.setInt('enterpriseid', entidJson);
                await prefs.setString('enterprisename', entnameJson);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnterprisePage(),
                  ),
                );
              } else if (roleJson == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPage(),
                  ),
                );
              }
            } else {
              // Toast
              setState(() {
                errText = "เบอร์โทรศัพท์ หรือ รหัสผ่านไม่ถูกต้อง";
              });
            }
          }
        },
      ),
    );
  }

  logo() {
    return SizedBox(
      width: 120,
      child: Image.asset(
        'assets/logos/logo-kt.png',
        fit: BoxFit.cover,
      ),
    );
  }

  customerText() {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 250,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('แจ้งความต้องการผลิตภัณฑ์พืชกระท่อม'),
          TextButton(onPressed: () {}, child: const Text('กดที่นี่'))
        ],
      ),
    );
  }

  notifyText() {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 250,
      child: const Text(
        '*** สมาคมพืชกระท่อมแห่งประเทศไทยเป็นเพียงตัวกลางเก็บรวบรวมข้อมูลความต้องการของตลาดเท่านั้น ***',
        softWrap: true,
        style: TextStyle(
          color: Colors.deepOrange,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
