import 'package:flutter/material.dart';
import 'package:wellbeing/view/permission_screen.dart';
import 'package:wellbeing/widget/appbar/appbar.dart';

class Permission extends StatelessWidget {
  const Permission({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: PermissionScreen());
  }
}
