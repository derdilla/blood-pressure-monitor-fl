import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Consumer<BloodPressureModel>(
          builder: (context, model, child) {
            return Wrap(
              children: [
                Statistic(
                    caption: const Text('Measurement count'),
                    child: futureInt(model.count)
                ),
                Statistic(
                    caption: const Text('Diastolic avg.'),
                    child: futureInt(model.avgDia)
                ),
                Statistic(
                    caption: const Text('Systolic avg.'),
                    child: futureInt(model.avgSys)
                ),
                Statistic(
                    caption: const Text('Pulse avg.'),
                    child: futureInt(model.avgPul)
                ),
              ],
            );
          },
        )
      ),
    );
  }
  
  Widget futureInt(Future<int> value) {
    return FutureBuilder<int>(
        future: value,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('not started');
            case ConnectionState.waiting:
              return const Text('loading...');
            default:
              if (snapshot.hasError) {
                return Text('ERROR: ${snapshot.error}');
              }
              assert(snapshot.hasData);
              if ((snapshot.data??-1) < 0) {
                return const Text('invalid data');
              }
              return Text(snapshot.data?.toString() ?? 'error');
          }
        }
    );
  }
}

class Statistic extends StatelessWidget {
  final Widget caption;
  final Widget child;

  const Statistic({super.key, required this.caption, required this.child, });

  @override
  Widget build(BuildContext context) { // TODO
    return Container(
      margin: const EdgeInsets.only(left:20, right: 20, top: 20),
      constraints: const BoxConstraints(
          minHeight: 50,
          minWidth: 150
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 4,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white38
        ),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 12,
            child: DefaultTextStyle(
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white38),
              child: caption
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: Align(
              alignment: Alignment.center,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 40
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
