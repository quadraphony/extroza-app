import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { voice, video }
enum CallStatus { missed, outgoing, incoming }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatarUrl;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatarUrl;
  final CallType type;
  final CallStatus status;
  final Timestamp timestamp;
  final int? durationInSeconds;
  final List<String> participantIds;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatarUrl,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatarUrl,
    required this.type,
    required this.status,
    required this.timestamp,
    this.durationInSeconds,
    required this.participantIds,
  });

  /// Creates a CallModel instance from a Firestore document snapshot.
  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CallModel(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      callerName: data['callerName'] ?? '',
      callerAvatarUrl: data['callerAvatarUrl'],
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      receiverAvatarUrl: data['receiverAvatarUrl'],
      type: CallType.values[data['type'] ?? 0],
      status: CallStatus.values[data['status'] ?? 0],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      durationInSeconds: data['durationInSeconds'],
      participantIds: List<String>.from(data['participantIds'] ?? []),
    );
  }

  /// Converts a CallModel instance into a Map to be stored in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatarUrl': callerAvatarUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatarUrl': receiverAvatarUrl,
      'type': type.index,
      'status': status.index,
      'timestamp': timestamp,
      'durationInSeconds': durationInSeconds,
      'participantIds': participantIds,
    };
  }
}
