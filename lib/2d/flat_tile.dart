import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import 'country_model.dart';

class FlagTile extends StatelessWidget {
  final Country country;
  final VoidCallback onTap;
  const FlagTile({required this.country, required this.onTap});

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