class ApiConfig {
  // Replace this with your Render URL once deployed
  static const String baseUrl = 'https://secureme-vj4u.onrender.com';

  // API endpoints
  static const String scanUrl = '$baseUrl/api/url/scan';
  static const String healthCheck = '$baseUrl/health';
}