import 'package:blood_pressure_app/components/nullable_text.dart';
import 'package:blood_pressure_app/components/pressure_text.dart';
import 'package:blood_pressure_app/data_util/entry_context.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A more compact [BloodPressureRecord] list that is less verbose.
class CompactMeasurementList extends StatefulWidget {
  /// Create a more compact, less verbose measurement list.
  const CompactMeasurementList({super.key,
    required this.data,
  });

  /// Entries sorted with newest ordered first.
  final List<FullEntry> data;

  @override
  State<CompactMeasurementList> createState() => _CompactMeasurementListState();
}

class _CompactMeasurementListState extends State<CompactMeasurementList> {
  List<int> _tableElementsSizes = [33, 9, 9, 9, 30];
  int _sideFlex = 1;
  late DateFormat formatter;

  @override
  void initState() {
    super.initState();
    formatter = DateFormat('yyyy-MM-dd HH:mm');
  }

  Widget _buildHeader() => Row(
    children: [
      Expanded(
        flex: _sideFlex,
        child: const SizedBox(),
      ),
      Expanded(
        flex: _tableElementsSizes[0],
        child: Text(AppLocalizations.of(context)!.time, style: const TextStyle(fontWeight: FontWeight.bold)),),
      Expanded(
        flex: _tableElementsSizes[1],
        child: Text(AppLocalizations.of(context)!.sysShort,
          style: TextStyle(fontWeight: FontWeight.bold, color: context.select<Settings, Color>((s) => s.sysColor))),),
      Expanded(
        flex: _tableElementsSizes[2],
        child: Text(AppLocalizations.of(context)!.diaShort,
          style: TextStyle(fontWeight: FontWeight.bold, color: context.select<Settings, Color>((s) => s.diaColor))),),
      Expanded(
        flex: _tableElementsSizes[3],
        child: Text(AppLocalizations.of(context)!.pulShort,
          style: TextStyle(fontWeight: FontWeight.bold, color: context.select<Settings, Color>((s) => s.pulColor))),),
      Expanded(
        flex: _tableElementsSizes[4],
        child: Text(AppLocalizations.of(context)!.notes, style: const TextStyle(fontWeight: FontWeight.bold)),),
      Expanded(
        flex: _sideFlex,
        child: const SizedBox(),
      ),
    ],
  );

  Widget _itemBuilder(BuildContext context, int index) => Column(
    children: [
      Dismissible(
        key: Key(widget.data[index].time.toIso8601String()),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) { // edit
            await context.createEntry(widget.data[index].asAddEntry);
            return false;
          } else { // delete
            await context.deleteEntry(widget.data[index]);
            return false;
          }
        },
        onDismissed: (direction) {},
        background: Container(
          width: 10,
          decoration:
          BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(5)),
          child: const Align(alignment: Alignment(-0.95, 0), child: Icon(Icons.edit)),
        ),
        secondaryBackground: Container(
          width: 10,
          decoration:
          BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
          child: const Align(alignment: Alignment(0.95, 0), child: Icon(Icons.delete)),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(children: [
            Expanded(
              flex: _sideFlex,
              child: const SizedBox(),
            ),
            Expanded(
              flex: _tableElementsSizes[0],
              child: Text(formatter.format(widget.data[index].time)),),
            Expanded(
                flex: _tableElementsSizes[1],
                child: PressureText(widget.data[index].sys)),
            Expanded(
              flex: _tableElementsSizes[2],
              child: PressureText(widget.data[index].dia),),
            Expanded(
              flex: _tableElementsSizes[3],
              child: NullableText(widget.data[index].pul?.toString()),),
            Expanded(
              flex: _tableElementsSizes[4],
              child: NullableText(() {
                String note = widget.data[index].note ?? '';
                for (final i in widget.data[index].intakes) {
                  note += '${i.medicine.designation}(${i.dosis.mg}mg)';
                }
                return note.isEmpty ? null : note;
              }()),
            ),
            Expanded(
              flex: _sideFlex,
              child: const SizedBox(),
            ),
          ],),
        ),
      ),
      const Divider(
        thickness: 1,
        height: 1,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    formatter = DateFormat(context.select<Settings, String>((s) => s.dateFormatString));
    if (MediaQuery.of(context).size.width < 1000) {
      _tableElementsSizes = [33, 9, 9, 9, 30];
      _sideFlex = 1;
    } else {
      _tableElementsSizes = [20, 5, 5, 5, 60];
      _sideFlex = 5;
    }
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(
          height: 10,
        ),
        Divider(
          height: 0,
          thickness: 2,
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        Expanded(
          child: Builder(
            builder: (BuildContext context) {
              if (widget.data.isEmpty) return Text(AppLocalizations.of(context)!.errNoData);
              return ListView.builder(
                itemCount: widget.data.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(2),
                itemBuilder: _itemBuilder,
              );
            },
          ),
        ),
      ],
    );
  }
}
