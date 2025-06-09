class SessionStorage {
  static final SessionStorage _instance = SessionStorage._internal();
  factory SessionStorage() => _instance;

  SessionStorage._internal();

  String? storedImagePath;
  String? firstName;
}

final session = SessionStorage();
