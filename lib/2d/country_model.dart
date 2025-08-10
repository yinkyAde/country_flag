
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