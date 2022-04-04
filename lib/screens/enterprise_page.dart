import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import 'login_page.dart';
import 'member_page.dart';
import 'sale_page.dart';

class EnterprisePage extends StatefulWidget {
  const EnterprisePage({Key? key}) : super(key: key);

  @override
  State<EnterprisePage> createState() => _EnterprisePageState();
}

class _EnterprisePageState extends State<EnterprisePage> {
  final _entFormKey = GlobalKey<FormState>();
  final TextEditingController _saleDate = TextEditingController();
  final TextEditingController _saleAmount = TextEditingController();
  late String _name;
  late String _entname;
  late int _entid;
  late String _token;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
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
        title: const Text('แจ้งความต้องการขายพืชกระท่อม'),
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
              onTap: () {},
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('สมาชิกในกลุ่ม'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberPage(),
                    ));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.all(32),
          child: Form(
            key: _entFormKey,
            child: ListView(
              children: [
                saleDateInput(),
                saleAmountInput(),
                saveForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  saleDateInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _saleDate,
        readOnly: true,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาเลือกวันที่ต้องการขาย';
          }
          return null;
        },
        onTap: () {
          var _alertDialog = AlertDialog(
            content: datePicker(),
          );
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return _alertDialog;
              });
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          label: Text(
            'วันที่ต้องการขาย',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _saleDate.text = DateFormat('dd/MM/yyyy').format(args.value);
    });
    Navigator.pop(context);
  }

  Widget datePicker() {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.height * 0.5,
      child: SfDateRangePicker(
        showNavigationArrow: true,
        showActionButtons: true,
        onSubmit: (value) {
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
        onSelectionChanged: _onSelectionChanged,
        selectionMode: DateRangePickerSelectionMode.single,
        enablePastDates: false,
        minDate: DateTime.now().add(const Duration(days: 7)),
        // initialSelectedRange: PickerDateRange(
        //   DateTime.now(),
        //   DateTime.now().add(const Duration(days: 60)),
        // ),
      ),
    );
  }

  saleAmountInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _saleAmount,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่ปริมาณที่ต้องการขาย';
          }
          return null;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          label: Text(
            'ปริมาณที่ต้องการขาย (กิโลกรัม)',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  saveForm() {
    return Container(
      margin: const EdgeInsets.all(16),
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

  saveBtn() {
    return SizedBox(
      height: 40,
      width: 200,
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
            Text('แจ้งความต้องการขาย'),
          ],
        ),
        onPressed: () async {
          if (_entFormKey.currentState!.validate()) {
            var json = jsonEncode({
              "saleDate": _saleDate.text,
              "saleAmount": _saleAmount.text,
            });

            var url = Uri.parse(
                'https://kt-laravel-backend.herokuapp.com/api/addsales/$_entid');

            var response = await http.post(url, body: json, headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            });
            print(response.statusCode);
          }
        },
      ),
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
