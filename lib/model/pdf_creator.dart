import 'dart:typed_data';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfCreator {
  Future<Uint8List> createPdf(List<BloodPressureRecord> data) async {
    Document pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat.a4,
        build: (Context context) {
          return Center(
            child: Table(
              children: [
                TableRow(
                    children: [
                      Text('timestamp'),
                      Text('systolic'),
                      Text('diastolic'),
                      Text('pulse'),
                      Text('note')
                    ]
                ),
                for (var entry in data)
                  TableRow(
                    children: [
                      Text(entry.creationTime.toIso8601String()),
                      Text(entry.systolic.toString()),
                      Text(entry.diastolic.toString()),
                      Text(entry.pulse.toString()),
                      Text(entry.notes)
                    ]
                  )
              ]
            ),
          );
        }));
    return await pdf.save();
  }
}