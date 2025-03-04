class BackendLinkManager {
  static const String baseUrl =
      'http://192.168.235.100:5000'; // Replace with your backend base URL

  // Define all the endpoints here
  static const String loginEndpoint = '$baseUrl/login';
  static const String registerEndpoint = '$baseUrl/register';
  static const String fetchUserDataEndpoint = '$baseUrl/user';
  static const String updateProfileEndpoint = '$baseUrl/update-profile';
  static const String communityEndpoint = '$baseUrl/community_post';
  static const String communitypost = '$baseUrl/get_community_posts';
  static const String historyEndpoint = '$baseUrl/history';

  // Add more endpoints as required
}
