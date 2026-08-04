import '../../domain/entities/weather_info.dart';

class WeatherModel extends WeatherInfo {
  const WeatherModel({
    required super.temperature,
    required super.condition,
    required super.humidity,
    required super.locationName,
    required super.description,
    required super.iconCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // OpenWeather API formats
    final main = json['main'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final weatherList = json['weather'] as List<dynamic>? ?? <dynamic>[];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>? ?? <String, dynamic>{}
        : <String, dynamic>{};

    return WeatherModel(
      temperature: (main['temp'] as num? ?? 0.0).toDouble(),
      condition: weather['main'] as String? ?? 'Unknown',
      humidity: (main['humidity'] as num? ?? 0).toInt(),
      locationName: json['name'] as String? ?? 'Unknown',
      description: weather['description'] as String? ?? 'No details',
      iconCode: weather['icon'] as String? ?? '01d',
    );
  }

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      temperature: (map['temperature'] as num? ?? 0.0).toDouble(),
      condition: map['condition'] as String? ?? 'Unknown',
      humidity: (map['humidity'] as num? ?? 0).toInt(),
      locationName: map['locationName'] as String? ?? 'Unknown',
      description: map['description'] as String? ?? '',
      iconCode: map['iconCode'] as String? ?? '01d',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'locationName': locationName,
      'description': description,
      'iconCode': iconCode,
    };
  }
}
