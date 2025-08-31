import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';

/// Composant d'animation de particules pour les bonnes réponses
class GoodAnswerParticles extends StatelessWidget {
  final VoidCallback? onComplete;

  const GoodAnswerParticles({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: GoodAnswerGame(onComplete: onComplete),
      backgroundBuilder: (context) => Container(
        color: Colors.transparent,
      ),
    );
  }
}

class GoodAnswerGame extends FlameGame with TapDetector {
  final VoidCallback? onComplete;

  GoodAnswerGame({this.onComplete});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Obtenir la taille de l'écran
    final screenSize = size;
    final centerX = screenSize.x / 2;
    final centerY = screenSize.y / 2;

    // Palette de couleurs arc-en-ciel pour les étincelles
    final List<Color> colors = [
      Colors.amber, // Or
      Colors.orange, // Orange
      Colors.red, // Rouge
      Colors.pink, // Rose
      Colors.purple, // Violet
      Colors.blue, // Bleu
      Colors.cyan, // Cyan
      Colors.green, // Vert
      Colors.lime, // Vert lime
      Colors.yellow, // Jaune
      Colors.white, // Blanc
      Colors.lightBlue, // Bleu clair
      Colors.lightGreen, // Vert clair
      Colors.deepOrange, // Orange foncé
      Colors.indigo, // Indigo
    ];

    // Créer des particules multicolores pour les bonnes réponses (centre)
    final centerParticle = Particle.generate(
      count: 30,
      lifespan: 2.0,
      generator: (i) => AcceleratedParticle(
        position: Vector2(
          centerX + (i % 3 - 1) * 20, // Variation horizontale
          centerY + (i % 2 - 0.5) * 10, // Variation verticale
        ),
        speed: Vector2(
          (i % 5 - 2) * 30, // Variation horizontale de vitesse
          -200 - (i % 3) * 20, // Variation verticale de vitesse
        ),
        acceleration: Vector2(0, 300),
        child: CircleParticle(
          radius: 3 + (i % 2), // Variation de taille
          paint: Paint()..color = colors[i % colors.length],
        ),
      ),
    );

    // Créer des étincelles multicolores à gauche
    final leftParticle = Particle.generate(
      count: 20,
      lifespan: 2.0,
      generator: (i) => AcceleratedParticle(
        position: Vector2(
          centerX - 50 + (i % 3 - 1) * 15, // Variation horizontale
          centerY + (i % 2 - 0.5) * 8, // Variation verticale
        ),
        speed: Vector2(
          -150 - (i % 3) * 20, // Variation de vitesse vers la gauche
          -180 - (i % 2) * 15, // Variation verticale
        ),
        acceleration: Vector2(50, 250),
        child: CircleParticle(
          radius: 2 + (i % 2), // Variation de taille
          paint: Paint()..color = colors[(i + 3) % colors.length],
        ),
      ),
    );

    // Créer des étincelles multicolores à droite
    final rightParticle = Particle.generate(
      count: 20,
      lifespan: 2.0,
      generator: (i) => AcceleratedParticle(
        position: Vector2(
          centerX + 50 + (i % 3 - 1) * 15, // Variation horizontale
          centerY + (i % 2 - 0.5) * 8, // Variation verticale
        ),
        speed: Vector2(
          150 + (i % 3) * 20, // Variation de vitesse vers la droite
          -180 - (i % 2) * 15, // Variation verticale
        ),
        acceleration: Vector2(-50, 250),
        child: CircleParticle(
          radius: 2 + (i % 2), // Variation de taille
          paint: Paint()..color = colors[(i + 6) % colors.length],
        ),
      ),
    );

    // Créer des particules spéciales dorées pour l'effet "étoiles"
    final starParticle = Particle.generate(
      count: 10,
      lifespan: 2.5,
      generator: (i) => AcceleratedParticle(
        position: Vector2(
          centerX + (i % 5 - 2) * 30, // Plus espacées
          centerY + (i % 3 - 1) * 15,
        ),
        speed: Vector2(
          (i % 7 - 3) * 40, // Vitesse plus élevée
          -250 - (i % 4) * 30,
        ),
        acceleration: Vector2(0, 350),
        child: CircleParticle(
          radius: 4 + (i % 3), // Plus grandes
          paint: Paint()..color = Colors.amber.withOpacity(0.8),
        ),
      ),
    );

    // Créer des particules arc-en-ciel pour l'effet "confettis"
    final rainbowParticle = Particle.generate(
      count: 15,
      lifespan: 2.2,
      generator: (i) => AcceleratedParticle(
        position: Vector2(
          centerX + (i % 4 - 1.5) * 25,
          centerY + (i % 2 - 0.5) * 12,
        ),
        speed: Vector2(
          (i % 6 - 2.5) * 35,
          -220 - (i % 3) * 25,
        ),
        acceleration: Vector2(0, 320),
        child: CircleParticle(
          radius: 2 + (i % 2),
          paint: Paint()..color = colors[(i * 2) % colors.length],
        ),
      ),
    );

    // Ajouter tous les systèmes de particules
    add(ParticleSystemComponent(particle: centerParticle));
    add(ParticleSystemComponent(particle: leftParticle));
    add(ParticleSystemComponent(particle: rightParticle));
    add(ParticleSystemComponent(particle: starParticle));
    add(ParticleSystemComponent(particle: rainbowParticle));

    // Appeler le callback après l'animation
    Future.delayed(const Duration(seconds: 2), () {
      onComplete?.call();
    });
  }
}

/// Composant d'animation de particules pour les mauvaises réponses
class BadAnswerParticles extends StatelessWidget {
  final VoidCallback? onComplete;

  const BadAnswerParticles({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: BadAnswerGame(onComplete: onComplete),
      backgroundBuilder: (context) => Container(
        color: Colors.transparent,
      ),
    );
  }
}

class BadAnswerGame extends FlameGame with TapDetector {
  final VoidCallback? onComplete;

  BadAnswerGame({this.onComplete});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Créer des particules rouges pour les mauvaises réponses
    final particle = Particle.generate(
      count: 15,
      lifespan: 1.5,
      generator: (i) => AcceleratedParticle(
        speed: Vector2(50, -150),
        acceleration: Vector2(0, 200),
        child: CircleParticle(
          radius: 2,
          paint: Paint()..color = Colors.red,
        ),
      ),
    );

    add(ParticleSystemComponent(particle: particle));

    // Appeler le callback après l'animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      onComplete?.call();
    });
  }
}

/// Composant d'animation de confettis pour les niveaux
class LevelUpConfetti extends StatelessWidget {
  final VoidCallback? onComplete;

  const LevelUpConfetti({Key? key, this.onComplete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: LevelUpGame(onComplete: onComplete),
      backgroundBuilder: (context) => Container(
        color: Colors.transparent,
      ),
    );
  }
}

class LevelUpGame extends FlameGame with TapDetector {
  final VoidCallback? onComplete;

  LevelUpGame({this.onComplete});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    // Créer des confettis colorés pour les passages de niveau
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink
    ];

    for (int i = 0; i < 5; i++) {
      final particle = Particle.generate(
        count: 10,
        lifespan: 3.0,
        generator: (j) => AcceleratedParticle(
          speed: Vector2(200 * (j % 2 == 0 ? 1 : -1), -300),
          acceleration: Vector2(0, 400),
          child: CircleParticle(
            radius: 4,
            paint: Paint()..color = colors[i],
          ),
        ),
      );

      add(ParticleSystemComponent(
        particle: particle,
        position: Vector2(size.x / 2, size.y),
      ));
    }

    // Appeler le callback après l'animation
    Future.delayed(const Duration(seconds: 3), () {
      onComplete?.call();
    });
  }
}

/// Composant d'animation de pulsation pour les boutons
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.scale = 1.1,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void pulse() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pulse,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Composant d'animation de glissement pour les cartes
class SlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset offset;

  const SlideAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 50),
  }) : super(key: key);

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer l'animation automatiquement
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

/// Composant d'animation de rotation pour les icônes
class RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double angle;

  const RotateAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.angle = 360,
  }) : super(key: key);

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.angle * (3.14159 / 180), // Convertir en radians
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void rotate() {
    _controller.forward().then((_) {
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: rotate,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
