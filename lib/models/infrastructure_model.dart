import 'package:cloud_firestore/cloud_firestore.dart';

class InfrastructureAsset {
  final String? id;
  final String name;
  final String type;
  final String location;
  final String status;
  final String description;
  final DateTime lastInspectionDate;
  final DateTime createdAt;

  InfrastructureAsset({
    this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.description,
    required this.lastInspectionDate,
    required this.createdAt,
  });

  factory InfrastructureAsset.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InfrastructureAsset(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      status: data['status'] ?? '',
      description: data['description'] ?? '',
      lastInspectionDate: (data['lastInspectionDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'status': status,
      'description': description,
      'lastInspectionDate': Timestamp.fromDate(lastInspectionDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static const List<String> types = [
    'Road',
    'Bridge',
    'Street Light',
    'Water Pipeline',
    'Drainage',
    'Park',
    'Bus Stop',
    'Public Toilet',
    'Government Building',
  ];

  static const List<String> statuses = [
    'Good',
    'Maintenance Required',
    'Damaged',
    'Critical',
  ];
}
