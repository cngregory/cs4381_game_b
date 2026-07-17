class Station {
  final int id;
  final String name;
  final List<int> nextStationIds;

  const Station({
    required this.id,
    required this.name,
    required this.nextStationIds,
  });

  bool get hasShortcut => nextStationIds.length > 1;

  @override
  String toString() => 'Station($id, $name -> $nextStationIds)';
}
