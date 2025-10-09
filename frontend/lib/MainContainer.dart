import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/main_container_provider.dart';
import 'package:forever/utils/BottomNav.dart';

import 'UI/MapPage.dart';
import 'UI/ProfilePage.dart';

class Maincontainer extends ConsumerStatefulWidget {
  const Maincontainer({super.key});

  @override
  ConsumerState createState() => _MaincontainerState();
}

class _MaincontainerState extends ConsumerState<Maincontainer> {
  @override
  Widget build(BuildContext context) {
    int  _currentIndex = ref.watch(main_container_provider);
    List<Widget> _pages = <Widget>[
      MapScreen(),
      ProfilePage()
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          ref.read(main_container_provider.notifier).state = index;
        },
      ),
    );
  }
}