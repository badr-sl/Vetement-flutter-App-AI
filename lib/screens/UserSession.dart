class UserSession {
  static final UserSession _instance = UserSession._internal();

  // Properties for the session data
  String? uid;
  String? email;
  String? password;
  Map<String, dynamic>? additionalInfo;

  UserSession._internal();

  // Factory constructor
  factory UserSession() {
    return _instance;
  }

  void setUserInfo({
    required String uid,
    required String email,
    required String password,
    Map<String, dynamic>? additionalInfo,
  }) {
    this.uid = uid;
    this.email = email;
    this.password = password;
    this.additionalInfo = additionalInfo;
  }

  void clearUserInfo() {
    uid = null;
    email = null;
    password = null;
    additionalInfo = null;
  }
}
