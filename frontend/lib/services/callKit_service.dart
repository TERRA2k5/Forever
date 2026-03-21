import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import '../UI/CallPage.dart';
import '../main.dart';

class CallKitService {

  void showIncoming(String callerName, String channelName, bool isVideo) async {
    final callId = channelName;
    final callKitParams = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'Forever',
      avatar: 'https://i.pravatar.cc/100', // Optional: Partner's profile pic
      handle: 'Incoming ${isVideo ? 'Video' : 'Voice'} Call',
      type: isVideo ? 1 : 0,
      duration: 30000, // Rings for 30 seconds before timing out
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: <String, dynamic>{
        // We hide the channel name in the 'extra' map so we can
        // access it later if they press accept!
        'channel_name': channelName,
        'is_video': isVideo,
      },
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default', // Plays default native ringtone
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    // 3. WAKE UP THE PHONE!
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  void handleIncoming(){
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
        // The user pressed the Green button!
        // 1. Extract the channel name we hid in the 'extra' map
          final extraData = event.body['extra'];
          final channelName = extraData['channel_name'];
          final isVideo = extraData['is_video'] == true;

          // 2. Navigate to the Agora Call Screen!
          Future.delayed(const Duration(milliseconds: 500), () {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => CallScreen(
                  channelName: channelName,
                  isVideoCall: isVideo,
                  isCaller: false, // Remember this flag we added earlier!
                ),
              ),
            );
          });
          break;

        case Event.actionCallDecline:
        // The user pressed the Red button.
        // CallKit automatically closes the screen and stops ringing.
          print("Call declined.");
          break;

        default:
          break;
      }
    });

    _checkColdBootCall();
  }

  Future<void> _checkColdBootCall() async {
    // This guarantees the MaterialApp is fully built and navigatorKey is ready!
    WidgetsBinding.instance.addPostFrameCallback((_) async {

      // Ask the native OS: "Are there any active calls right now?"
      var calls = await FlutterCallkitIncoming.activeCalls();

      if (calls is List && calls.isNotEmpty) {
        // Yes! We woke up because the user accepted a call.
        print("Cold boot active call detected!");
        final callData = calls[0]; // Get the currently active call
        _navigateToCallScreen(callData['extra']);
      }
    });
  }

  // Helper function to keep our navigation code clean and DRY
  void _navigateToCallScreen(dynamic extraData) {
    if (extraData == null) return;

    final channelName = extraData['channel_name'];
    final isVideo = extraData['is_video'] == true;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: channelName,
          isVideoCall: isVideo,
          isCaller: false, // We are receiving the call!
        ),
      ),
    );
  }
}