import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallState {
  final RtcEngine? engine;
  final bool isLocalJoined;
  final int? remoteUid;
  final String? errorMessage;
  final bool isSpeakerOn;

  const CallState({
    this.engine,
    this.isLocalJoined = false,
    this.remoteUid,
    this.errorMessage,
    this.isSpeakerOn = false
  });

  CallState copyWith({
    RtcEngine? engine,
    bool? isLocalJoined,
    int? remoteUid,
    bool clearRemoteUid = false,
    String? errorMessage,
    bool? isSpeakerOn,
  }) {
    return CallState(
      engine: engine ?? this.engine,
      isLocalJoined: isLocalJoined ?? this.isLocalJoined,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      errorMessage: errorMessage ?? this.errorMessage,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}