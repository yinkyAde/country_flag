import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import 'country_model.dart';

class CountrySheet extends StatelessWidget {
  final Country country;
  const CountrySheet({required this.country});

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
