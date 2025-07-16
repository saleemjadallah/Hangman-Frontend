import 'package:flutter/material.dart';

class HangmanDrawing extends StatefulWidget {
  final int wrongGuesses;
  final int maxWrongGuesses;
  final double? width;
  final double? height;
  
  const HangmanDrawing({
    super.key,
    required this.wrongGuesses,
    required this.maxWrongGuesses,
    this.width,
    this.height,
  });

  @override
  State<HangmanDrawing> createState() => _HangmanDrawingState();
}

class _HangmanDrawingState extends State<HangmanDrawing>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.maxWrongGuesses,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) => 
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    ).toList();
  }

  @override
  void didUpdateWidget(HangmanDrawing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wrongGuesses > oldWidget.wrongGuesses && 
        widget.wrongGuesses <= _controllers.length) {
      _controllers[widget.wrongGuesses - 1].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width ?? 200, widget.height ?? 250),
      painter: HangmanPainter(
        wrongGuesses: widget.wrongGuesses,
        animations: _animations,
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int wrongGuesses;
  final List<Animation<double>> animations;

  HangmanPainter({
    required this.wrongGuesses,
    required this.animations,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Base
    if (wrongGuesses >= 1) {
      final progress = animations[0].value;
      canvas.drawLine(
        Offset(20, size.height - 20),
        Offset(20 + (size.width - 40) * progress, size.height - 20),
        paint,
      );
    }

    // Pole
    if (wrongGuesses >= 2) {
      final progress = animations[1].value;
      canvas.drawLine(
        const Offset(40, 230),
        Offset(40, 230 - 200 * progress),
        paint,
      );
    }

    // Top
    if (wrongGuesses >= 3) {
      final progress = animations[2].value;
      canvas.drawLine(
        const Offset(40, 30),
        Offset(40 + 100 * progress, 30),
        paint,
      );
    }

    // Noose
    if (wrongGuesses >= 4) {
      final progress = animations[3].value;
      canvas.drawLine(
        const Offset(140, 30),
        Offset(140, 30 + 40 * progress),
        paint,
      );
    }

    // Head
    if (wrongGuesses >= 5) {
      final progress = animations[4].value;
      canvas.drawCircle(
        const Offset(140, 85),
        15 * progress,
        paint,
      );
      
      // Face (appears at full progress)
      if (progress == 1.0) {
        // Eyes (X's for dead look)
        paint.strokeWidth = 2;
        canvas.drawLine(
          const Offset(133, 80),
          const Offset(137, 84),
          paint,
        );
        canvas.drawLine(
          const Offset(137, 80),
          const Offset(133, 84),
          paint,
        );
        canvas.drawLine(
          const Offset(143, 80),
          const Offset(147, 84),
          paint,
        );
        canvas.drawLine(
          const Offset(147, 80),
          const Offset(143, 84),
          paint,
        );
        
        // Sad mouth
        final path = Path();
        path.moveTo(130, 92);
        path.quadraticBezierTo(140, 88, 150, 92);
        canvas.drawPath(path, paint);
        paint.strokeWidth = 3;
      }
    }

    // Body
    if (wrongGuesses >= 6) {
      final progress = animations[5].value;
      canvas.drawLine(
        const Offset(140, 100),
        Offset(140, 100 + 60 * progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HangmanPainter oldDelegate) {
    return wrongGuesses != oldDelegate.wrongGuesses;
  }
}