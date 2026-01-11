import 'dart:collection';
import 'dart:math';
import 'package:latlong2/latlong.dart';

// =====================
// DATA STRUCTURES
// =====================
class Node {
  final String id;
  final LatLng position;
  List<Edge> edges = [];

  Node(this.id, this.position);
}

class Edge {
  final Node target;
  final double weight; // khoảng cách (km)

  Edge(this.target, this.weight);
}

class Graph {
  Map<String, Node> nodes = {};

  void addNode(Node node) {
    nodes[node.id] = node;
  }

  void addEdge(String fromId, String toId, double weight) {
    final from = nodes[fromId];
    final to = nodes[toId];
    if (from != null && to != null) {
      from.edges.add(Edge(to, weight));
    }
  }
}

// =====================
// PATHFINDING ALGORITHMS
// =====================
class PathFindingAlgorithms {
  final Distance _distance = Distance();

  // Hàm tính khoảng cách Haversine (heuristic cho A*)
  double _heuristic(LatLng a, LatLng b) {
    return _distance.as(LengthUnit.Kilometer, a, b);
  }

  // =====================
  // 1. DIJKSTRA - Đường ngắn (< 5km)
  // =====================
  List<Node> dijkstra(Graph graph, Node start, Node goal) {
    print('🔵 Running Dijkstra...');

    final distances = <String, double>{};
    final previous = <String, Node>{};
    final pq = PriorityQueue<_PQNode>((a, b) => a.priority.compareTo(b.priority));
    final visited = <String>{};

    // Khởi tạo
    for (var node in graph.nodes.values) {
      distances[node.id] = double.infinity;
    }
    distances[start.id] = 0;
    pq.add(_PQNode(start, 0));

    while (pq.isNotEmpty) {
      final current = pq.removeFirst();

      if (visited.contains(current.node.id)) continue;
      visited.add(current.node.id);

      // Tìm thấy đích
      if (current.node.id == goal.id) {
        return _reconstructPath(previous, start, goal);
      }

      // Duyệt các cạnh
      for (var edge in current.node.edges) {
        final neighbor = edge.target;
        final newDist = distances[current.node.id]! + edge.weight;

        if (newDist < distances[neighbor.id]!) {
          distances[neighbor.id] = newDist;
          previous[neighbor.id] = current.node;
          pq.add(_PQNode(neighbor, newDist));
        }
      }
    }

    return []; // Không tìm thấy đường
  }

  // =====================
  // 2. A* - Đường trung bình (5-20km)
  // =====================
  List<Node> aStar(Graph graph, Node start, Node goal) {
    print('🟢 Running A*...');

    final gScore = <String, double>{}; // Chi phí từ start
    final fScore = <String, double>{}; // gScore + heuristic
    final previous = <String, Node>{};
    final openSet = PriorityQueue<_PQNode>((a, b) => a.priority.compareTo(b.priority));
    final closedSet = <String>{};

    // Khởi tạo
    for (var node in graph.nodes.values) {
      gScore[node.id] = double.infinity;
      fScore[node.id] = double.infinity;
    }
    gScore[start.id] = 0;
    fScore[start.id] = _heuristic(start.position, goal.position);
    openSet.add(_PQNode(start, fScore[start.id]!));

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();

      if (closedSet.contains(current.node.id)) continue;

      // Tìm thấy đích
      if (current.node.id == goal.id) {
        return _reconstructPath(previous, start, goal);
      }

      closedSet.add(current.node.id);

      // Duyệt các cạnh
      for (var edge in current.node.edges) {
        final neighbor = edge.target;
        if (closedSet.contains(neighbor.id)) continue;

        final tentativeGScore = gScore[current.node.id]! + edge.weight;

        if (tentativeGScore < gScore[neighbor.id]!) {
          previous[neighbor.id] = current.node;
          gScore[neighbor.id] = tentativeGScore;
          fScore[neighbor.id] = gScore[neighbor.id]! +
              _heuristic(neighbor.position, goal.position);
          openSet.add(_PQNode(neighbor, fScore[neighbor.id]!));
        }
      }
    }

    return [];
  }

  // =====================
  // 3. BELLMAN-FORD - Đường dài (> 20km)
  // =====================
  List<Node> bellmanFord(Graph graph, Node start, Node goal) {
    print('🟡 Running Bellman-Ford...');

    final distances = <String, double>{};
    final previous = <String, Node?>{};

    // Khởi tạo
    for (var node in graph.nodes.values) {
      distances[node.id] = double.infinity;
      previous[node.id] = null;
    }
    distances[start.id] = 0;

    // Relax edges V-1 lần
    final nodesList = graph.nodes.values.toList();
    for (int i = 0; i < nodesList.length - 1; i++) {
      for (var node in nodesList) {
        if (distances[node.id] == double.infinity) continue;

        for (var edge in node.edges) {
          final newDist = distances[node.id]! + edge.weight;
          if (newDist < distances[edge.target.id]!) {
            distances[edge.target.id] = newDist;
            previous[edge.target.id] = node;
          }
        }
      }
    }

    // Kiểm tra negative cycle (optional)
    for (var node in nodesList) {
      for (var edge in node.edges) {
        if (distances[node.id]! + edge.weight < distances[edge.target.id]!) {
          print('⚠️ Negative cycle detected!');
          return [];
        }
      }
    }

    return _reconstructPath(previous.cast<String, Node>(), start, goal);
  }

  // =====================
  // HELPER: Tái tạo đường đi
  // =====================
  List<Node> _reconstructPath(
      Map<String, Node> previous,
      Node start,
      Node goal,
      ) {
    final path = <Node>[];
    Node? current = goal;

    while (current != null) {
      path.insert(0, current);
      if (current.id == start.id) break;
      current = previous[current.id];
    }

    return path;
  }
}

// =====================
// PRIORITY QUEUE NODE
// =====================
class _PQNode {
  final Node node;
  final double priority;

  _PQNode(this.node, this.priority);
}

// =====================
// SIMPLE PRIORITY QUEUE
// =====================
class PriorityQueue<T> {
  final List<T> _items = [];
  final Comparator<T> _comparator;

  PriorityQueue(this._comparator);

  void add(T item) {
    _items.add(item);
    _items.sort(_comparator);
  }

  T removeFirst() => _items.removeAt(0);

  bool get isNotEmpty => _items.isNotEmpty;
  bool get isEmpty => _items.isEmpty;
}