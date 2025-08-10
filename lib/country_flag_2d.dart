import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

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

class Country {
  final String name;
  final String code; // ISO country code, e.g. "NG"
  final Map<String, String> extra;

  const Country({
    required this.name,
    required this.code,
    this.extra = const {},
  });
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
                    child: _FlagTile(
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
      builder: (context) => _CountrySheet(country: c),
    );
  }
}

class _FlagTile extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  const _FlagTile({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Center(
              child: CountryFlag.fromCountryCode(
                country.code,
                shape: const RoundedRectangle(4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountrySheet extends StatelessWidget {
  final Country country;
  const _CountrySheet({required this.country});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: CountryFlag.fromCountryCode(
              country.code,
              shape: const RoundedRectangle(8),
              width: 96,
              height: 64,
            ),
          ),
          const SizedBox(height: 12),
          Text(country.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...country.extra.entries.map(
                (e) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              trailing: Text(e.value),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Close'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
