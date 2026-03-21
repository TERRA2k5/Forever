import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../models/call_model.dart';
import '../providers/call_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelName;
  final bool isVideoCall;
  final bool isCaller;

  const CallScreen({
    Key? key,
    required this.channelName,
    required this.isVideoCall,
    required this.isCaller,
  }) : super(key: key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(callProvider.notifier)
          .joinCall(widget.channelName, widget.isVideoCall,widget.isCaller);
    });
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);

    ref.listen<CallState>(callProvider, (previous, next) {
      if (previous?.remoteUid != null && next.remoteUid == null) {
        Navigator.of(context).pop();
      }
    });

    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Call Failed")));
        print("Call failed with error: ${next.errorMessage}");
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(child: _renderRemoteView(callState)),

            if (widget.isVideoCall)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _renderLocalView(callState),
                  ),
                ),
              ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "speaker_btn",
                    // Prevents hero animation crashes with multiple FABs
                    backgroundColor:
                        callState.isSpeakerOn
                            ? Colors.white.withOpacity(0.8)
                            : Colors.white.withOpacity(0.2),
                    onPressed: () {
                      ref.read(callProvider.notifier).toggleSpeaker();
                    },
                    child: Icon(
                      callState.isSpeakerOn
                          ? Icons.volume_up
                          : Icons.volume_down,
                      color:
                          callState.isSpeakerOn ? Colors.black : Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 40),//Ejjakx
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderRemoteView(CallState state) {
    if (state.remoteUid != null && state.engine != null) {
      if (widget.isVideoCall) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: state.engine!,
            canvas: VideoCanvas(uid: state.remoteUid),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      } else {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.white54),
            SizedBox(height: 20),
            Text(
              "Voice Call Connected",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        );
      }
    } else {
      return const Text(
        'Waiting for partner to join...',
        style: TextStyle(color: Colors.white70, fontSize: 18),
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _renderLocalView(CallState state) {
    if (state.isLocalJoined && state.engine != null) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: state.engine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }
}
