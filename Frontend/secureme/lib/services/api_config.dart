class ApiConfig {
  // Using HTTPS for secure connection
  // static const String baseUrl = 'https://secureme-vj4u.onrender.com';
  static const String baseUrl = 'http://localhost:4000';

  // API endpoints
  static const String scanUrl = '$baseUrl/api/url/scan';
  static const String healthCheck = '$baseUrl/health';
}
