import 'package:equatable/equatable.dart';

class WeatherInfo extends Equatable {
  final double temperature;
  final String condition;
  final int humidity;
  final String locationName;
  final String description;
  final String iconCode;

  const WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.locationName,
    required this.description,
    required this.iconCode,
  });

  @override
  List<Object?> get props => <Object?>[
        temperature,
        condition,
        humidity,
        locationName,
        description,
        iconCode,
      ];
}
