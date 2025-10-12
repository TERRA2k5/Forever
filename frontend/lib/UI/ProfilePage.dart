import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forever/services/firebaseAuth_service.dart';
import 'package:forever/utils/CostomButton.dart';
import 'package:forever/utils/IdCard.dart';
import 'package:forever/utils/alertboxes.dart';

import '../providers/id_provider.dart';
import '../providers/pet_name_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myIdAsync = ref.watch(myIdProvider);
    final petNameAsync = ref.watch(petNameProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 80),
                      // --- App Title ---
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: textTheme.displaySmall?.copyWith(height: 1.2),
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
                      SizedBox(height: 60),
                      IdCard(myid: myId, isPartner: false, ref: ref),
                      SizedBox(height: 30),
                      IdCard(myid: partnerId, isPartner: true, ref: ref),
                      SizedBox(height: 30),

                      petNameAsync.when(
                        data: (petName) {
                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Give your partner a pet name',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  // Added vertical padding for better spacing
                                  child: InkWell(
                                    onTap: () {
                                      showPetNameBox(context, ref);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          petName ?? 'Your Partner',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          color: colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        error: (err, stack) => Text('No pet name found.'),
                        loading:
                            () => Center(child: CircularProgressIndicator()),
                      ),

                      SizedBox(height: 30),
                      CustomBtn(
                        onPressed: () {
                          AuthService().logout(ref, context);
                        },
                        text: 'Logout',
                        icon: Icon(Icons.logout),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                );
              },
              error:
                  (err, stack) => Center(
                    child: Text(
                      'Some error occured :\n Check your network connection.\n : $err',
                    ),
                  ),
              loading: () => Center(child: CircularProgressIndicator()),
            );
          },
          error:
              (err, stack) => Center(
                child: Text(
                  'Some error occured :\n Check your network connection.\n : $err',
                ),
              ),
          loading: () => Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
