import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

//========================================
const String kMessage =
    'Chúc bạn một mùa Giáng Sinh ấm áp, an lành bên những người thân yêu. '
    'Chúc năm mới 2027 bình an, hạnh phúc và mọi điều ước đều thành hiện thực!';
const String kFrom = 'Gửi bạn, với tất cả yêu thương';
// ========================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const XmasApp());
}

class XmasApp extends StatelessWidget {
  const XmasApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Thiệp Giáng Sinh',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
    home: const CardPage(),
  );
}

class Burst {
  Burst(this.pos, this.start, this.seed);
  final Offset pos;
  final double start;
  final int seed;
}

double clamp01(double v) => v.clamp(0.0, 1.0).toDouble();

class CardPage extends StatefulWidget {
  const CardPage({super.key});
  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> with TickerProviderStateMixin {
  final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker;
  late final AnimationController _flip, _title, _type;
  late final Animation<double> _titleScale, _titleFade;
  final List<Burst> _bursts = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((d) => _time.value = d.inMicroseconds / 1e6)..start();
    _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _title = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _type = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _titleScale = CurvedAnimation(parent: _title, curve: Curves.elasticOut);
    _titleFade = CurvedAnimation(parent: _title, curve: const Interval(0, 0.3));
    _flip.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _title.forward();
        _type.forward();
      }
      if (s == AnimationStatus.dismissed) _bursts.clear();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _flip.dispose();
    _title.dispose();
    _type.dispose();
    super.dispose();
  }

  void _close() {
    _title.reset();
    _type.reset();
    _flip.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.3,
            colors: [Color(0xFF1B1F4A), Color(0xFF05060F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AnimatedBuilder(
                  animation: _flip,
                  builder: (_, __) {
                    final a = Curves.easeInOutCubic.transform(_flip.value) * math.pi;
                    final front = a < math.pi / 2;
                    final lift = 1 + 0.04 * math.sin(a); // hơi phóng to khi lật
                    return Transform.scale(
                      scale: lift,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(a),
                        child: front
                            ? _cover()
                            : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: _scene(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- BÌA THIỆP ----------------
  Widget _cover() {
    return GestureDetector(
      onTap: _flip.forward,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB3122B), Color(0xFF5E0816)],
          ),
          border: Border.all(color: const Color(0xFFFFD66B), width: 3),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: SnowPainter(_time)),
              ValueListenableBuilder<double>(
                valueListenable: _time,
                builder: (_, t, __) {
                  final pulse = 1 + 0.06 * math.sin(t * 3.2);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, math.sin(t * 2) * 10),
                        child: Transform.rotate(
                          angle: math.sin(t * 2.4) * 0.08,
                          child: const Text('🎁', style: TextStyle(fontSize: 110)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Một tấm thiệp\ndành riêng cho bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFE9A8),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Transform.scale(
                        scale: pulse,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: const Color(0xFFFFD66B), width: 2),
                            color: Colors.white.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD66B).withOpacity(0.25 + 0.2 * math.sin(t * 3.2)),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                          child: const Text('Chạm để mở  ✨',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- MẶT TRONG ----------------
  Widget _scene() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: (d) {
              final now = _time.value;
              _bursts.removeWhere((b) => now - b.start > 2);
              _bursts.add(Burst(d.localPosition, now, _rng.nextInt(1 << 20)));
            },
            child: CustomPaint(painter: ScenePainter(_time, _bursts), size: Size.infinite),
          ),
          Positioned(top: 38, left: 0, right: 0, child: IgnorePointer(child: _titleWidget())),
          Positioned(left: 14, right: 14, bottom: 12, child: IgnorePointer(child: _messagePanel())),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(Icons.replay_rounded),
              color: Colors.white70,
              tooltip: 'Đóng thiệp',
              onPressed: _close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleWidget() {
    return ValueListenableBuilder<double>(
      valueListenable: _time,
      builder: (_, t, __) {
        final s = -0.3 + 1.6 * ((t * 0.35) % 1.0);
        final grad = LinearGradient(
          colors: const [Color(0xFFFFC94D), Colors.white, Color(0xFFFFC94D)],
          stops: [clamp01(s - 0.25), clamp01(s), clamp01(s + 0.25)],
        );
        return FadeTransition(
          opacity: _titleFade,
          child: ScaleTransition(
            scale: _titleScale,
            child: Transform.translate(
              offset: Offset(0, math.sin(t * 2) * 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✦ GIÁNG SINH AN LÀNH ✦',
                      style: TextStyle(fontSize: 12, letterSpacing: 3, color: Color(0xFFFFD66B))),
                  const SizedBox(height: 6),
                  ShaderMask(
                    shaderCallback: (r) => grad.createShader(r),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'Merry\nChristmas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 54,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messagePanel() {
    return FadeTransition(
      opacity: _titleFade,
      child: AnimatedBuilder(
        animation: _type,
        builder: (_, __) {
          final n = (kMessage.length * _type.value).floor();
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1040).withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14.5, height: 1.4),
                    children: [
                      TextSpan(text: kMessage.substring(0, n), style: const TextStyle(color: Colors.white)),
                      TextSpan(text: kMessage.substring(n), style: const TextStyle(color: Colors.transparent)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(kFrom,
                    style: const TextStyle(
                        fontSize: 12.5, fontStyle: FontStyle.italic, color: Color(0xFFFFD66B))),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
//                              VẼ CẢNH
// =====================================================================

const _burstCols = [
  Color(0xFFFFD166),
  Color(0xFFFF6B8B),
  Color(0xFF6BE3FF),
  Color(0xFFFFFFFF),
  Color(0xFFFF9F43),
  Color(0xFF9DFFB0),
];

void drawSnow(Canvas c, Size s, double t, {int count = 90}) {
  final p = Paint();
  for (int i = 0; i < count; i++) {
    final r = math.Random(i * 7919 + 13);
    final depth = r.nextDouble();
    final x0 = r.nextDouble() * s.width;
    final y0 = r.nextDouble() * s.height;
    final phase = r.nextDouble() * 6.28;
    final speed = 18 + depth * 60;
    final y = (y0 + t * speed) % s.height;
    final x = (x0 + math.sin(t * 0.8 + phase) * (12 + depth * 18)) % s.width;
    p.color = Color.fromRGBO(255, 255, 255, 0.35 + depth * 0.6);
    c.drawCircle(Offset(x, y), 1 + depth * 2.8, p);
  }
}

void drawBurst(Canvas c, Offset o, double age, int seed, double power) {
  const life = 1.8;
  if (age < 0 || age > life) return;
  final r = math.Random(seed);
  final fade = 1 - age / life;
  final col = _burstCols[r.nextInt(_burstCols.length)];
  final col2 = _burstCols[r.nextInt(_burstCols.length)];
  final paint = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  Offset pos(double ang, double sp, double a) {
    final k = 1 - math.exp(-3 * a);
    return o + Offset(math.cos(ang) * sp * k, math.sin(ang) * sp * k + 70 * power * a * a);
  }

  for (int i = 0; i < 44; i++) {
    final ang = i / 44 * 2 * math.pi;
    final sp = (80 + r.nextDouble() * 70) * power;
    paint
      ..color = (i.isEven ? col : col2).withOpacity(fade)
      ..strokeWidth = 2.4 * fade + 0.6;
    c.drawLine(pos(ang, sp, age), pos(ang, sp, math.max(0, age - 0.07)), paint);
  }
  if (age < 0.18) {
    final k = 1 - age / 0.18;
    c.drawCircle(o, 34 * power * k, Paint()..color = Colors.white.withOpacity(0.6 * k));
  }
}

Path starPath(Offset c, double R, double r, double rot) {
  final p = Path();
  for (int i = 0; i < 10; i++) {
    final rad = i.isEven ? R : r;
    final a = rot - math.pi / 2 + i * math.pi / 5;
    final pt = Offset(c.dx + math.cos(a) * rad, c.dy + math.sin(a) * rad);
    i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
  }
  return p..close();
}

void drawEmoji(Canvas c, String text, Offset o, double fs) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: fs)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, o);
}

class SnowPainter extends CustomPainter {
  SnowPainter(this.time) : super(repaint: time);
  final ValueNotifier<double> time;
  @override
  void paint(Canvas canvas, Size size) => drawSnow(canvas, size, time.value, count: 70);
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ScenePainter extends CustomPainter {
  ScenePainter(this.time, this.bursts) : super(repaint: time);
  final ValueNotifier<double> time;
  final List<Burst> bursts;

  static final _stars = List.generate(80, (i) {
    final r = math.Random(i * 31 + 7);
    return [r.nextDouble(), r.nextDouble() * 0.6, r.nextDouble() * 6.28, 0.6 + r.nextDouble() * 1.6];
  });
  static const _lightCols = [Color(0xFFFF4D6D), Color(0xFFFFD166), Color(0xFF4CC9F0), Color(0xFF80ED99)];
  static const _ballCols = [Color(0xFFE63946), Color(0xFFFFC857), Color(0xFF4EA8DE), Color(0xFFC77DFF)];

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height, t = time.value;
    final rect = Offset.zero & s;

    // Bầu trời
    c.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF060B30), Color(0xFF1A2A6C), Color(0xFF6A3F8E), Color(0xFFD97B8D)],
          stops: [0, 0.45, 0.75, 1],
        ).createShader(rect),
    );

    // Sao lấp lánh
    final sp = Paint();
    for (final st in _stars) {
      final tw = 0.5 + 0.5 * math.sin(t * (1.5 + st[3]) + st[2]);
      sp.color = Colors.white.withOpacity(0.25 + 0.75 * tw);
      c.drawCircle(Offset(st[0] * w, st[1] * h), st[3] * 0.7 * (0.7 + 0.5 * tw), sp);
    }

    // Pháo hoa tự động
    const period = 2.2;
    for (final off in [0.0, 1.1]) {
      final tt = t + off;
      final k = (tt / period).floor();
      final r = math.Random(k * 97 + (off * 10).toInt());
      drawBurst(
        c,
        Offset(w * (0.15 + r.nextDouble() * 0.7), h * (0.1 + r.nextDouble() * 0.25)),
        tt - k * period,
        k * 13 + (off * 7).toInt(),
        w / 380,
      );
    }

    // Trăng lưỡi liềm
    final mc = Offset(w * 0.16, h * 0.3);
    c.drawCircle(
      mc,
      w * 0.13,
      Paint()
        ..shader = const RadialGradient(colors: [Color(0x55FFF3C4), Color(0x00FFF3C4)])
            .createShader(Rect.fromCircle(center: mc, radius: w * 0.13)),
    );
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: mc, radius: w * 0.05)),
      Path()..addOval(Rect.fromCircle(center: mc.translate(w * 0.025, -w * 0.012), radius: w * 0.044)),
    );
    c.drawPath(moon, Paint()..color = const Color(0xFFFFF3C4));

    // Xe trượt tuyết & tuần lộc
    const cyc = 14.0;
    final p = (t % cyc) / cyc;
    final sx = w * (1.25 - p * 1.5);
    final sy = h * 0.25 + math.sin(p * math.pi * 4) * h * 0.025;
    final fs = w * 0.075;
    for (int i = 0; i < 18; i++) {
      final tx = sx + fs * 3.4 + i * w * 0.018;
      final ty = sy + fs * 0.6 + math.sin(i * 0.6 + t * 6) * 6;
      final a = clamp01((1 - i / 18) * (0.5 + 0.5 * math.sin(t * 10 + i)));
      c.drawCircle(Offset(tx, ty), 3.2 * (1 - i / 18) + 0.5, Paint()..color = const Color(0xFFFFE08A).withOpacity(a));
    }
    drawEmoji(c, '🦌🦌🛷', Offset(sx, sy), fs);
    drawEmoji(c, '🎅', Offset(sx + fs * 2.25, sy - fs * 0.5), fs * 0.9);

    // Đồi xa
    final far = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 6) {
      far.lineTo(x, h * 0.745 + math.sin(x / w * 3.2 + 1.0) * h * 0.018);
    }
    far
      ..lineTo(w, h)
      ..close();
    c.drawPath(
      far,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9BDF0), Color(0xFF6F86C6)],
        ).createShader(Rect.fromLTWH(0, h * 0.7, w, h * 0.3)),
    );

    // Cây thông
    _tree(c, w, h, t);

    // Đồi gần
    final near = Path()..moveTo(0, h);
    for (double x = 0; x <= w; x += 6) {
      near.lineTo(x, h * 0.80 + math.sin(x / w * 2.4) * h * 0.022);
    }
    near
      ..lineTo(w, h)
      ..close();
    c.drawPath(
      near,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFCFDCFF)],
        ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.22)),
    );

    // Hộp quà nảy nhẹ
    final gy = h * 0.862;
    _gift(c, Offset(w * 0.20, gy), w * 0.11, const Color(0xFFD62839), const Color(0xFFFFD66B), t, 0);
    _gift(c, Offset(w * 0.31, gy), w * 0.075, const Color(0xFF2D6CDF), Colors.white, t, 1.3);
    _gift(c, Offset(w * 0.72, gy), w * 0.10, const Color(0xFF1FA67A), const Color(0xFFFFD66B), t, 2.1);
    _gift(c, Offset(w * 0.83, gy), w * 0.07, const Color(0xFFB44CE8), Colors.white, t, 3.4);

    // Tuyết phía trước
    drawSnow(c, s, t, count: 110);

    // Pháo hoa khi chạm
    for (final b in bursts) {
      drawBurst(c, b.pos, t - b.start, b.seed, w / 380 * 1.2);
    }
  }

  void _gift(Canvas c, Offset bottomCenter, double size, Color col, Color ribbon, double t, double phase) {
    final dy = -math.max(0.0, math.sin(t * 2.5 + phase)) * 6;
    final r = Rect.fromLTWH(bottomCenter.dx - size / 2, bottomCenter.dy - size * 0.85 + dy, size, size * 0.85);
    c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), Paint()..color = col);
    final rp = Paint()..color = ribbon;
    c.drawRect(Rect.fromLTWH(r.center.dx - size * 0.07, r.top, size * 0.14, r.height), rp);
    c.drawRect(Rect.fromLTWH(r.left, r.center.dy - size * 0.07, r.width, size * 0.14), rp);
    c.drawCircle(Offset(r.center.dx - size * 0.1, r.top - size * 0.04), size * 0.1, rp);
    c.drawCircle(Offset(r.center.dx + size * 0.1, r.top - size * 0.04), size * 0.1, rp);
  }

  void _tree(Canvas c, double w, double h, double t) {
    final cx = w * 0.5, baseY = h * 0.845, trunkH = h * 0.045, F = h * 0.40;
    final topY = baseY - trunkH - F;
    final hws = [w * 0.15, w * 0.225, w * 0.30];

    c.save();
    c.translate(cx, baseY);
    c.rotate(math.sin(t * 1.3) * 0.01);
    c.translate(-cx, -baseY);

    c.drawRect(Rect.fromLTWH(cx - w * 0.03, baseY - trunkH - 2, w * 0.06, trunkH + 8),
        Paint()..color = const Color(0xFF6B4226));

    for (int i = 2; i >= 0; i--) {
      final apex = topY + F * i * 0.27;
      final bot = topY + F * (0.42 + i * 0.29);
      final hw = hws[i];
      final path = Path()
        ..moveTo(cx, apex)
        ..lineTo(cx + hw, bot)
        ..quadraticBezierTo(cx, bot + F * 0.07, cx - hw, bot)
        ..close();
      c.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2FA85A), Color(0xFF0E5A30)],
          ).createShader(Rect.fromLTRB(cx - hw, apex, cx + hw, bot)),
      );
      c.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = Colors.white.withOpacity(0.55),
      );

      final r = math.Random(100 + i);
      // Đèn nhấp nháy
      final nL = 9 + i * 3;
      for (int k = 0; k < nL; k++) {
        final v = 0.25 + r.nextDouble() * 0.7;
        final u = (r.nextDouble() * 2 - 1) * 0.82;
        final pos = Offset(cx + u * hw * v, apex + (bot - apex) * v);
        final col = _lightCols[(k + i) % _lightCols.length];
        final b = 0.5 + 0.5 * math.sin(t * 3.2 + k * 1.9 + i);
        c.drawCircle(
          pos,
          w * 0.03,
          Paint()
            ..color = col.withOpacity(0.55 * b)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
        );
        c.drawCircle(pos, w * 0.009,
            Paint()..color = Color.lerp(col, Colors.white, 0.5 * b)!.withOpacity(0.55 + 0.45 * b));
      }
      // Quả châu
      final nB = 3 + i * 2;
      for (int k = 0; k < nB; k++) {
        final v = 0.35 + r.nextDouble() * 0.6;
        final u = (r.nextDouble() * 2 - 1) * 0.75;
        final pos = Offset(cx + u * hw * v, apex + (bot - apex) * v);
        final col = _ballCols[(k + i) % _ballCols.length];
        final rad = w * 0.017;
        c.drawCircle(
          pos,
          rad,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.4, -0.4),
              colors: [Colors.white, col, Color.lerp(col, Colors.black, 0.5)!],
              stops: const [0, 0.35, 1],
            ).createShader(Rect.fromCircle(center: pos, radius: rad)),
        );
      }
    }

    // Ngôi sao đỉnh cây
    final sc = Offset(cx, topY + w * 0.01);
    final pulse = 0.5 + 0.5 * math.sin(t * 2.5);
    c.drawCircle(
      sc,
      w * 0.11,
      Paint()
        ..color = const Color(0xFFFFE08A).withOpacity(0.3 + 0.35 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    final ray = Paint()
      ..color = const Color(0xFFFFF1B8).withOpacity(0.35 + 0.3 * pulse)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int k = 0; k < 8; k++) {
      final a = t * 0.5 + k * math.pi / 4;
      final len = w * 0.16 * (0.8 + 0.3 * pulse);
      c.drawLine(sc, sc + Offset(math.cos(a) * len, math.sin(a) * len), ray);
    }
    c.drawPath(starPath(sc, w * 0.055, w * 0.024, math.sin(t) * 0.15), Paint()..color = const Color(0xFFFFD43B));
    c.drawPath(
      starPath(sc, w * 0.055, w * 0.024, math.sin(t) * 0.15),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withOpacity(0.8),
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}