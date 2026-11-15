import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/aiModel/domain/entities/stressFeatures.dart';
import 'package:exolab/features/aiModel/domain/entities/stressPrediction.dart';
import 'package:exolab/features/aiModel/domain/usecases/initializeDependency.dart';
import 'package:exolab/features/llm/presentation/controllers/llmController.dart';
import 'package:exolab/features/main/domain/entities/somethingEntry.dart';
import 'package:exolab/features/main/presentation/controllers/UIController.dart';
import 'package:exolab/features/main/presentation/pages/assessments/widgets/insightsCard.dart';
import 'package:exolab/features/main/presentation/pages/assessments/widgets/tableWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssessmentsPage extends ConsumerStatefulWidget {
  const AssessmentsPage({super.key});

  @override
  ConsumerState<AssessmentsPage> createState() => _AssessmentsPageState();
}

class _AssessmentsPageState extends ConsumerState<AssessmentsPage> {
  // ---------------------------------------------------------------------------
  // STRESS CASE: single source of truth.
  // Raw Empatica E4 units (same units the model's scaler was trained on),
  // computed over a 60 s window. The table below is built from these values.
  // ---------------------------------------------------------------------------
  static const StressFeatures _stressCase = StressFeatures(
    bvpMean: -0.02,
    bvpStd: 96.0, // high pulse-wave variability
    edaMean: 6.8, // high skin conductance (µS)
    edaStd: 0.32, // high EDA variability
    edaScrCount: 12, // 12 SCR peaks in 60 s -> 12 responses/min
    tempMean: 32.1, // peripheral cooling (°C)
    tempStd: 0.045,
    tempTrend: -0.00125, // °C per sample @ 4 Hz  ->  -0.30 °C/min
    accSma: 96.0, // normal, person is mostly still
    accVmStd: 3.1,
  );

  static const double _tempHz = 4;
  static const String _sync = '14:05 UTC';

  // Cardiovascular table (static, no model)
  final List<SomethingEntry> cardivascularHealth = [
    const SomethingEntry(
      sensing: 'Blood Oxygen (SpO₂)',
      reading: '97%',
      state: 'Normal',
      personalRange: '95 – 100%',
      source: 'S',
      updates: '-',
      lastSync: '6:07 UTC',
    ),
    const SomethingEntry(
      sensing: 'Resting Heart Rate',
      reading: '72 bpm',
      state: 'Normal',
      personalRange: '60 – 80 bpm',
      source: 'S',
      updates: '-',
      lastSync: '8:42 UTC',
    ),
    const SomethingEntry(
      sensing: 'Blood Pressure',
      reading: '128/84 mmHg',
      state: 'HIGH',
      personalRange: '90/60 – 120/80 mmHg',
      source: 'M',
      updates: 'Required',
      lastSync: '9:15 UTC',
    ),
    const SomethingEntry(
      sensing: 'Heart Rate Variability',
      reading: '34 ms',
      state: 'LOW',
      personalRange: '40 – 75 ms',
      source: 'S',
      updates: 'Unreviewed',
      lastSync: '9:28 UTC',
    ),
    const SomethingEntry(
      sensing: 'Pulse Rate',
      reading: '76 bpm',
      state: 'Normal',
      personalRange: '60 – 100 bpm',
      source: 'S',
      updates: '-',
      lastSync: '10:00 UTC',
    ),
    const SomethingEntry(
      sensing: 'Systolic Pressure',
      reading: '138 mmHg',
      state: 'HIGH',
      personalRange: '90 – 120 mmHg',
      source: 'M',
      updates: 'Scheduled',
      lastSync: '10:32 UTC',
    ),
    const SomethingEntry(
      sensing: 'Blood Oxygen (SpO₂)',
      reading: '93%',
      state: 'LOW',
      personalRange: '95 – 100%',
      source: 'S',
      updates: 'Unreviewed',
      lastSync: '11:05 UTC',
    ),
    const SomethingEntry(
      sensing: 'Diastolic Pressure',
      reading: '76 mmHg',
      state: 'Normal',
      personalRange: '60 – 80 mmHg',
      source: 'M',
      updates: 'Entered',
      lastSync: '11:20 UTC',
    ),
    const SomethingEntry(
      sensing: 'Heart Rate',
      reading: '104 bpm',
      state: 'HIGH',
      personalRange: '60 – 100 bpm',
      source: 'S',
      updates: 'Required',
      lastSync: '12:15 UTC',
    ),
    const SomethingEntry(
      sensing: 'Pulse Pressure',
      reading: '42 mmHg',
      state: 'Normal',
      personalRange: '30 – 50 mmHg',
      source: 'M',
      updates: '-',
      lastSync: '12:30 UTC',
    ),
  ];

  // Psychological table: built from _stressCase so it always matches the model input
  List<SomethingEntry> get psychologicalReadings {
    final f = _stressCase;
    final trendPerMin = f.tempTrend * _tempHz * 60;

    return [
      SomethingEntry(
        sensing: 'BVP Mean',
        reading: f.bvpMean.toStringAsFixed(2),
        state: 'Normal',
        personalRange: '-0.40 – 0.40',
        source: 'S',
        updates: '-',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'BVP Variability',
        reading: f.bvpStd.toStringAsFixed(1),
        state: 'HIGH',
        personalRange: '20 – 80',
        source: 'S',
        updates: 'Unreviewed',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'EDA Mean',
        reading: '${f.edaMean.toStringAsFixed(1)} µS',
        state: 'HIGH',
        personalRange: '0.5 – 5.0 µS',
        source: 'S',
        updates: 'Required',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'EDA Variability',
        reading: '${f.edaStd.toStringAsFixed(2)} µS',
        state: 'HIGH',
        personalRange: '0.02 – 0.20 µS',
        source: 'S',
        updates: 'Required',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'EDA Responses (SCR)',
        reading: '${f.edaScrCount.toInt()} responses/min',
        state: 'HIGH',
        personalRange: '0 – 6 responses/min',
        source: 'S',
        updates: 'Unreviewed',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'Skin Temperature Mean',
        reading: '${f.tempMean.toStringAsFixed(1)} °C',
        state: 'LOW',
        personalRange: '32.5 – 34.0 °C',
        source: 'S',
        updates: 'Unreviewed',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'Skin Temperature Variability',
        reading: '${f.tempStd.toStringAsFixed(3)} °C',
        state: 'HIGH',
        personalRange: '0.010 – 0.040 °C',
        source: 'S',
        updates: 'Scheduled',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'Skin Temperature Trend',
        reading: '${trendPerMin.toStringAsFixed(2)} °C/min',
        state: 'LOW',
        personalRange: '-0.10 – 0.10 °C/min',
        source: 'S',
        updates: 'Unreviewed',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'Activity (ACC SMA)',
        reading: f.accSma.toStringAsFixed(1),
        state: 'Normal',
        personalRange: '85 – 105',
        source: 'S',
        updates: '-',
        lastSync: _sync,
      ),
      SomethingEntry(
        sensing: 'Movement Variability',
        reading: f.accVmStd.toStringAsFixed(1),
        state: 'Normal',
        personalRange: '1.0 – 4.0',
        source: 'S',
        updates: '-',
        lastSync: _sync,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Model state
  // ---------------------------------------------------------------------------
  Future<AiModelModule>? _aiFuture; // loaded lazily on first "Analyze"

  bool _isLoading = false;
  String? _error;
  // String? _psychExplanation; // null -> "Analyze Data" button

  String _buildPrompt(StressPrediction result) {
    final pct = (result.stressProbability * 100).toStringAsFixed(0);
    final verdict = result.label == StressLabel.stress
        ? 'STRESS detected'
        : 'BASELINE (no stress detected)';

    final readings = psychologicalReadings
        .map(
          (e) =>
              '- ${e.sensing}: ${e.reading} (state: ${e.state}, personal range: ${e.personalRange})',
        )
        .join('\n');

    return '''
You are a health assistant for astronauts who are not technical or medical experts.
Explain the data below in clear, simple words, without jargon or raw numbers where possible.
- Say what the readings mean together, not one by one.
- If it looks critical and needs medical attention, clearly advise seeing a doctor.
- Keep a calm, reassuring tone and stay under 150 words.
- Do not give suggestions here!
- Do not exceed 450 character

Stress model result: $verdict ($pct% stress probability)

Readings (60-second window):
$readings
''';
  }

  Future<void> _analyzePsychological() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1) Run the TFLite model
      _aiFuture ??= AiModelModule.init();
      final ai = await _aiFuture!;
      final result = await ai.predictStress(_stressCase);

      // 2) Ask the LLM to explain it (await OUTSIDE setState)
      final explanation = await ref
          .read(llmControllerProvider.notifier)
          .analyzeData(_buildPrompt(result));

      // 3) Update the UI synchronously
      if (!mounted) return;
      setState(() {
        ref.read(uiControllerProvider.notifier).rememberedAnalysis =
            explanation;
        _isLoading = false;
      });
    } catch (e) {
      _aiFuture = null; // allow retry from scratch
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1100;

    Widget buildAssessmentSection({
      required String title,
      required IconData icon,
      required List<SomethingEntry> entries,
      String? explanation,
      bool isLoading = false,
      String? error,
      VoidCallback? onAnalyze,
    }) {
      final table = SizedBox(
        width: double.infinity,
        child: TableWidget(title: title, entries: entries),
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: table),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: InsightsCard(
                icon: icon,
                explanation: explanation,
                isLoading: isLoading,
                error: error,
                onAnalyze: onAnalyze,
                showDisclaimer: true,
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          table,
          const SizedBox(height: 12),
          InsightsCard(
            icon: icon,
            explanation: explanation,
            isLoading: isLoading,
            error: error,
            onAnalyze: onAnalyze,
            showDisclaimer: false,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 10, bottom: 0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 18, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assess your health',
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Explore your health measurements and understand what they indicate.',
                    style: context.text.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Psychological: runs the TFLite model on _stressCase
              buildAssessmentSection(
                title: 'Psychological & Mental Health',
                icon: Icons.psychology_outlined,
                entries: psychologicalReadings,
                explanation: ref.watch(uiControllerProvider).analysis,
                isLoading: _isLoading,
                error: _error,
                onAnalyze: _analyzePsychological,
              ),

              const SizedBox(height: 25),

              // Cardiovascular: static text, no model
              buildAssessmentSection(
                title: 'Cardiovascular Health',
                icon: Icons.favorite_border,
                entries: cardivascularHealth,
                explanation:
                    'This section provides an overview of cardiovascular measurements, including heart rate, blood pressure, oxygen saturation, and heart rate variability. Comparing these measurements with personal baselines can help identify changes that may require further attention.',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
