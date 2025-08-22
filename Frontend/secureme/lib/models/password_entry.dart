import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a new password entry
  factory PasswordEntry.create({
    required String title,
    required String username,
    required String password,
    String? website,
    String? notes,
  }) {
    final now = DateTime.now();
    final id = _generateId(title, username, now);
    
    return PasswordEntry(
      id: id,
      title: title,
      username: username,
      password: password,
      website: website,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Generate a unique ID based on title, username, and timestamp
  static String _generateId(String title, String username, DateTime timestamp) {
    final input = '$title$username${timestamp.millisecondsSinceEpoch}';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Create a copy with updated fields
  PasswordEntry copyWith({
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
  }) {
    return PasswordEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'],
      title: json['title'],
      username: json['username'],
      password: json['password'],
      website: json['website'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Get masked password for display
  String get maskedPassword => '*' * password.length;

  // Get display name for the entry
  String get displayName => title.isNotEmpty ? title : website ?? 'Untitled';

  @override
  String toString() {
    return 'PasswordEntry(id: $id, title: $title, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
