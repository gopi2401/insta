class UserInfo {
  int id;
  String username;
  String fullname;
  String biography;
  String category;
  int followerCount;
  int followingCount;
  int mediaCount;
  bool isPrivate;
  String publicEmail;
  String hdProfilePicUrl;
  String profilePicUrl;
  bool isVerified;

  // Constructor
  UserInfo({
    required this.id,
    required this.username,
    required this.fullname,
    required this.biography,
    required this.category,
    required this.followerCount,
    required this.followingCount,
    required this.mediaCount,
    required this.isPrivate,
    required this.publicEmail,
    required this.hdProfilePicUrl,
    required this.profilePicUrl,
    required this.isVerified,
  });

  // Named constructor for JSON deserialization
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    var data = json['result']['user'];

    return UserInfo(
      id: int.parse(data['id']), // Provide fallback default values
      username: data['username'] ?? 'Unknown',
      fullname: data['full_name'] ?? '',
      biography: data['biography'] ?? '',
      category: data['category'] ?? '',
      followerCount: data['follower_count'] ?? 0,
      followingCount: data['following_count'] ?? 0,
      mediaCount: data['media_count'] ?? 0,
      isPrivate: data['is_private'] ?? false,
      publicEmail: data['public_email'] ?? '',
      hdProfilePicUrl: data['hd_profile_pic_url_info']?['url'] ?? '',
      profilePicUrl: data['profile_pic_url'] ?? '',
      isVerified: data['is_verified'] ?? false,
    );
  }

  // Method to convert class object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
      'biography': biography,
      'category': category,
      'follower_count': followerCount,
      'following_count': followingCount,
      'media_count': mediaCount,
      'is_private': isPrivate,
      'public_email': publicEmail,
      'hd_profile_pic_url': hdProfilePicUrl,
      'profile_pic_url': profilePicUrl,
      'is_verified': isVerified,
    };
  }
}
