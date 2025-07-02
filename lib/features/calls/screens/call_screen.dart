import 'package:extroza/features/calls/service/call_service.dart';
import 'package:extroza/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final UserModel receiver;

  const CallScreen({super.key, required this.receiver});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _callService.onAddRemoteStream = (stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    };
    await _callService.makeCall(
      receiver: widget.receiver,
      localRenderer: _localRenderer,
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _callService.hangUp(_localRenderer);
    super.dispose();
  }

  void _toggleMute() {
    // Access the public localStream directly from the service instance.
    if (_callService.localStream != null) {
      final audioTrack = _callService.localStream!.getAudioTracks().first;
      final isEnabled = !audioTrack.enabled;
      setState(() {
        _isMuted = !isEnabled;
        audioTrack.enabled = isEnabled;
      });
    }
  }

  void _toggleCamera() {
    // Access the public localStream directly from the service instance.
    if (_callService.localStream != null) {
      final videoTrack = _callService.localStream!.getVideoTracks().first;
      final isEnabled = !videoTrack.enabled;
      setState(() {
        _isCameraOff = !isEnabled;
        videoTrack.enabled = isEnabled;
      });
    }
  }
  
  void _switchCamera() {
    // Access the public localStream directly from the service instance.
    if (_callService.localStream != null) {
       final videoTrack = _callService.localStream!.getVideoTracks().first;
       // The helper allows switching between front and back cameras.
       videoTrack.switchCamera();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Remote video
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
          ),
          // Local video
          Positioned(
            top: 48,
            right: 24,
            width: 100,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
          ),
          // Call controls
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                 Text(
                  'Calling ${widget.receiver.fullName}...',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4.0)]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      onPressed: _toggleMute,
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.red : Colors.white,
                      iconColor: _isMuted ? Colors.white : Colors.black,
                    ),
                     _buildControlButton(
                      onPressed: () {
                        _callService.hangUp(_localRenderer);
                        Navigator.of(context).pop();
                      },
                      icon: Icons.call_end,
                      color: Colors.red,
                      iconColor: Colors.white,
                    ),
                     _buildControlButton(
                      onPressed: _toggleCamera,
                      icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                       color: _isCameraOff ? Colors.red : Colors.white,
                      iconColor: _isCameraOff ? Colors.white : Colors.black,
                    ),
                     _buildControlButton(
                      onPressed: _switchCamera,
                      icon: Icons.switch_camera,
                      color: Colors.white,
                      iconColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color,
      child: Icon(icon, color: iconColor),
    );
  }
}
