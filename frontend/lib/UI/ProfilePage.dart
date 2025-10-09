import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/id_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myIdAsync = ref.watch(myIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: myIdAsync.when(
          data: (myId){
            final partnerIdAsync = ref.watch(partnerIdProvider);
            return partnerIdAsync.when(
              data: (partnerId) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("Your ID:", style: Theme.of(context).textTheme.titleLarge),
                      SelectableText(myId, style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 40),
                      Text("Partner's ID:", style: Theme.of(context).textTheme.titleLarge),
                      SelectableText(partnerId ?? 'Not connected', style: Theme.of(context).textTheme.headlineLarge),
                    ],
                  ),
                );
              },
              error: (err, stack) => Center(child: Text('Some error occured :\n Check your network connection.\n : $err'),),
              loading: () => Center(child: CircularProgressIndicator(),
              ));
          },
          error: (err, stack) => Center(child: Text('Some error occured :\n Check your network connection.\n : $err'),),
          loading: () => Center(child: CircularProgressIndicator(),
          )),
    );
  }
}
