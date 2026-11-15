enum LeafletMapStyle {
  openStreetMap(
    name: 'Leaflet OpenStreetMap',
    description: 'Peta Leaflet Klasik Terang',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
  ),
  darkMatter(
    name: 'Leaflet Dark Matter',
    description: 'Peta Leaflet Gelap Kontras Tinggi',
    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
  );

  final String name;
  final String description;
  final String urlTemplate;
  final List<String> subdomains;

  const LeafletMapStyle({
    required this.name,
    required this.description,
    required this.urlTemplate,
    required this.subdomains,
  });
}
