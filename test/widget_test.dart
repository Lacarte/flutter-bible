// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:bible_app/main.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;
  setUpAll(() async {
    // Connects to the app
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      // Closes the connection
      driver.close();
    }
  });
  test.testWidgets('Counter increments smoke test',
      (test.WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new MyApp());

    Timeline timeline = await driver.traceAction(() async {
      // Find the scrollable user list

      // Scroll down 5 times

      // Tap the '+' icon and trigger a frame.
      await tester.tap(test.find.byIcon(Icons.menu));
      await tester.pump();
    });

    // The `timeline` object contains all the performance data recorded during
    // the scrolling session. It can be digested into a handful of useful
    // aggregate numbers, such as "average frame build time".
    TimelineSummary summary = new TimelineSummary.summarize(timeline);

    // The following line saves the timeline summary to a JSON file.
    summary.writeSummaryToFile('scrolling_performance', pretty: true);

    // The following line saves the raw timeline data as JSON.
    summary.writeTimelineToFile('scrolling_performance', pretty: true);
  });
}
