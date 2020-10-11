import 'package:flutter_test/flutter_test.dart';

import 'package:longPressPreview/src/long_press_preview.dart';

void main() {
  testWidgets('my LongPressPreview Widget', (WidgetTester tester) async {
    await tester.pumpWidget(LongPressPreview());
  });
}
