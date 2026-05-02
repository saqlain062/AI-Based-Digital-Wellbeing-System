import 'package:flutter/material.dart';
import 'package:wellbeing/util/theme/wellbeing_theme.dart';

class SCustomDialog extends StatelessWidget {
  const SCustomDialog({
    super.key,
    this.textHeading = 'null',
    this.textBody = 'null',
    this.secondButton = true,
    this.textButton1 = 'null',
    this.textButton2 = 'null',
    required this.pressed,
    required this.image,
    required this.pressed2,
  });
  final String image;
  final String textHeading;
  final String textBody;
  final bool secondButton;
  final String textButton1;
  final String textButton2;
  final Function() pressed;
  final Function() pressed2;
  @override
  Widget build(BuildContext context) {
    final isdark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: isdark ? WellbeingTheme.darkSurface : WellbeingTheme.lightSurface,
          borderRadius: WellbeingTheme.cardRadius,
          border: Border.all(
            color: isdark ? Colors.white.withAlpha(18) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // SvgPicture.asset(image),
              Text(
                textHeading,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                textBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color.fromRGBO(141, 143, 148, 1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (secondButton)
                    Expanded(
                  child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: isdark
                              ? Colors.white.withAlpha(8)
                              : const Color(0xFFF8FAFC),
                          borderRadius: WellbeingTheme.buttonRadius,
                        ),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors
                                    .transparent; // Custom color on press
                              }
                              return Colors
                                  .transparent; // No color change on long press
                            }),
                          ),
                          onPressed: pressed,
                          child: Text(
                            textButton1,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),

                  // SblueButton(pressed: pressed2, textButton2: textButton2)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
