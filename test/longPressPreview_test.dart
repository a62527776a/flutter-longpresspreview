import 'package:flutter_test/flutter_test.dart';

import 'package:longPressPreview/longPressPreview.dart';

void main() {
  testWidgets('my LongPressPreview Widget', (WidgetTester tester) async {
    await tester.pumpWidget(LongPressPreview());
  });
}
