class UserInfo {
  final int userNo;
  final String userName;
  final String userInfo;
  final String profileImg;
  final String lastLogin;

  UserInfo({
    required this.userNo,
    required this.userName,
    required this.userInfo,
    required this.profileImg,
    required this.lastLogin,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userNo: json['user_no'],
      userName: json['user_name'],
      userInfo: json['user_info'],
      profileImg: json['profile_img'],
      lastLogin: json['last_login'],
    );
  }

}
