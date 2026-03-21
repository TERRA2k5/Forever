import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../models/call_model.dart';
import '../services/agora_service.dart';
import '../services/fcm_handler.dart';


class CallController extends AutoDisposeNotifier<CallState> {
  final AgoraCallService _callService = AgoraCallService();

  @override
  CallState build() {
    ref.onDispose(() async {
      await _callService.cleanupAgoraEngine();
      await FlutterCallkitIncoming.endAllCalls();
    });

    return const CallState();
  }

  Future<void> joinCall(String channel, bool isVideo, bool isCaller) async {
    await _callService.startCall(
      channel: channel,
      isVideo: isVideo,
      onJoinSuccess: () async {
        print("Local user joined the call successfully {riverpod}");
        state = state.copyWith(
          isLocalJoined: true,
          engine: _callService.engine,
          isSpeakerOn: isVideo
        );
        if(isCaller) await FcmHandler().sendCallNotification(channelName: channel,isVideo:  isVideo);
      },
      onUserJoined: (int uid) {
        state = state.copyWith(remoteUid: uid);
      },
      onUserOffline: (int uid) {
        state = state.copyWith(clearRemoteUid: true);
      },
      onError: (ErrorCodeType err, String msg) {
        state = state.copyWith(errorMessage: msg);
      },
    );
  }

  // Add this inside CallController:
  Future<void> toggleSpeaker() async {
    // If we don't have an engine yet, do nothing
    if (state.engine == null) return;

    // Flip the current state
    final newSpeakerState = !state.isSpeakerOn;

    // Tell Agora to route audio to the speaker or earpiece
    await state.engine!.setEnableSpeakerphone(newSpeakerState);

    // Update Riverpod so the button icon changes!
    state = state.copyWith(isSpeakerOn: newSpeakerState);
  }
}

final callProvider = AutoDisposeNotifierProvider<CallController, CallState>(() {
  return CallController();
});