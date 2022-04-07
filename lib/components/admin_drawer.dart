import 'package:flutter/material.dart';

import '../screens/admin/admin_page.dart';
import '../screens/admin/admin_manage_page.dart';
import '../screens/admin/admin_show_enterprise.dart';

Drawer createAdminDrawer(BuildContext context, String name) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        createAdminDrawerHeader(name),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('หน้าแรก'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminPage(),
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('จัดการผู้ดูแลระบบ'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminManagePage(),
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('จัดการกลุ่มวิสาหกิจ'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminShowEnterprise(),
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart_outlined),
          title: const Text('ดูรายการแจ้งความต้องการขาย'),
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const EnterprisePage(),
            //     ));
          },
        ),
      ],
    ),
  );
}

DrawerHeader createAdminDrawerHeader(String name) {
  return DrawerHeader(
    decoration: const BoxDecoration(
      color: Colors.lightBlue,
    ),
    child: Stack(
      children: [
        Positioned(
          bottom: 36.0,
          left: 16.0,
          child: Text(name),
        ),
      ],
    ),
  );
}
