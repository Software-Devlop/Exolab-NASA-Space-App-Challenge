import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MonitoringWidget extends ConsumerStatefulWidget {
  const MonitoringWidget({super.key});

  @override
  ConsumerState<MonitoringWidget> createState() => _MonitoringWidgetState();
}

class _MonitoringWidgetState extends ConsumerState<MonitoringWidget> {
  final healthData = [
    {
      'sensor': 'Blood Oxygen',
      'value': '95',
      'unit': '%',
      'status': 'Normal',
      'range': '95-100%',
      'sync': '08:42 UTC',
    },
    {
      'sensor': 'Heart Rate',
      'value': '72',
      'unit': 'bpm',
      'status': 'Normal',
      'range': '60-100 bpm',
      'sync': '08:41 UTC',
    },
    {
      'sensor': 'Body Temperature',
      'value': '38.2',
      'unit': '°C',
      'status': 'HIGH',
      'range': '36.1-37.5 °C',
      'sync': '08:40 UTC',
    },
    {
      'sensor': 'Respiratory Rate',
      'value': '18',
      'unit': 'breaths/min',
      'status': 'Normal',
      'range': '12-20 breaths/min',
      'sync': '08:39 UTC',
    },
    {
      'sensor': 'Heart Rate',
      'value': '112',
      'unit': 'bpm',
      'status': 'HIGH',
      'range': '60-100 bpm',
      'sync': '08:38 UTC',
    },
    {
      'sensor': 'Blood Oxygen',
      'value': '91',
      'unit': '%',
      'status': 'LOW',
      'range': '95-100%',
      'sync': '08:37 UTC',
    },
    {
      'sensor': 'HRV',
      'value': '48',
      'unit': 'ms',
      'status': 'Normal',
      'range': '30-70 ms',
      'sync': '08:36 UTC',
    },
    {
      'sensor': 'Heart Rate',
      'value': '112',
      'unit': 'bpm',
      'status': 'HIGH',
      'range': '60-100 bpm',
      'sync': '08:38 UTC',
    },
    {
      'sensor': 'Blood Oxygen',
      'value': '91',
      'unit': '%',
      'status': 'LOW',
      'range': '95-100%',
      'sync': '08:37 UTC',
    },
    {
      'sensor': 'HRV',
      'value': '48',
      'unit': 'ms',
      'status': 'Normal',
      'range': '30-70 ms',
      'sync': '08:36 UTC',
    },
  ];

  Widget _tableCell(
    String text, {
    Color color = const Color(0xFF47645F),
    bool bold = false,
  }) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        color: color,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustContainer(
      padding: const EdgeInsets.fromLTRB(25, 18, 7, 20),
      child: Column(
        spacing: 10,
        children: [
          // Title
          Row(
            spacing: 15,
            children: [
              SvgPicture.asset("assets/icons/leaf.svg"),
              Text("Monitoring", style: context.text.titleMedium),
            ],
          ),

          SizedBox(
            height: 350,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.surface,
                    context.colors.surface,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.88, 1.0],
                ).createShader(bounds);
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(right: 17),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Table(
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: const {
                              0: FlexColumnWidth(1.5),
                              1: FlexColumnWidth(1.0),
                              2: FlexColumnWidth(0.8),
                              3: FlexColumnWidth(1.3),
                              4: FlexColumnWidth(1.0),
                            },
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: context.colors.secondary.withAlpha(190),
                                width: 0.8,
                              ),
                            ),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: context.colors.secondary.withAlpha(
                                    127,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                  ),
                                ),
                                children:
                                    [
                                      'Sensing',
                                      'Reading',
                                      'State',
                                      'Range',
                                      'Last Sync',
                                    ].map((title) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          title,
                                          style: context.text.labelMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              ...healthData.map((data) {
                                final status = data['status']!;
                                final isAlert =
                                    status == 'HIGH' || status == 'LOW';

                                return TableRow(
                                  children:
                                      [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isAlert
                                                    ? context.colors.error
                                                    : context.colors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _tableCell(
                                                data['sensor']!,
                                              ),
                                            ),
                                          ],
                                        ),
                                        _tableCell(
                                          '${data['value']} ${data['unit'] ?? ''}',
                                          bold: true,
                                        ),
                                        _tableCell(
                                          status,
                                          color: isAlert
                                              ? context.colors.error
                                              : context.colors.primary,
                                        ),
                                        _tableCell(data['range'] ?? '--'),
                                        _tableCell(data['sync'] ?? '--'),
                                      ].map((cell) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 13,
                                            horizontal: 8,
                                          ),
                                          child: cell,
                                        );
                                      }).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
