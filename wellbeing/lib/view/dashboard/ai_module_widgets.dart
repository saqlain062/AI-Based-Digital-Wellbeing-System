import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

class AiModulePalette {
  static const Color blue = WellbeingTheme.indigo;
  static const Color teal = WellbeingTheme.cyan;
  static const Color purple = WellbeingTheme.purple;
  static const Color success = WellbeingTheme.success;
  static const Color warning = WellbeingTheme.warning;
  static const Color danger = WellbeingTheme.error;

  static Color backgroundTop(BuildContext context) {
    return WellbeingDecor.background(context);
  }

  static Color backgroundBottom(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121933)
        : const Color(0xFFF1F5F9);
  }

  static Color cardFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withAlpha(18)
        : Colors.white.withAlpha(220);
  }

  static Color cardStroke(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withAlpha(28)
        : const Color(0xFFE2E8F0);
  }

  static Color textPrimary(BuildContext context) {
    return WellbeingDecor.textPrimary(context);
  }

  static Color textSecondary(BuildContext context) {
    return WellbeingDecor.textSecondary(context);
  }

  static Color riskColor(String category) {
    switch (category) {
      case 'High':
        return danger;
      case 'Moderate':
        return warning;
      default:
        return success;
    }
  }
}

class AiModuleScaffold extends StatelessWidget {
  const AiModuleScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showBack = false,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AiModulePalette.textPrimary(context);
    final textSecondary = AiModulePalette.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: AiModulePalette.backgroundBottom(context),
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: AiModulePalette.backgroundTop(context),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AiModulePalette.backgroundTop(context),
                AiModulePalette.backgroundBottom(context),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showBack)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: AiIconButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title!,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle!,
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                    height: 1.35,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AiGlassCard extends StatelessWidget {
  const AiGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AiModulePalette.cardFill(context),
                    AiModulePalette.cardFill(context).withAlpha(110),
                  ],
                ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AiModulePalette.cardStroke(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AiSectionTitle extends StatelessWidget {
  const AiSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AiModulePalette.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class AiStatusBadge extends StatelessWidget {
  const AiStatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AiPrimaryButton extends StatelessWidget {
  const AiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AiModulePalette.blue,
            AiModulePalette.purple,
            AiModulePalette.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AiModulePalette.blue.withAlpha(70),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class AiSecondaryButton extends StatelessWidget {
  const AiSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: AiModulePalette.cardStroke(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AiModulePalette.textPrimary(context),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AiAnimatedProgressRing extends StatelessWidget {
  const AiAnimatedProgressRing({
    super.key,
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentColor = Colors.white;
    final labelColor = Colors.white.withAlpha(isDark ? 190 : 215);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: 132,
          height: 132,
          child: CustomPaint(
            painter: _ProgressRingPainter(progress: value, color: color),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      color: percentColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Risk score',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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
}

class AiIconButton extends StatelessWidget {
  const AiIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AiModulePalette.cardFill(context),
          border: Border.all(color: AiModulePalette.cardStroke(context)),
        ),
        child: Icon(
          icon,
          color: AiModulePalette.textPrimary(context),
          size: 20,
        ),
      ),
    );
  }
}

class AiFadeSlideIn extends StatelessWidget {
  const AiFadeSlideIn({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class AiMetricPill extends StatelessWidget {
  const AiMetricPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 18 : 120,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AiModulePalette.textSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: AiModulePalette.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class AiAppIcon extends StatelessWidget {
  const AiAppIcon({super.key, required this.name, this.iconBytes});

  final String name;
  final Uint8List? iconBytes;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(name);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, accent.withAlpha(120)],
        ),
      ),
      child: iconBytes != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.memory(iconBytes!, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  Color _accent(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('youtube')) return const Color(0xFFFF4F70);
    if (lower.contains('whatsapp')) return const Color(0xFF2BD38B);
    if (lower.contains('instagram')) return const Color(0xFFE874FF);
    if (lower.contains('chrome')) return const Color(0xFF4FA7FF);
    return AiModulePalette.teal;
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11
      ..color = Colors.white.withAlpha(54);

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 19
      ..color = color.withAlpha(72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          Color.lerp(color, Colors.white, 0.16)!,
          color,
          Color.lerp(color, AiModulePalette.purple, 0.35)!,
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, glow);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
