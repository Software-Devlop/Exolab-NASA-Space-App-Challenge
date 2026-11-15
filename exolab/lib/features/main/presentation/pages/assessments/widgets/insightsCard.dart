import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
import 'package:exolab/core/presentation/globalWidgets/custElevatedButton.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';

class InsightsCard extends StatelessWidget {
  final IconData icon;
  final String? explanation;
  final bool showDisclaimer;
  final bool isLoading;
  final String? error;
  final VoidCallback? onAnalyze;

  const InsightsCard({
    super.key,
    required this.icon,
    this.explanation,
    this.showDisclaimer = true,
    this.isLoading = false,
    this.error,
    this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CustContainer(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, size: 20, color: colors.primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'AI Health Insights',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Body: loading -> error -> analyze button -> explanation
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        'This might take up to a few minutes depending on your computer '
                        'performance as it runs locally, please be patient',
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else if (error != null) ...[
              Text(
                'Problem: $error',
                style: context.text.bodyMedium?.copyWith(color: colors.error),
              ),
              const SizedBox(height: 12),
              CustElevatedButton(
                onPressed: onAnalyze ?? () {},
                child: const Text('Try again'),
              ),
            ] else if (explanation == null)
              CustElevatedButton(
                onPressed: onAnalyze ?? () {},
                child: const Text(
                  'Analyze Data',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              Text(
                explanation!,
                style: context.text.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colors.onSurface.withAlpha(190),
                ),
              ),

            // Disclaimer
            // if (showDisclaimer) ...[
            //   const SizedBox(height: 18),
            //   Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 12,
            //       vertical: 10,
            //     ),
            //     decoration: BoxDecoration(
            //       color: colors.primary.withAlpha(15),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Icon(Icons.info_outline, size: 17, color: colors.primary),
            //         const SizedBox(width: 8),
            //         Expanded(
            //           child: Text(
            //             'These insights are informational and do not replace professional medical evaluation.',
            //             style: context.text.bodySmall?.copyWith(
            //               height: 1.4,
            //               color: colors.onSurface.withAlpha(190),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
