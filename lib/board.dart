import 'station.dart';

class MoveResult {
  final int? destination;
  final int? previousStation;
  final bool completed;

  const MoveResult({
    required this.destination,
    required this.previousStation,
    required this.completed,
  });
}

class Board {
  static const int stationCount = 29;
  static const int startStationId = 0;

  final Map<int, Station> _stations;

  Board() : _stations = _createStations() {
    validate();
  }

  List<Station> get stations => List.unmodifiable(_stations.values);

  bool isValidStation(int id) => _stations.containsKey(id);

  List<int> nextStationsFrom(int id) {
    final station = _stations[id];
    if (station == null) {
      throw ArgumentError('Invalid station id: $id');
    }
    return List.unmodifiable(station.nextStationIds);
  }

  MoveResult destination({
    required int startId,
    required int moveValue,
  }) {
    if (!isValidStation(startId)) {
      throw ArgumentError('Invalid start station: $startId');
    }

    if (moveValue < 1 || moveValue > 5) {
      throw ArgumentError('Move value must be between 1 and 5.');
    }

    var current = startId;
    int? previous;

    for (var step = 0; step < moveValue; step++) {
      final nextIds = nextStationsFrom(current);

      if (nextIds.isEmpty) {
        return MoveResult(
          destination: null,
          previousStation: previous,
          completed: true,
        );
      }

      int next;

      if (current == 5) {
        // Starting on 5 takes shortcut; passing through 5 goes outer.
        next = previous == null ? 20 : 6;
      } else if (current == 10) {
        // Starting on 10 takes shortcut; passing through 10 goes outer.
        next = previous == null ? 22 : 11;
      } else if (current == 28) {
        // If we reached 28 from the 5-side shortcut, continue toward 27.
        // Otherwise, starting on 28 or coming from 23 goes toward 25.
        next = previous == 21 ? 27 : 25;
      } else {
        next = nextIds.first;
      }

      previous = current;
      current = next;

      if (current == startStationId && step < moveValue - 1) {
        return MoveResult(
          destination: null,
          previousStation: previous,
          completed: true,
        );
      }
    }

    return MoveResult(
      destination: current,
      previousStation: previous,
      completed: false,
    );
  }

  int moveBackward({
    required int currentStation,
    required int previousStation,
  }) {
    if (!isValidStation(currentStation)) {
      throw ArgumentError('Invalid current station: $currentStation');
    }

    if (!isValidStation(previousStation)) {
      throw ArgumentError('Invalid previous station: $previousStation');
    }

    if (currentStation == startStationId) {
      if (previousStation == 24 || previousStation == 19) {
        return previousStation;
      }

      throw ArgumentError(
        'Station 0 can only move back to 24 or 19 based on the path used.',
      );
    }

    if (nextStationsFrom(previousStation).contains(currentStation)) {
      return previousStation;
    }

    throw ArgumentError(
      'Station $previousStation does not connect to $currentStation.',
    );
  }

  void validate() {
    assert(_stations.length == stationCount);

    for (var id = 0; id < stationCount; id++) {
      assert(_stations.containsKey(id));
    }

    for (final station in _stations.values) {
      assert(station.id >= 0 && station.id < stationCount);

      for (final nextId in station.nextStationIds) {
        assert(_stations.containsKey(nextId));
      }
    }
  }

  static Map<int, Station> _createStations() {
    return {
      0: Station(id: 0, name: 'Start / bottom-right corner', nextStationIds: [1]),

      1: Station(id: 1, name: 'Right edge 1', nextStationIds: [2]),
      2: Station(id: 2, name: 'Right edge 2', nextStationIds: [3]),
      3: Station(id: 3, name: 'Right edge 3', nextStationIds: [4]),
      4: Station(id: 4, name: 'Right edge 4', nextStationIds: [5]),
      5: Station(id: 5, name: 'Top-right corner', nextStationIds: [6, 20]),

      6: Station(id: 6, name: 'Top edge 1', nextStationIds: [7]),
      7: Station(id: 7, name: 'Top edge 2', nextStationIds: [8]),
      8: Station(id: 8, name: 'Top edge 3', nextStationIds: [9]),
      9: Station(id: 9, name: 'Top edge 4', nextStationIds: [10]),

      10: Station(id: 10, name: 'Top-left corner', nextStationIds: [11, 22]),

      11: Station(id: 11, name: 'Left edge 1', nextStationIds: [12]),
      12: Station(id: 12, name: 'Left edge 2', nextStationIds: [13]),
      13: Station(id: 13, name: 'Left edge 3', nextStationIds: [14]),
      14: Station(id: 14, name: 'Left edge 4', nextStationIds: [15]),

      15: Station(id: 15, name: 'Bottom-left corner', nextStationIds: [16]),
      16: Station(id: 16, name: 'Bottom edge 1', nextStationIds: [17]),
      17: Station(id: 17, name: 'Bottom edge 2', nextStationIds: [18]),
      18: Station(id: 18, name: 'Bottom edge 3', nextStationIds: [19]),
      19: Station(id: 19, name: 'Bottom edge 4', nextStationIds: [0]),

      20: Station(id: 20, name: 'Top-right inner shortcut', nextStationIds: [21]),
      21: Station(id: 21, name: 'Upper-right middle shortcut', nextStationIds: [28]),
      22: Station(id: 22, name: 'Top-left inner shortcut', nextStationIds: [23]),
      23: Station(id: 23, name: 'Upper-left middle shortcut', nextStationIds: [28]),
      24: Station(id: 24, name: 'Bottom-right inner shortcut', nextStationIds: [0]),
      25: Station(id: 25, name: 'Lower-right middle shortcut', nextStationIds: [24]),
      26: Station(id: 26, name: 'Bottom-left inner shortcut', nextStationIds: [15]),
      27: Station(id: 27, name: 'Lower-left middle shortcut', nextStationIds: [26]),
      28: Station(id: 28, name: 'Center station', nextStationIds: [25, 27]),

      /* Corrected shortcut path:
      // 5 -> 20 -> 21 -> 28 -> 27 -> 26 -> 15
      20: Station(id: 20, name: 'Top-right inner shortcut', nextStationIds: [21]),
      21: Station(id: 21, name: 'Upper-right middle shortcut', nextStationIds: [28]),
      28: Station(id: 28, name: 'Center station', nextStationIds: [25, 27]),
      27: Station(id: 27, name: 'Lower-left middle shortcut', nextStationIds: [26]),
      26: Station(id: 26, name: 'Bottom-left inner shortcut', nextStationIds: [15]),

      // Corrected shortcut path:
      // 10 -> 22 -> 23 -> 28 -> 25 -> 24 -> 0
      22: Station(id: 22, name: 'Top-left inner shortcut', nextStationIds: [23]),
      23: Station(id: 23, name: 'Upper-left middle shortcut', nextStationIds: [28]),
      28: Station(id: 28, name: 'Center station', nextStationIds: [25]),
      25: Station(id: 25, name: 'Lower-right middle shortcut', nextStationIds: [24]),
      24: Station(id: 24, name: 'Bottom-right inner shortcut', nextStationIds: [0]),
      */
    };
  }
}