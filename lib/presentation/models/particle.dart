import 'dart:ui';

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;
  double lifespan;

  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    this.lifespan = 1.0,
  });

  void update() {
    position += velocity;
    lifespan -= 0.015;
  }

  bool isDead() => lifespan <= 0;
}
