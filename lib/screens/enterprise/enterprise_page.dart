import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ktmobileapp/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import '../../components/enterprise_drawer.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class EnterprisePage extends StatefulWidget {
  const EnterprisePage({Key? key}) : super(key: key);

  @override
  State<EnterprisePage> createState() => _EnterprisePageState();
}

class _EnterprisePageState extends State<EnterprisePage> {
  final _entFormKey = GlobalKey<FormState>();
  final TextEditingController _saleDate = TextEditingController();
  final TextEditingController _saleAmount = TextEditingController();

  late String _username;
  late String _entname;
  late int _entid;
  late String _token;

  String? plants;
  String? members;

  bool isLoading = true;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _entname = prefs.getString("enterprisename")!;
      _entid = prefs.getInt("enterpriseid")!;
      _token = prefs.getString("token")!;
    });
    // Get member and plant belongs to the enterprise

    // Set _plants and _ members
  }

  Future<String?> getSales() async {
    var url = Uri.parse(apiURL + 'sales/$_entid');

    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    });

    print(response.statusCode);

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
        title: const Text('แจ้งความต้องการขายพืชกระท่อม'),
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                summaryCard(),
                inputForm(),
                saveForm(),
                const Divider(),
                const SizedBox(height: 8),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'รายการแจ้งความต้องการขาย',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                showSaleList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showSaleList() {
    return FutureBuilder(
      future: getSales(),
      builder: (context, snapshot) {
        List<Widget> myList = [];

        if (snapshot.hasData) {
          var jsonString = jsonDecode(snapshot.data.toString());
          List? sales = jsonString['payload'];

          if (sales!.isEmpty) {
            myList = [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'ไม่พบข้อมูล',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )
            ];
          } else {
            myList = [
              Column(
                children: sales.map((item) {
                  DateTime parsedCreatedDate =
                      DateTime.parse(item['created_at']);
                  DateTime parsedSellDate =
                      DateTime.parse(item['date_for_sell']);
                  var createdDate =
                      DateFormat('dd/MM/yyyy').format(parsedCreatedDate);
                  var sellDate =
                      DateFormat('dd/MM/yyyy').format(parsedSellDate);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(createdDate.toString()),
                            Column(
                              children: [
                                const Text('วันที่ต้องการขาย'),
                                Text(sellDate.toString()),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('จำนวนที่ต้องการขาย'),
                                Text(item['quantity_for_sell'].toString() +
                                    ' กิโลกรัม'),
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
  }

  Widget summaryCard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          enterpriseCard('จำนวนสมาชิก', 50.toString(), 'คน', Colors.blue[200]),
          enterpriseCard(
              'จำนวนต้นกระท่อม', 130.toString(), 'ต้น', Colors.lightGreen[100]),
        ],
      ),
    );
  }

  Widget enterpriseCard(String str, String? amount, String unit, Color? color) {
    return Card(
      color: color,
      child: Container(
        width: 155,
        height: 120,
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(unit)],
            )
          ],
        ),
      ),
    );
  }

  Widget inputForm() {
    return Form(
        key: _entFormKey,
        child: Column(
          children: [
            saleDateInput(),
            saleAmountInput(),
          ],
        ));
  }

  saleDateInput() {
    return Container(
      margin: const EdgeInsets.all(8),
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
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.calendar_month_outlined),
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
            'วันที่ต้องการขาย',
            style: TextStyle(color: Colors.green[800]),
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
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
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
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _saleAmount,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return 'กรุณาใส่ปริมาณที่ต้องการขาย';
          }
          return null;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.green),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.green),
          ),
          label: Text(
            'ปริมาณที่ต้องการขาย',
            style: TextStyle(color: Colors.green[800]),
          ),
          suffixText: 'กิโลกรัม',
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

            var url = Uri.parse(apiURL + 'addsales/$_entid');

            var response = await http.post(url, body: json, headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            });
            print(response.statusCode);
          }
        },
      ),
    );
  }
}
