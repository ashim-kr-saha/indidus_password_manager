import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import 'home/home_screen.dart';

class DummyDataProgressPage extends ConsumerStatefulWidget {
  static const path = '/dummy-data-progress';

  const DummyDataProgressPage({super.key});

  @override
  ConsumerState<DummyDataProgressPage> createState() =>
      _DummyDataProgressPageState();
}

class _DummyDataProgressPageState extends ConsumerState<DummyDataProgressPage> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startDummyDataCreation();
  }

  Future<void> _startDummyDataCreation() async {
    try {
      await for (final progress in Database.instance.createDummyData()) {
        setState(() {
          _progress = progress;
        });
      }
      if (mounted) {
        context.go(HomeScreen.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error creating dummy data: ${e.toString()}'),
        ));
        context.go(HomeScreen.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Creating Dummy Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Text('${(_progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
