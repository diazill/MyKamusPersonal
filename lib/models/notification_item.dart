import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String type; // 'target', 'update', dll
  final bool isRead;
  final DateTime createdAt;
  final String createdBy;
  final String? version; // optional, for 'update' type

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    required this.createdBy,
    this.version,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map, String id) {
    return NotificationItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'info',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? 'system',
      version: map['version'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      if (version != null) 'version': version,
    };
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? createdBy,
    String? version,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      version: version ?? this.version,
    );
  }
}
