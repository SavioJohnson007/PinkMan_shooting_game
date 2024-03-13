import 'dart:math';

import 'package:flame/components.dart';

class Point {
  double x, y;

  Point(this.x, this.y);
}

bool pointInPolygon(Point point, List<Point> polygon) {
  int numVertices = polygon.length;
  double x = point.x, y = point.y;
  bool inside = false;

  Point p1 = polygon[0], p2;

  for (int i = 1; i <= numVertices; i++) {
    p2 = polygon[i % numVertices];

    if (y > min(p1.y, p2.y)) {
      if (y <= max(p1.y, p2.y)) {
        if (x <= max(p1.x, p2.x)) {
          double xIntersection =
              (y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;

          if (p1.x == p2.x || x <= xIntersection) {
            inside = !inside;
          }
        }
      }
    }

    p1 = p2;
  }

  return inside;
}

bool checkIf_overlapping(x,y,List<Vector2> vertices) {
  Point point = Point(x, y);
  List<Point> polygon = [];
  
  for(int i = 0;i< vertices.length;i++){
    polygon.add(Point(vertices[i].x,vertices[i].y));
  }

  if (pointInPolygon(point, polygon)) {
    return true;
  } else {
    return false;
  }
}
