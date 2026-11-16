import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../theme/apple_style.dart';

/// Exercises with a moving demonstration, by exercise id. The ankle
/// self-massage and the Kegel exercises have none.
const Map<String, ExerciseScene> exerciseScenes = {
  'walk': ExerciseScene.walk,
  'squat': ExerciseScene.sitToStand,
  'adductor': ExerciseScene.ballSqueeze,
};

enum ExerciseScene {
  /// Brisk walking outdoors, seen from the side. One loop is four step
  /// cycles, so the path and the trees come round seamlessly.
  walk(seconds: 4 * _stepCycle, still: 0.2),

  /// Sitting down slowly and standing up with a straight back, from the side.
  sitToStand(seconds: 6.4, still: 1.9),

  /// Squeezing a ball between the knees while seated, seen half from the
  /// front.
  ballSqueeze(seconds: 6.0, still: 2.0);

  const ExerciseScene({required this.seconds, required this.still});

  /// Length of one loop.
  final double seconds;

  /// The moment shown, without movement, when the phone asks for reduced
  /// motion.
  final double still;
}

/// A looping line figure in the brand gradient that shows how an exercise
/// is done. Purely visual: the steps below say the same in words.
class ExerciseAnimation extends StatefulWidget {
  const ExerciseAnimation({
    super.key,
    required this.scene,
    required this.playing,
  });

  final ExerciseScene scene;

  /// False while the card is folded: the figure stops, and starts over from
  /// the beginning when the card opens again.
  final bool playing;

  @override
  State<ExerciseAnimation> createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.scene.seconds * 1000).round()),
  );
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(ExerciseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !oldWidget.playing && !_still) _controller.value = 0;
    _sync();
  }

  void _sync() {
    if (_still) {
      _controller.value = widget.scene.still / widget.scene.seconds;
    } else if (!widget.playing) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: 150,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppleStyle.inputFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: RepaintBoundary(
          child: CustomPaint(painter: _ScenePainter(widget.scene, _controller)),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.progress) : super(repaint: progress);

  final ExerciseScene scene;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress.value * scene.seconds;
    switch (scene) {
      case ExerciseScene.walk:
        _paintWalk(_Stage(canvas, size, unitsTall: 112), t);
      case ExerciseScene.sitToStand:
        _paintSitToStand(_Stage(canvas, size, unitsTall: 112, centerX: -1), t);
      case ExerciseScene.ballSqueeze:
        // Seated: drawn larger, so the knees and the ball are easy to see.
        _paintBallSqueeze(_Stage(canvas, size, unitsTall: 84, centerX: 4), t);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.progress != progress;
}

// ---- Body ------------------------------------------------------------------
// Scene units: y points up from the floor and the standing figure is about
// 97 tall. Angles are in radians; positive means towards the front (+x).

const double _torsoLength = 31;
const double _neckLength = 2.5;
const double _headRadius = 7;
const double _upperArm = 16.5;
const double _foreArm = 15;
const double _thigh = 24;
const double _shin = 23;
const double _foot = 8.5;

/// Unit vector [angle] from straight down.
Offset _down(double angle) => Offset(math.sin(angle), -math.cos(angle));

/// Unit vector [angle] from straight up.
Offset _up(double angle) => Offset(math.sin(angle), math.cos(angle));

/// The knee of a leg reaching from [hip] to [ankle], bending forward.
Offset _knee(Offset hip, Offset ankle) {
  final Offset d = ankle - hip;
  final double reach = math.min(d.distance, _thigh + _shin - 0.01);
  final double bend = math.acos(
    ((_thigh * _thigh + reach * reach - _shin * _shin) / (2 * _thigh * reach))
        .clamp(-1.0, 1.0),
  );
  final double along = math.atan2(d.dy, d.dx);
  final Offset a =
      hip + Offset(math.cos(along + bend), math.sin(along + bend)) * _thigh;
  final Offset b =
      hip + Offset(math.cos(along - bend), math.sin(along - bend)) * _thigh;
  return a.dx >= b.dx ? a : b;
}

/// A figure seen from the side, facing right. The far arm and leg are drawn
/// faded behind the body.
class _SideFigure {
  _SideFigure({
    required this.hip,
    required double torso,
    required this.nearAnkle,
    required this.farAnkle,
    required double nearFoot,
    required double farFoot,
    required double nearUpper,
    required double nearFore,
    required double farUpper,
    required double farFore,
  }) {
    neck = hip + _up(torso) * _torsoLength;
    // The head tilts half as much as the back, so the eyes stay forward.
    head = neck + _up(torso / 2) * (_neckLength + _headRadius);
    shoulder = neck - _up(torso) * 2.5;
    nearKnee = _knee(hip, nearAnkle);
    farKnee = _knee(hip, farAnkle);
    // Foot angles are measured below the horizontal.
    nearToe =
        nearAnkle + Offset(math.cos(nearFoot), -math.sin(nearFoot)) * _foot;
    farToe = farAnkle + Offset(math.cos(farFoot), -math.sin(farFoot)) * _foot;
    nearElbow = shoulder + _down(nearUpper) * _upperArm;
    nearHand = nearElbow + _down(nearFore) * _foreArm;
    farElbow = shoulder + _down(farUpper) * _upperArm;
    farHand = farElbow + _down(farFore) * _foreArm;
  }

  final Offset hip;
  final Offset nearAnkle;
  final Offset farAnkle;
  late final Offset neck, head, shoulder;
  late final Offset nearKnee, farKnee, nearToe, farToe;
  late final Offset nearElbow, nearHand, farElbow, farHand;

  void paint(_Stage s) {
    s.line([shoulder, farElbow, farHand], s.far);
    s.line([hip, farKnee, farAnkle, farToe], s.far);
    s.line([hip, neck], s.near);
    s.head(head);
    s.line([hip, nearKnee, nearAnkle, nearToe], s.near);
    s.line([shoulder, nearElbow, nearHand], s.near);
  }
}

// ---- Scenes ----------------------------------------------------------------

/// Sit down slowly, hips back and chest forward; sit upright; lean forward
/// with a straight back; stand up until the knees are straight.
final _sitToStand = _Track(const [
  // seconds, hip x, hip y, back lean, upper arm, forearm
  [0.0, -1, 49.4, 0.02, 0.05, 0.25], // standing, knees straight
  [0.8, -1, 49.4, 0.02, 0.05, 0.25],
  [1.9, -7, 37, 0.45, 0.55, 0.85], // lowering slowly
  [2.9, -12, 29, 0.38, 0.45, 0.75],
  [3.3, -13, 26.5, 0.06, 0.25, 0.55], // seated, hands on the thighs
  [4.1, -13, 26.5, 0.06, 0.25, 0.55],
  [4.7, -11.5, 27, 0.62, 0.55, 0.85], // leaning forward, back straight
  [5.2, -6, 37.5, 0.45, 0.45, 0.7],
  [5.7, -1, 49.4, 0.02, 0.05, 0.25], // up, knees straight
  [6.4, -1, 49.4, 0.02, 0.05, 0.25],
]);

void _paintSitToStand(_Stage s, double t) {
  final [hipX, hipY, back, upper, fore] = _sitToStand.at(t);
  s.floor();
  // A sturdy chair without wheels.
  s.line(const [Offset(-27, 51), Offset(-25, 24), Offset(-5, 24)], s.prop);
  s.line(const [Offset(-24.5, 24), Offset(-24.5, 0)], s.prop);
  s.line(const [Offset(-6, 24), Offset(-6, 0)], s.prop);
  _SideFigure(
    hip: Offset(hipX, hipY),
    torso: back,
    nearAnkle: const Offset(0, 2.5),
    farAnkle: const Offset(2.5, 2.5),
    nearFoot: 0.25,
    farFoot: 0.25,
    nearUpper: upper,
    nearFore: fore,
    farUpper: upper + 0.12,
    farFore: fore + 0.1,
  ).paint(s);
}

const double _stride = 28; // how far a foot travels on the ground per step
const double _stance = 0.62; // share of the cycle a foot is on the ground
const double _stepCycle = 1.05; // seconds for two steps, a brisk pace

/// How far the ground slides back during one step cycle.
const double _cycleDistance = _stride / _stance;

/// Where a foot is at [phase] of the walking cycle: it lands on the heel,
/// rolls flat, pushes off from the toe and swings forward.
({Offset ankle, double angle}) _walkingFoot(double phase) {
  final double q = phase % 1;
  final double x, angle, lift;
  if (q < _stance) {
    final double u = q / _stance;
    x = _stride / 2 - u * _stride;
    angle = 0.12 + 0.13 * _ease(u / 0.15) + 0.55 * _ease((u - 0.7) / 0.3);
    lift = 0;
  } else {
    final double u = (q - _stance) / (1 - _stance);
    x = -_stride / 2 + _ease(u) * _stride;
    angle = 0.8 - 0.68 * _ease(u / 0.7);
    lift = math.sin(math.pi * u) * 5.5;
  }
  // On the ground the foot pivots on its heel or on its toe.
  final double y = math.max(2.5 + lift, 0.4 + _foot * math.sin(angle));
  return (ankle: Offset(x, y), angle: angle);
}

void _paintWalk(_Stage s, double t) {
  final double p = t / _stepCycle;
  // The figure walks on the spot; path and trees slide back at its pace.
  // Over the four cycles of a loop that is two tree gaps and twelve dashes.
  s.walkway(
    p * _cycleDistance,
    treeEvery: 2 * _cycleDistance,
    dashEvery: _cycleDistance / 3,
  );
  final near = _walkingFoot(p);
  final far = _walkingFoot(p + 0.5);
  // Arms swing against the legs, elbows bent for a brisk pace.
  final double swing = math.cos(2 * math.pi * p) * 0.45;
  _SideFigure(
    hip: Offset(0, 44.8 + 0.9 * math.cos(4 * math.pi * (p - 0.31))),
    torso: 0.08,
    nearAnkle: near.ankle,
    farAnkle: far.ankle,
    nearFoot: near.angle,
    farFoot: far.angle,
    nearUpper: -swing,
    nearFore: 0.8 - swing,
    farUpper: swing,
    farFore: 0.8 + swing,
  ).paint(s);
}

/// Squeeze with control, hold for 2–3 seconds, release slowly.
final _squeeze = _Track(const [
  // seconds, squeeze (0 resting, 1 squeezed)
  [0.0, 0], [0.7, 0], [1.5, 1], [4.0, 1], [5.5, 0], [6.0, 0],
]);

/// Seen from the front and turned about 32°: the figure faces down the
/// stage's +z axis, x runs across its hips. A turned view shows the thighs
/// and both knees, which a straight front view hides.
Offset _turned(double x, double y, double z) =>
    Offset(x * 0.8473 + z * 0.5312, y);

void _paintBallSqueeze(_Stage s, double t) {
  final double squeeze = _squeeze.at(t)[0];
  const double restRadius = 6;
  final double rx = restRadius - 2 * squeeze;
  // Squashed across, the ball bulges up and down.
  final double ry = restRadius * restRadius / rx;
  final double knee = rx + 2.3; // the knees touch the ball
  s.floor();
  // A chair: back legs and backrest first, then the seat and front legs.
  for (final (x, z) in const [(-14.0, -7.0), (14.0, -7.0)]) {
    s.line([_turned(x, 0, z), _turned(x, 24, z)], s.prop);
  }
  s.line([
    _turned(-13, 24, -7),
    _turned(-13, 52, -8),
    _turned(13, 52, -8),
    _turned(13, 24, -7),
  ], s.prop);
  s.line([
    _turned(-14, 24, -7),
    _turned(14, 24, -7),
    _turned(14, 24, 15),
    _turned(-14, 24, 15),
    _turned(-14, 24, -7),
  ], s.prop);
  for (final x in const [-14.0, 14.0]) {
    s.line([_turned(x, 0, 15), _turned(x, 24, 15)], s.prop);
  }
  // The figure's right side (+x) is the far one: arm faded, leg behind the
  // ball. Hands hold the sides of the seat.
  List<Offset> leg(double side) => [
    _turned(6 * side, 26.5, 0),
    _turned(knee * side, 24.5, 22),
    _turned(8.5 * side, 2.5, 23),
    _turned(9 * side, 0.5, 31),
  ];
  List<Offset> arm(double side) => [
    _turned(9.5 * side, 55, -1),
    _turned(12.5 * side, 40.5, 3),
    _turned(13 * side, 25.5, 9),
  ];
  s.line(arm(1), s.far);
  s.line(leg(1), s.near);
  final Offset ball = _turned(0, 24.5, 22);
  // Seen turned, the ball's width mixes its squashed width and its depth.
  s.ball(
    ball,
    math.sqrt(math.pow(rx * 0.8473, 2) + math.pow(restRadius * 0.5312, 2)),
    ry,
  );
  s.line([_turned(-6, 26.5, 0), _turned(6, 26.5, 0)], s.near);
  s.line([_turned(0, 26.5, 0), _turned(0, 57, -1)], s.near);
  s.line([_turned(-9.5, 55, -1), _turned(9.5, 55, -1)], s.near);
  s.head(_turned(0, 66.5, -1));
  s.line(leg(-1), s.near);
  s.line(arm(-1), s.near);
  // A small timer fills while the squeeze is held.
  s.timer(
    progress: ((t - 1.5) / 2.5).clamp(0.0, 1.0),
    opacity: _ease((t - 1.3) / 0.2) * (1 - _ease((t - 4.0) / 0.3)),
  );
}

// ---- Drawing ---------------------------------------------------------------

/// Maps scene units onto the canvas and holds the paints.
class _Stage {
  _Stage(
    this.canvas,
    this.size, {
    required double unitsTall,
    double centerX = 0,
  }) : scale = size.height / unitsTall {
    origin = Offset(size.width / 2 - centerX * scale, size.height - 7 * scale);
    ui.Gradient gradient(double alpha) =>
        ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          AppleStyle.gradientStart.withValues(alpha: alpha),
          AppleStyle.gradientEnd.withValues(alpha: alpha),
        ]);
    near = _stroke(4.4)..shader = gradient(1);
    far = _stroke(4.4)..shader = gradient(0.32);
    _fill = Paint()..shader = gradient(1);
    prop = _stroke(2.8)..color = const Color(0xFFC9CED6);
    _floor = _stroke(2)..color = const Color(0xFFD9DDE3);
  }

  final Canvas canvas;
  final Size size;
  final double scale;
  late final Offset origin;
  late final Paint near, far, prop;
  late final Paint _fill, _floor;

  Paint _stroke(double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * scale
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  double get _left => -origin.dx / scale;
  double get _right => (size.width - origin.dx) / scale;

  Offset _map(Offset p) =>
      Offset(origin.dx + p.dx * scale, origin.dy - p.dy * scale);

  /// One stroke through [points], so faded limbs do not darken at joints.
  void line(List<Offset> points, Paint paint) {
    final Path path = Path()
      ..moveTo(_map(points.first).dx, _map(points.first).dy);
    for (final p in points.skip(1)) {
      final Offset m = _map(p);
      path.lineTo(m.dx, m.dy);
    }
    canvas.drawPath(path, paint);
  }

  void head(Offset center) =>
      canvas.drawCircle(_map(center), _headRadius * scale, _fill);

  void floor() => line([Offset(_left, 0), Offset(_right, 0)], _floor);

  /// A dashed path with trees behind it, slid back by [scroll] units.
  void walkway(
    double scroll, {
    required double treeEvery,
    required double dashEvery,
  }) {
    final Paint tree = Paint()..color = const Color(0xFFE4E7EC);
    final Paint trunk = _stroke(2)..color = tree.color;
    for (
      var x = _first(30 - scroll, treeEvery, _left - 10);
      x < _right + 10;
      x += treeEvery
    ) {
      line([Offset(x, 0), Offset(x, 13)], trunk);
      canvas.drawCircle(_map(Offset(x, 21)), 8.5 * scale, tree);
    }
    for (
      var x = _first(-scroll, dashEvery, _left - dashEvery);
      x < _right;
      x += dashEvery
    ) {
      line([Offset(x, 0), Offset(x + dashEvery / 2, 0)], _floor);
    }
  }

  /// The first of the points `start + k * every` at or after [from].
  static double _first(double start, double every, double from) =>
      from + (start - from) % every;

  void ball(Offset center, double rx, double ry) {
    canvas.drawOval(
      Rect.fromCenter(
        center: _map(center),
        width: 2 * rx * scale,
        height: 2 * ry * scale,
      ),
      Paint()..color = AppleStyle.gradientStart,
    );
    canvas.drawCircle(
      _map(center + Offset(-rx * 0.38, ry * 0.38)),
      1.3 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  /// A ring in the top right corner that fills over a held position.
  void timer({required double progress, required double opacity}) {
    if (opacity <= 0) return;
    final Rect ring = Rect.fromCircle(
      center: Offset(size.width - 22, 22),
      radius: 8,
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      ring,
      paint..color = AppleStyle.track.withValues(alpha: opacity),
    );
    canvas.drawArc(
      ring,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint..color = AppleStyle.accent.withValues(alpha: opacity),
    );
  }
}

// ---- Timing ----------------------------------------------------------------

/// Smoothstep of [x], clamped to 0..1.
double _ease(double x) {
  final double c = x.clamp(0.0, 1.0);
  return c * c * (3 - 2 * c);
}

/// Keyframed values over time. A monotone cubic runs through the keys:
/// smooth, never overshooting, and exactly still between equal keys.
class _Track {
  _Track(this.keys)
    : _slopes = [for (var i = 0; i < keys.length; i++) _slopesAt(keys, i)];

  /// Each row: time in seconds, then one value per channel.
  final List<List<double>> keys;
  final List<List<double>> _slopes;

  static List<double> _slopesAt(List<List<double>> keys, int i) {
    return [
      for (var c = 1; c < keys[i].length; c++)
        if (i == 0 || i == keys.length - 1)
          0
        else
          _monotone(
            (keys[i][c] - keys[i - 1][c]) / (keys[i][0] - keys[i - 1][0]),
            (keys[i + 1][c] - keys[i][c]) / (keys[i + 1][0] - keys[i][0]),
          ),
    ];
  }

  /// Harmonic mean of the neighbouring slopes; zero at a turning point.
  static double _monotone(double before, double after) =>
      before * after <= 0 ? 0 : 2 / (1 / before + 1 / after);

  List<double> at(double t) {
    var i = 0;
    while (i < keys.length - 2 && t > keys[i + 1][0]) {
      i++;
    }
    final List<double> a = keys[i], b = keys[i + 1];
    final double h = b[0] - a[0];
    final double s = ((t - a[0]) / h).clamp(0.0, 1.0);
    final double s2 = s * s, s3 = s2 * s;
    return [
      for (var c = 1; c < a.length; c++)
        (2 * s3 - 3 * s2 + 1) * a[c] +
            (s3 - 2 * s2 + s) * h * _slopes[i][c - 1] +
            (3 * s2 - 2 * s3) * b[c] +
            (s3 - s2) * h * _slopes[i + 1][c - 1],
    ];
  }
}
