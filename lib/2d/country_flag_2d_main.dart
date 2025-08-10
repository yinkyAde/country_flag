import 'package:flutter/material.dart';

import 'country_model.dart';
import 'country_sheet.dart';
import 'flat_tile.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flag Globe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlagGlobePage(),
    );
  }
}

class FlagGlobePage extends StatelessWidget {
  const FlagGlobePage({super.key});

  @override
  Widget build(BuildContext context) {

    final countries = <Country>[
      const Country(name: 'Nigeria', code: 'NG', extra: {'Capital': 'Abuja', 'Region': 'Africa'}),
      const Country(name: 'Ghana', code: 'GH', extra: {'Capital': 'Accra', 'Region': 'Africa'}),
      const Country(name: 'United States', code: 'US', extra: {'Capital': 'Washington, D.C.', 'Region': 'Americas'}),
      const Country(name: 'United Kingdom', code: 'GB', extra: {'Capital': 'London', 'Region': 'Europe'}),
      const Country(name: 'Canada', code: 'CA', extra: {'Capital': 'Ottawa', 'Region': 'Americas'}),
      const Country(name: 'Brazil', code: 'BR', extra: {'Capital': 'Brasília', 'Region': 'Americas'}),
      const Country(name: 'India', code: 'IN', extra: {'Capital': 'New Delhi', 'Region': 'Asia'}),
      const Country(name: 'Japan', code: 'JP', extra: {'Capital': 'Tokyo', 'Region': 'Asia'}),
      const Country(name: 'South Africa', code: 'ZA', extra: {'Capital': 'Pretoria', 'Region': 'Africa'}),
      const Country(name: 'France', code: 'FR', extra: {'Capital': 'Paris', 'Region': 'Europe'}),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Flag Globe', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final diameter = (constraints.biggest.shortestSide * 0.9)
                .clamp(240.0, 520.0);
            return SizedBox(
              width: diameter,
              height: diameter,
              child: _FlagSphere(
                countries: countries,
                diameter: diameter,
                crossAxisCount: 12,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlagSphere extends StatelessWidget {
  final List<Country> countries;
  final double diameter;
  final int crossAxisCount;

  const _FlagSphere({
    required this.countries,
    required this.diameter,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalTiles = crossAxisCount * (crossAxisCount + 6);
    final items = List<Country>.generate(
      totalTiles,
          (i) => countries[i % countries.length],
    );

    return ClipOval(
      child: ShaderMask(
        shaderCallback: (rect) {
          return RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.92),
              Colors.white.withOpacity(0.80),
              Colors.white.withOpacity(0.65),
            ],
            stops: const [0.0, 0.55, 0.8, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.modulate,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(6),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final c = items[index];
                  final row = index ~/ crossAxisCount;
                  final rows = (items.length / crossAxisCount).ceil();
                  final t = (row / (rows - 1)) * 2 - 1; // -1..1
                  final bow = (1 - (t * t)) * 8; // center wider than poles
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: bow),
                    child: FlagTile(
                      country: c,
                      onTap: () => _showCountrySheet(context, c),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountrySheet(BuildContext context, Country c) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => CountrySheet(country: c),
    );
  }
}
