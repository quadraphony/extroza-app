import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extroza/features/calls/models/call_model.dart';
import 'package:extroza/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _callsCollection = 'calls';

  RTCPeerConnection? _peerConnection;
  // This is now a public field, which is correct.
  MediaStream? localStream;
  Function(MediaStream stream)? onAddRemoteStream;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  Stream<QuerySnapshot> getCallHistoryStream() {
    return _firestore
        .collection(_callsCollection)
        .where('participantIds', arrayContains: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> makeCall({
    required UserModel receiver,
    required RTCVideoRenderer localRenderer,
  }) async {
    try {
      _peerConnection = await createPeerConnection(_configuration);

      final mediaConstraints = {
        'audio': true,
        'video': {'facingMode': 'user'}
      };

      // Uses the public localStream variable.
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = localStream;

      localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream!);
      });

      DocumentReference callDocRef = _firestore.collection(_callsCollection).doc();

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDocRef.collection('callerCandidates').add(candidate.toMap());
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        event.streams[0].getTracks().forEach((track) {
          onAddRemoteStream?.call(event.streams[0]);
        });
      };

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      final call = CallModel(
        id: callDocRef.id,
        callerId: _auth.currentUser!.uid,
        callerName: _auth.currentUser!.displayName ?? 'Unknown',
        receiverId: receiver.uid,
        receiverName: receiver.fullName,
        type: CallType.video,
        status: CallStatus.outgoing,
        timestamp: Timestamp.now(),
        participantIds: [_auth.currentUser!.uid, receiver.uid],
      );

      await callDocRef.set(call.toMap());
      await callDocRef.update({'offer': offer.toMap()});


      callDocRef.collection('receiverCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() as Map<String, dynamic>;
            _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });
      });

      callDocRef.snapshots().listen((snapshot) async {
        final data = snapshot.data() as Map<String, dynamic>;
        if (_peerConnection?.getRemoteDescription() == null && data['answer'] != null) {
          final answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
          await _peerConnection!.setRemoteDescription(answer);
        }
      });

    } catch (e) {
      print('Error making call: $e');
    }
  }

  Future<void> answerCall({
    required String callId,
    required RTCVideoRenderer localRenderer,
  }) async {
    try {
       _peerConnection = await createPeerConnection(_configuration);
       
        final mediaConstraints = {
        'audio': true,
        'video': {'facingMode': 'user'}
      };

      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = localStream;

      localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream!);
      });

      DocumentReference callDocRef = _firestore.collection(_callsCollection).doc(callId);
      DocumentSnapshot callSnapshot = await callDocRef.get();
      final callData = callSnapshot.data() as Map<String, dynamic>;

      final offer = RTCSessionDescription(callData['offer']['sdp'], callData['offer']['type']);
      await _peerConnection!.setRemoteDescription(offer);

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await callDocRef.update({'answer': answer.toMap()});

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDocRef.collection('receiverCandidates').add(candidate.toMap());
      };

       callDocRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
             final data = change.doc.data() as Map<String, dynamic>;
            _peerConnection!.addCandidate(
              RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              ),
            );
          }
        });
      });
      
    } catch (e) {
      print('Error answering call: $e');
    }
  }

  Future<void> hangUp(RTCVideoRenderer localRenderer) async {
    try {
      if (localStream != null) {
        localStream!.getTracks().forEach((track) => track.stop());
        localStream = null;
      }
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
      localRenderer.srcObject = null;
    } catch (e) {
      print('Error hanging up: $e');
    }
  }
}
