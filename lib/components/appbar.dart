import 'package:flutter/material.dart';

import '../screens/plant_page.dart';

Drawer createFarmerDrawer(BuildContext context, String username,
    String enterprisename, String agentname) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        createFarmerDrawerHeader(username, enterprisename, agentname),
        ListTile(
          leading: const Icon(Icons.local_florist),
          title: const Text('บันทึกการปลูก'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.library_books_outlined),
          title: const Text('รายการปลูก'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlantPage(),
                ));
          },
        ),
      ],
    ),
  );
}

DrawerHeader createFarmerDrawerHeader(
    String username, String enterprisename, String agentname) {
  return DrawerHeader(
    decoration: const BoxDecoration(
      color: Colors.lightBlue,
    ),
    child: Stack(
      children: [
        Positioned(
          bottom: 60.0,
          left: 16.0,
          child: Text('ชื่อ $username'),
        ),
        Positioned(
          bottom: 36.0,
          left: 16.0,
          child: Text('กลุ่มที่สังกัด: $enterprisename'),
        ),
        Positioned(
          bottom: 12.0,
          left: 16.0,
          child: Text('ตัวแทนกลุ่ม: $agentname'),
        ),
      ],
    ),
  );
}
