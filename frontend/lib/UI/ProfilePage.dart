import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/utils/CostomButton.dart';
import 'package:forever/utils/IdCard.dart';

import '../providers/id_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myIdAsync = ref.watch(myIdProvider);
    final textTheme = Theme
        .of(context)
        .textTheme;
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
        body: SingleChildScrollView(
          child: myIdAsync.when(
            data: (myId) {
              final partnerIdAsync = ref.watch(partnerIdProvider);
              return partnerIdAsync.when(
                data: (partnerId) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        // --- App Title ---
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: textTheme.displaySmall?.copyWith(
                                height: 1.2),
                            children: [
                              const TextSpan(
                                text: 'Together\n',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              TextSpan(
                                text: 'Profile ♡',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 60,),
                        IdCard(myid: myId,isPartner:  false, ref: ref),
                        SizedBox(height: 40),
                        IdCard(myid: partnerId, isPartner: true, ref: ref),
                        SizedBox(height: 60,),

                        CustomBtn(onPressed: (){
                          FirebaseAuth.instance.signOut();
                        },
                        text: 'Logout',
                        icon: Icon(Icons.logout),)
                      ],
                    ),
                  );
                },
                error:
                    (err, stack) =>
                    Center(
                      child: Text(
                        'Some error occured :\n Check your network connection.\n : $err',
                      ),
                    ),
                loading: () => Center(child: CircularProgressIndicator()),
              );
            },
            error:
                (err, stack) =>
                Center(
                  child: Text(
                    'Some error occured :\n Check your network connection.\n : $err',
                  ),
                ),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
        )
    );
  }
}
