import 'package:flutter/material.dart';

class JourneyStep {
  final String departure;
  final String arrival;
  final String duration;
  final String distance;
  final double price;

  JourneyStep({
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.distance,
    required this.price,
    required String instruction,
  });
}

class ListJourney extends StatelessWidget {
  final List<JourneyStep> steps;
  final void Function(JourneyStep)? onChoose;

  const ListJourney({Key? key, required this.steps, this.onChoose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Départ : ${step.departure}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Arrivée : ${step.arrival}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          step.duration,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          step.distance,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${step.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onChoose != null
                          ? () => onChoose!(step)
                          : null,
                      child: const Text('Choisir cette course'),
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

final exampleSteps = [
  JourneyStep(
    departure: 'Gare de Lyon',
    arrival: 'Tour Eiffel',
    duration: '18 min',
    distance: '5.2 km',
    price: 19.90,
    instruction: '',
  ),
  JourneyStep(
    departure: 'Montparnasse',
    arrival: 'Musée d’Orsay',
    duration: '12 min',
    distance: '3.7 km',
    price: 15.50,
    instruction: '',
  ),
  JourneyStep(
    departure: 'Champs-Élysées',
    arrival: 'Opéra Garnier',
    duration: '9 min',
    distance: '2.8 km',
    price: 13.20,
    instruction: '',
  ),
  JourneyStep(
    departure: 'Place de la Bastille',
    arrival: 'Sacré-Cœur',
    duration: '22 min',
    distance: '6.1 km',
    price: 21.75,
    instruction: '',
  ),
  JourneyStep(
    departure: 'La Défense',
    arrival: 'Jardin du Luxembourg',
    duration: '25 min',
    distance: '7.4 km',
    price: 24.30,
    instruction: '',
  ),
];
// To display in your app:
// ListJourney(steps: exampleSteps)
