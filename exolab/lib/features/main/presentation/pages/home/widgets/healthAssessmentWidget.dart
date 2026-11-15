import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class HealthAssessmentWidget extends ConsumerStatefulWidget {
  final String? content;
  final VoidCallback onLaunchAnalysis;
  final bool isLoading;
  final String? onError;
  const HealthAssessmentWidget({
    super.key,
    this.content,
    required this.onLaunchAnalysis,
    this.isLoading = false,
    this.onError,
  });

  @override
  ConsumerState<HealthAssessmentWidget> createState() =>
      _HealthAssessmentWidgetState();
}

class _HealthAssessmentWidgetState
    extends ConsumerState<HealthAssessmentWidget> {
  @override
  Widget build(BuildContext context) {
    return CustContainer(
      height: 350,
      padding: const EdgeInsets.fromLTRB(20, 18, 8, 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            spacing: 15,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset("assets/icons/leaf.svg"),
              Text("Health Assessment", style: context.text.titleMedium),
            ],
          ),

          const SizedBox(height: 8),

          // Content
          // if loading
          if (widget.isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else if (widget.onError != null)
            Expanded(child: Center(child: Text("Error: ${widget.onError}")))
          else if (widget.content == null)
            Expanded(
              child: Column(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Waiting for the analysis to get started"),
                  ElevatedButton(
                    onPressed: widget.onLaunchAnalysis,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      "Start Analysis",
                      style: context.text.labelMedium!.copyWith(
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SelectionArea(
                    child: MarkdownBody(data: widget.content!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
