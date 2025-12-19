import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/providers/chat_provider.dart'; // Import chat provider
import 'package:forever/providers/chat_state_provider.dart';
import 'package:forever/providers/id_provider.dart'; // Import ID provider to check sender
import 'package:forever/providers/main_container_provider.dart';
import 'package:forever/utils/BottomNav.dart';
import 'package:forever/utils/battery_optimization.dart';
import 'package:forever/utils/in-app_notification.dart';
import 'package:permission_handler/permission_handler.dart';

import 'UI/MapPage.dart';
import 'UI/ProfilePage.dart';

class Maincontainer extends ConsumerStatefulWidget {
  const Maincontainer({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<Maincontainer> createState() => _MaincontainerState();
}

class _MaincontainerState extends ConsumerState<Maincontainer> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != 0) {
        ref.read(main_container_provider.notifier).state = widget.initialIndex;
      }
    });

    checkBatteryOptimization(context);

  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = ref.watch(main_container_provider);

    // ✅ NEW: Listen to the Firestore Stream directly
    ref.listen(messagesStreamProvider, (previous, next) {
      next.whenData((messages) {
        if (previous?.hasValue == true && messages.isNotEmpty) {
          final oldMessages = previous!.value!;
          final newMessage = messages.first;

          bool isNew = oldMessages.isEmpty ||
              newMessage.timestamp.isAfter(oldMessages.first.timestamp);

          if (isNew) {
            // 3. Check if *I* sent it (we don't want notifications for our own messages)
            final myId = ref.read(myIdProvider);
            if (newMessage.senderId != myId) {

              // 4. Finally, check if the Chat Screen is closed
              final isChatOpen = ref.read(isChatScreenOpenProvider);
              if (!isChatOpen) {
                showInAppNotification(
                  context,
                  'New Message',
                  newMessage.text,
                );
              }
            }
          }
        }
      });
    });

    List<Widget> pages = <Widget>[
      MapScreen(),
      const ProfilePage()
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(main_container_provider.notifier).state = index;
        },
      ),
    );
  }
}