import 'package:flutter/material.dart';
import '../models/journey.dart';
import 'app_logger.dart';
// For any constants you might need
// For navigation after journey selection

class ListJourney extends StatelessWidget {
  final List<Journey> journeys;

  const ListJourney({super.key, required this.journeys});

  @override
  Widget build(BuildContext context) {
    if (journeys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Aucun trajet enregistré',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        final journey = journeys[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        journey.startLocation,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (journey.startPlaceId != null &&
                        journey.startPlaceId!.isNotEmpty)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '(${journey.startPlaceId})',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        journey.endLocation,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (journey.endPlaceId != null &&
                        journey.endPlaceId!.isNotEmpty)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '(${journey.endPlaceId})',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Distance: ${journey.distance.toStringAsFixed(1)} km',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Durée: ${journey.duration}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Prix: ${journey.price.toStringAsFixed(2)} \$',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement journey selection
                        AppLogger().info(
                            'Journey selected: ${journey.startLocation} to ${journey.endLocation}');
                      },
                      child: const Text('Choisir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
