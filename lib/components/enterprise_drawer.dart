import 'package:flutter/material.dart';

import '../screens/enterprise_page.dart';
import '../screens/member_page.dart';

Drawer createEnterpriseDrawer(
    BuildContext context, String username, String entname) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        createEnterpriseDrawerHeader(username, entname),
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
        ListTile(
          leading: const Icon(Icons.shopping_cart_outlined),
          title: const Text('แจ้งความต้องการขาย'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnterprisePage(),
                ));
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.shopping_bag_outlined),
        //   title: const Text('รายการแจ้งความต้องการขาย'),
        //   onTap: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const SalePage(),
        //         ));
        //   },
        // ),
      ],
    ),
  );
}

DrawerHeader createEnterpriseDrawerHeader(String username, String entname) {
  return DrawerHeader(
    decoration: const BoxDecoration(
      color: Colors.lightBlue,
    ),
    child: Stack(
      children: [
        Positioned(
          bottom: 36.0,
          left: 16.0,
          child: Text("ชื่อ: $username"),
        ),
        Positioned(
          bottom: 12.0,
          left: 16.0,
          child: Text('กลุ่มที่ดูแล: $entname'),
        ),
      ],
    ),
  );
}
