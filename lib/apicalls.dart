// This contains functions for dummy data

class ApiCall {
  Future<Map<String, double>> getCurrentLocation() async {
    // Dummy data for location
    return {
      'latitude': 37.7749,
      'longitude': -122.4194,
    };
  }

  Future<List<Map<String, dynamic>>> getDummyChartData() async {
    // Dummy data for chart
    return [
      {'x': 'Jan', 'y': 30},
      {'x': 'Feb', 'y': 28},
      {'x': 'Mar', 'y': 34},
      {'x': 'Apr', 'y': 32},
      {'x': 'May', 'y': 40},
    ];
  }
}
