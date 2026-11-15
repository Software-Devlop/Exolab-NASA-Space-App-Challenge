import 'package:exolab/features/main/domain/entities/somethingEntry.dart';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  final String? title;
  final List<SomethingEntry> entries;

  const TableWidget({super.key, this.title, required this.entries});

  static const Color _backgroundColor = Color(0xFFFCFDFD);
  static const Color _primaryColor = Color(0xFF548779);
  static const Color _headerColor = Color(0xFFDCE7E3);
  static const Color _mutedColor = Color(0xFF929D99);
  static const Color _textColor = Color(0xFF252525);
  static const Color _borderColor = Color(0xFFE4ECE9);
  static const Color _dangerColor = Color(0xFFBE3030);

  /// Minimum table width. Below this the table scrolls horizontally.
  static const double _minTableWidth = 700;

  static const double _headerHeight = 33;
  static const double _rowHeight = 35;

  /// Column proportions (same numbers as your old fixed widths).
  /// The columns now share whatever width the card gives them.
  static const List<int> _columnFlex = [
    150, // Sensing
    90, // Reading
    65, // State
    120, // Personal Range
    65, // Source
    80, // Updates
    85, // Last Sync
  ];

  static const List<String> _headers = [
    'Sensing',
    'Reading',
    'State',
    'Personal Range',
    'Source',
    'Updates',
    'Last Sync',
  ];

  @override
  Widget build(BuildContext context) {
    // Forces the card to take the full width it is offered.
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 10, 20),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 15),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

            LayoutBuilder(
              builder: (context, constraints) {
                // Fill the card. Only scroll if the card is narrower than the minimum.
                final double tableWidth = constraints.maxWidth < _minTableWidth
                    ? _minTableWidth
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [_buildHeader(), ...entries.map(_buildEntry)],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: _headerHeight,
      color: _headerColor,
      child: Row(
        children: List.generate(_headers.length, (index) {
          return Expanded(
            flex: _columnFlex[index],
            child: Center(
              child: Text(
                _headers[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _primaryColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEntry(SomethingEntry entry) {
    final bool abnormal = entry.isHigh || entry.isLow;

    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: [
          // Sensing
          Expanded(
            flex: _columnFlex[0],
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(left: 5, right: 17),
                  decoration: BoxDecoration(
                    color: entry.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.sensing,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reading
          _buildCell(
            entry.reading,
            _textColor,
            flex: _columnFlex[1],
            fontWeight: FontWeight.w600,
          ),

          // State
          _buildCell(
            entry.state,
            abnormal ? _dangerColor : _mutedColor,
            flex: _columnFlex[2],
          ),

          // Personal Range
          _buildCell(entry.personalRange, _mutedColor, flex: _columnFlex[3]),

          // Source
          _buildCell(
            entry.source,
            _textColor,
            flex: _columnFlex[4],
            fontWeight: FontWeight.w600,
          ),

          // Updates
          _buildCell(
            entry.updates,
            abnormal ? _dangerColor : _mutedColor,
            flex: _columnFlex[5],
            fontWeight: abnormal ? FontWeight.w500 : FontWeight.normal,
          ),

          // Last Sync
          _buildCell(
            entry.lastSync,
            abnormal ? _dangerColor : _mutedColor,
            flex: _columnFlex[6],
            fontWeight: abnormal ? FontWeight.w600 : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    String value,
    Color color, {
    required int flex,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
