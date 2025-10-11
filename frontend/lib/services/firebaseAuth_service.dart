import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:forever/MainContainer.dart';
import 'package:forever/providers/main_container_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/start_up_provider.dart';

class AuthService{

    void createUser(BuildContext context , String emailAddress,String password,String confPassword, String name, WidgetRef ref) async{
        if(confPassword != password){
            Fluttertoast.showToast(msg: 'Password do not match.');
            return;
        }
        else if(name == '' || emailAddress == '' || password == '' || confPassword == ''){
            Fluttertoast.showToast(msg: 'All fields are Required.');
        }
        try {
            final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: emailAddress,
                password: password,
            );
        } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
                Fluttertoast.showToast(msg: 'The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
                Fluttertoast.showToast(msg: 'The account already exists for that email.');
            }
        } catch (e) {
            print(e);
        }

        FirebaseAuth.instance
            .authStateChanges()
            .listen((User? user) async {
            if (user != null) {
                ref.read(main_container_provider.notifier).state = 1;
                await user.updateDisplayName(name);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("userUID", user.uid.toString());
                await prefs.setString("userName", name);
                await prefs.setString("userEmail", emailAddress);

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Maincontainer()),
                );
            }
        });
    }

    Future<void> loginUser(BuildContext context , String emailAddress , String password, WidgetRef ref) async {
        if(emailAddress == "" || password == ""){
            Fluttertoast.showToast(msg: 'All fields are Required.');
        }
        else{
            try {
                final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailAddress,
                    password: password
                );
            } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                }
            }
        }

        FirebaseAuth.instance
            .authStateChanges()
            .listen((User? user) async {
            if (user != null) {
                ref.read(main_container_provider.notifier).state = 0;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("userUID", user.uid.toString());
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Maincontainer()), (route) => false
                );
            }
        });
    }

    Future<void> logout(WidgetRef ref) async {
        await FirebaseAuth.instance.signOut();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        ref.invalidate(startupRouteProvider);
    }
}