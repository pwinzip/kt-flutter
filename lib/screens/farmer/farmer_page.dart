import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ktmobileapp/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import '../../components/farmer_drawer.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class FarmerPage extends StatefulWidget {
  const FarmerPage({Key? key}) : super(key: key);

  @override
  State<FarmerPage> createState() => _FarmerPageState();
}

class _FarmerPageState extends State<FarmerPage> {
  final _farmerFormKey = GlobalKey<FormState>();

  final TextEditingController _remainAmount = TextEditingController();
  final TextEditingController _addonAmount = TextEditingController();
  final TextEditingController _addonSpecies = TextEditingController();
  final TextEditingController _expectedDate = TextEditingController();
  final TextEditingController _expectedAmount = TextEditingController();

  late String _username;
  late int _farmerid;
  late String _enterprisename;
  late String _agentname;
  late String _token;

  String? _remainPlants;
  String? _addonPlants;
  bool isLoading = true;

  Future<void> getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username")!;
      _farmerid = prefs.getInt('farmerid')!;
      _enterprisename = prefs.getString("enterprisename")!;
      _agentname = prefs.getString("agentname")!;
      _token = prefs.getString("token")!;
    });
    var response = await getPlantAmount(_farmerid, _token);
    setState(() {
      _remainPlants = jsonDecode(response.body)['remain'].toString();
      _addonPlants = jsonDecode(response.body)['addon'].toString();
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
    _expectedDate.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('?????????????????????????????????????????????????????????????????????'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.person),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 1, child: Text('???????????????????????????????????????')),
                const PopupMenuItem(value: 2, child: Text('??????????????????????????????')),
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
              } else if (value == 1) {
                print('Go to profile');
              }
            },
          ),
        ],
      ),
      drawer:
          createFarmerDrawer(context, _username, _enterprisename, _agentname),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.all(8),
          child: isLoading
              ? const Text('loading')
              : ListView(
                  children: [
                    summaryCard(),
                    inputForm(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget inputForm() {
    return Form(
      key: _farmerFormKey,
      child: Column(
        children: [
          inputTextBox(_remainAmount, '???????????????????????????????????????????????????',
              '????????????????????????????????????????????????????????????????????????????????????????????????', true, 1, 1, true, "?????????"),
          inputTextBox(_addonAmount, '????????????????????????????????????????????????????????????',
              '????????????????????????????????????????????????????????????????????????????????????', true, 1, 1, true, "?????????"),
          inputTextBox(_addonSpecies, '???????????????????????????????????????????????????????????????',
              '???????????????????????????????????????????????????????????????????????????????????????', false, 2, 3, false, "", true),
          expectedDateInput(),
          inputTextBox(
              _expectedAmount,
              '?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????',
              '?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????',
              true,
              1,
              1,
              true,
              "????????????????????????"),
          saveForm(),
        ],
      ),
    );
  }

  Widget summaryCard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          plantCard('??????????????????', _remainPlants),
          plantCard('???????????????????????????', _addonPlants),
        ],
      ),
    );
  }

  Widget plantCard(String str, String? amount) {
    return Card(
      color: Colors.green[100],
      child: Container(
        width: 150,
        height: 120,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              children: const [Text('?????????')],
            )
          ],
        ),
      ),
    );
  }

  Container inputTextBox(
    TextEditingController textCtrl,
    String labelText,
    String errText, [
    bool isNumber = true,
    int minline = 1,
    maxline = 1,
    isSuffix = true,
    suffText = "?????????",
    bool isMultiline = false,
  ]) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: textCtrl,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiline
                ? TextInputType.multiline
                : TextInputType.text,
        maxLines: maxline,
        minLines: minline,
        validator: (value) {
          if (value!.isEmpty) {
            return errText;
          }
          return null;
        },
        decoration: InputDecoration(
          suffixText: isSuffix ? suffText : null,
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
        ),
      ),
    );
  }

  expectedDateInput() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        controller: _expectedDate,
        readOnly: true,
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
            '????????????????????????????????????????????????????????????????????????',
            style: TextStyle(color: Colors.green[800]),
          ),
        ),
      ),
    );
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
        initialSelectedRange: PickerDateRange(
          DateTime.now(),
          DateTime.now().add(const Duration(days: 60)),
        ),
      ),
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _expectedDate.text = DateFormat('dd/MM/yyyy').format(args.value);
    });
    Navigator.pop(context);
  }

  saveForm() {
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

  saveBtn() {
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
            Text('????????????????????????????????????'),
          ],
        ),
        onPressed: () async {
          if (_farmerFormKey.currentState!.validate()) {
            // check valid tel and password
            var json = jsonEncode({
              "remain": _remainAmount.text,
              "addonAmount": _addonAmount.text,
              "addonSpecies": _addonSpecies.text,
              "expectedDate": _expectedDate.text,
              "expectedAmount": _expectedAmount.text,
            });

            var response = await saveFarmerPlant(json, _farmerid, _token);

            print(response.statusCode);

            if (response.statusCode == 200) {
              print("successful");
              setState(() {});
            }
          }
        },
      ),
    );
  }
}
