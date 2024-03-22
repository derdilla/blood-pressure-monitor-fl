import 'package:flutter/material.dart';

/// A info screen to show possible time format codes.
class TimeFormattingReferenceScreen extends StatelessWidget {
  /// Create a info screen to show possible time format codes.
  const TimeFormattingReferenceScreen({super.key});
  // https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  static const _formats = '''
DAY                          d
 ABBR_WEEKDAY                 E
 WEEKDAY                      EEEE
 ABBR_STANDALONE_MONTH        LLL
 STANDALONE_MONTH             LLLL
 NUM_MONTH                    M
 NUM_MONTH_DAY                Md
 NUM_MONTH_WEEKDAY_DAY        MEd
 ABBR_MONTH                   MMM
 ABBR_MONTH_DAY               MMMd
 ABBR_MONTH_WEEKDAY_DAY       MMMEd
 MONTH                        MMMM
 MONTH_DAY                    MMMMd
 MONTH_WEEKDAY_DAY            MMMMEEEEd
 ABBR_QUARTER                 QQQ
 QUARTER                      QQQQ
 YEAR                         y
 YEAR_NUM_MONTH               yM
 YEAR_NUM_MONTH_DAY           yMd
 YEAR_NUM_MONTH_WEEKDAY_DAY   yMEd
 YEAR_ABBR_MONTH              yMMM
 YEAR_ABBR_MONTH_DAY          yMMMd
 YEAR_ABBR_MONTH_WEEKDAY_DAY  yMMMEd
 YEAR_MONTH                   yMMMM
 YEAR_MONTH_DAY               yMMMMd
 YEAR_MONTH_WEEKDAY_DAY       yMMMMEEEEd
 YEAR_ABBR_QUARTER            yQQQ
 YEAR_QUARTER                 yQQQQ
 HOUR24                       H
 HOUR24_MINUTE                Hm
 HOUR24_MINUTE_SECOND         Hms
 HOUR                         j
 HOUR_MINUTE                  jm
 HOUR_MINUTE_SECOND           jms
 MINUTE                       m
 MINUTE_SECOND                ms
 SECOND                       s''';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).primaryColor,
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.71),
            1: FlexColumnWidth(0.29),
          },
          children: _buildRows(context),
        ),
      ),
    ),);

  List<TableRow> _buildRows(BuildContext context) {
    final List<TableRow> rowsOut = [
      TableRow(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),),
        ),
        children: const [Text('ICU Name'), Text('Skeleton')],
      ),
    ];
    final lines = _formats.trim().split('\n');
    for (int i = 1; i < lines.length; i++) {
      final List<String> values = lines[i].trim().split(RegExp(r'\s{2,}'));
      rowsOut.add(TableRow(children: [Text(values[0]), Text(values[1])]));
    }
    return rowsOut;
  }
}
