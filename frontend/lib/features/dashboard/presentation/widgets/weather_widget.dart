import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/weather_info.dart';
import '../providers/dashboard_providers.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  String _getWeatherSuggestion(String condition) {
    switch (condition.toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return 'It\'s raining. Perfect time for indoor breathing exercises!';
      case 'clear':
        return 'Skies are clear. Consider a 10-minute walk for natural light!';
      case 'clouds':
        return 'Overcast weather. Great for a screen break near a window!';
      case 'snow':
        return 'Brr, it\'s cold! Stay cozy and log a meditation session.';
      case 'mist':
      case 'fog':
      case 'haze':
        return 'Visibility is low. Focus on desk-stretch exercises today!';
      default:
        return 'Ensure your desk space is well-lit and drink some water.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherStateProvider);

    return weatherState.when(
      data: (WeatherInfo weather) {
        final suggestion = _getWeatherSuggestion(weather.condition);
        final iconUrl = 'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png';

        return Semantics(
          label: 'Weather update. Location: ${weather.locationName}. Temperature: ${weather.temperature.toInt()} degrees Celsius. ${weather.condition}. $suggestion',
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    context.colorScheme.primary.withOpacity(0.05),
                    context.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            weather.locationName,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Weather Widget',
                        style: context.textTheme.labelSmall?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      // OpenWeather API network image for conditions
                      CachedNetworkImage(
                        imageUrl: iconUrl,
                        height: 52,
                        width: 52,
                        placeholder: (BuildContext context, String url) => const SizedBox(
                          height: 52,
                          width: 52,
                          child: Center(
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (BuildContext context, String url, Object error) => const Icon(
                          Icons.wb_sunny_outlined,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${weather.temperature.toStringAsFixed(1)}°C',
                            style: context.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            '${weather.condition} • Humidity ${weather.humidity}%',
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Suggestion banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.lightbulb_outline,
                          color: context.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: context.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => _buildShimmer(context),
      error: (Object err, StackTrace? stack) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Weather Offline', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () {
                        // Trigger weather refresh
                        ref.read(weatherStateProvider.notifier).loadWeather();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Could not update weather. Please check your internet connection.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.onSurface.withOpacity(0.08),
      highlightColor: context.colorScheme.onSurface.withOpacity(0.03),
      child: Card(
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(width: 120, height: 16, color: Colors.white),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Container(width: 48, height: 48, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(width: 80, height: 24, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 140, height: 12, color: Colors.white),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
