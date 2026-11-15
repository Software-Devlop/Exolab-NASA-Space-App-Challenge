import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/llm/presentation/controllers/llmController.dart';
import 'package:exolab/features/main/presentation/pages/home/widgets/aiAssistantWidget.dart';
import 'package:exolab/features/main/presentation/pages/home/widgets/anatomyWidget.dart';
import 'package:exolab/features/main/presentation/pages/home/widgets/healthAssessmentWidget.dart';
import 'package:exolab/features/task/presentation/controllers/taskController.dart';
import 'package:exolab/features/task/presentation/widgets/healthTasksWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exolab/features/aiModel/presentation/controllers/aiController.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  Color? borderColor;
  InjurySeverity? severityLevel;
  String? selectedOrgan;
  String? situationDesc;

  String randomText =
      "Lorem ispum dolor sit amet constectitur adipsicing domer saket redeki robn denov on sond! Sibd ksv oedd. Lorem ispum dolor sit amet constectitur adipsicing domer saket redeki robn denov, on sond sibd ksv oedd. Lorem ispum dolor sit amet constectitur adipsicing domer saket redeki robn denov on sond! Sibd ksv oedd.";

  final String exampleHealthAssessment =
      """Hello, and thank you for staying on top of your health checks. 👋 Here is the big picture. 🌍

**The good news. 💚** Your heart and blood vessels are healthy, and your bones are strong. 🦴 Your blood pressure, heart rate, and oxygen level are all in your normal range.

**Your chest. 🩹** The pain in your upper left chest comes from the knock you took. It is a mild muscle problem, not a heart problem, and it is getting better with time. Keep resting that area and avoid movements that make it hurt. If the pain gets worse, spreads, or comes with shortness of breath, tell the medical team right away. 🚨

**Your stress, sleep, and mood. 🧠** This is the area that needs the most care right now. Your stress is high, and your sleep and mood are low. 😔 Living far from home, in a small space with little privacy, can make anyone feel this way. It is a normal response to a hard situation, and it does not mean you are doing anything wrong. 🤍

**Why it matters. ❤️** Your heart is healthy today. But stress and poor sleep that continue for weeks could slowly strain it. Looking after your mind is also a way of protecting your heart.

**What helps. 🌱** Keep a steady sleep routine, 😴 take short breaks, and stay active within what your chest allows. 🧘 Stay in touch with your family, friends, and crew, 👨‍👩‍👧 and talk to the flight surgeon or the support team on the ground about how you feel. You are not alone up there. 🚀 The team on Earth is with you. 🌎💙""";

  int currentChatPage = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.watch(taskControllerProvider.notifier).loadTasks();

      await ref.read(aiMLControllerProvider.notifier).initialize();

      final controller = ref.read(aiMLControllerProvider.notifier);

      final input = [
        [1],
      ];

      final output = [
        [0],
      ];

      await controller.runModel(input: input, output: output);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> items = [
    "Heart Rate",
    "Blood Oxygen",
    "Sleep",
    "Exercise",
  ];

  @override
  Widget build(BuildContext context) {
    currentChatPage = ref.watch(llmControllerProvider).currentChat;
    final chatWatch = ref.watch(llmControllerProvider).chats;
    final mlWatch = ref.watch(aiMLControllerProvider);
    final allTask = ref.watch(taskControllerProvider).tasks;
    // print(allTask);

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 10, bottom: 0),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        thickness: 9,
        radius: const Radius.circular(20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 18, 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greetings
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good afternoon User!",
                        style: context.text.headlineSmall,
                      ),
                      Text(
                        "A clear view of your health, here on board.",
                        style: context.text.bodySmall!.copyWith(
                          color: context.colors.onSurface.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      // Left Section
                      Expanded(
                        child: Column(
                          spacing: 15,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Health Assessment
                            HealthAssessmentWidget(
                              content: exampleHealthAssessment,
                              // mlWatch.output.isEmpty
                              //     ? null
                              //     : mlWatch.output.toString(),
                              isLoading: mlWatch.mlLoading,
                              onError: mlWatch.mlError,
                              onLaunchAnalysis: () async {
                                final controller = ref.read(
                                  aiMLControllerProvider.notifier,
                                );

                                final input = [
                                  [1],
                                ];

                                final output = [
                                  [0],
                                ];

                                await controller.runModel(
                                  input: input,
                                  output: output,
                                );
                              },
                            ),

                            // AI Assisstant (ExoLab Assistant)
                            AIAssistantWidget(
                              chatWatch: chatWatch,
                              currentChatPage: currentChatPage,
                              suggestions: [],
                            ),

                            // ElevatedButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       if (suggi.isEmpty) {
                            //         suggi = [
                            //           "First suggestion",
                            //           "Second suggestion",
                            //           "Something",
                            //           "else",
                            //         ];
                            //       } else {
                            //         suggi = [];
                            //       }
                            //     });
                            //   },
                            //   child: Text("Suggi show!"),
                            // ),
                          ],
                        ),
                      ),

                      // Right Sections
                      Expanded(
                        child: Column(
                          spacing: 15,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animated injury details panel
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end:
                                        severityLevel != null &&
                                            selectedOrgan != null
                                        ? 280
                                        : 0,
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  builder: (context, width, child) {
                                    return SizedBox(
                                      width: width,
                                      height: 430,
                                      child: ClipRect(
                                        child: width < 240
                                            ? const SizedBox.shrink()
                                            : Opacity(
                                                opacity: ((width - 240) / 40)
                                                    .clamp(0.0, 1.0),
                                                child: child,
                                              ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 280,
                                    height: 430,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: context.colors.surface,
                                      border: Border.all(
                                        color: borderColor ?? Colors.purple,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selectedOrgan
                                                  ?.replaceAll('_', ' ')
                                                  .split(' ')
                                                  .map(
                                                    (word) => word.isEmpty
                                                        ? word
                                                        : '${word[0].toUpperCase()}${word.substring(1)}',
                                                  )
                                                  .join(' ') ??
                                              '',
                                          style: context.text.titleMedium,
                                        ),

                                        const SizedBox(height: 10),
                                        Text(
                                          'Severity: ${severityLevel?.name ?? ""}',
                                          style: context.text.labelLarge,
                                        ),

                                        const SizedBox(height: 10),
                                        Text(
                                          situationDesc ?? randomText,
                                          style: context.text.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Anatomy viewer takes remaining space
                                Expanded(
                                  child: AnatomyViewerTest(
                                    injuredParts: {
                                      'chest_left': InjurySeverity.mild,
                                      'abdomen_upper_left':
                                          InjurySeverity.severe,
                                      'index_proximal_right':
                                          InjurySeverity.mild,
                                    },
                                    onPartSelected: (partId, severity) {
                                      setState(() {
                                        if (partId == null) {
                                          severityLevel = null;
                                          selectedOrgan = null;
                                          borderColor = null;
                                          return;
                                        }

                                        severityLevel = severity;
                                        selectedOrgan = partId;

                                        switch (severityLevel) {
                                          case InjurySeverity.severe:
                                            borderColor = const Color(
                                              0xFFFF3030,
                                            );
                                          case InjurySeverity.moderate:
                                            borderColor = const Color(
                                              0xFFFF6400,
                                            );
                                          case InjurySeverity.mild:
                                            borderColor = const Color(
                                              0xFFFFD60A,
                                            );
                                          case InjurySeverity.suspected:
                                            borderColor = const Color(
                                              0xFFFF9800,
                                            );
                                          default:
                                            borderColor = Colors.greenAccent;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            HealthTasksWidget(
                              percentage: allTask.isNotEmpty
                                  ? allTask
                                            .where((t) => t.isDone == true)
                                            .length /
                                        allTask.length
                                  : 0,
                              bigNote:
                                  "Let's maintain some healthy habits today!",
                              task: allTask,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
