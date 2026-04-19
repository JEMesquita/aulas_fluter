import 'package:flutter/material.dart';

class DetailArguments {
  final String title;
  final String subtitle;
  final String description;

  const DetailArguments({
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

class DetailsScreen extends StatelessWidget {
  static const routeName = '/details';

  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as DetailArguments?;

    return Scaffold(
      appBar: AppBar(
        title: Text(args?.title ?? 'Detalhes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              args?.title ?? 'Sem título',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              args?.subtitle ?? 'Sem subtítulo',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Text(
              args?.description ?? 'Sem descrição disponível.',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
