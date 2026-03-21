import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraCallService {
  late RtcEngine engine;

  final String appId = dotenv.env['AGORA_APP_ID'] ?? '';

  Future<void> _requestPermissions(bool isVideo) async {
    if (isVideo) {
      await [Permission.microphone, Permission.camera].request();
    } else {
      await [Permission.microphone].request();
    }
  }

  // Set up the Agora RTC engine instance
  Future<void> _initializeAgoraSDK() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    print("Agora RTC Engine initialized with App ID: $appId");
  }

  // Join a channel
  Future<void> _joinChannel(String channel, bool isVideo) async {
    await engine.joinChannel(
      token: '',
      channelId: channel,
      options: ChannelMediaOptions(
        autoSubscribeVideo: isVideo,
        autoSubscribeAudio: true,
        publishCameraTrack: isVideo,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  // Register an event handler for Agora RTC
  void _setupEventHandlers({
    required VoidCallback onJoinSuccess,
    required Function(int uid) onUserJoined,
    required Function(int uid) onUserOffline,
    required Function(ErrorCodeType err, String msg) onError,
  }) {
    print('Setting up event handler for agora');
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user ${connection.localUid} joined");
          onJoinSuccess();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user $remoteUid joined");
          onUserJoined(remoteUid);
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          print("Remote user $remoteUid left");
          onUserOffline(remoteUid);
        },
        onError: (ErrorCodeType err, String msg) {
          print("🚨 AGORA ERROR: $err - $msg");
          onError(err, msg); // Pass it up the chain!
        },
      ),
    );
  }

  Future<void> _setupLocalVideo() async {
    // The video module and preview are disabled by default.
    await engine.enableVideo();
    await engine.startPreview();
  }

  // Leaves the channel and releases resources
  Future<void> cleanupAgoraEngine() async {
    await engine.leaveChannel();
    await engine.release();
  }

  Future<void> startCall({
    required String channel,
    required bool isVideo,
    required VoidCallback onJoinSuccess,
    required Function(int uid) onUserJoined,
    required Function(int uid) onUserOffline,
    required Function(ErrorCodeType err, String msg) onError,
  }) async {
    await _requestPermissions(isVideo);
    await _initializeAgoraSDK();

    if (isVideo) {
      await _setupLocalVideo();
    }
    print('joining ${channel} with video: ${isVideo}');
    // Pass the callbacks from the UI into the handler setup
    _setupEventHandlers(
      onJoinSuccess: onJoinSuccess,
      onUserJoined: onUserJoined,
      onUserOffline: onUserOffline,
      onError: onError,
    );

    await _joinChannel(channel, isVideo);
  }
}
