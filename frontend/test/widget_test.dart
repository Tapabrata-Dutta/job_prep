import 'package:flutter_test/flutter_test.dart';

import 'package:place_prep/main.dart';

void main() {
  testWidgets('shows the DSA dashboard title', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Placement Prep'), findsOneWidget);
    expect(find.text('DSA progress'), findsOneWidget);
  });
}
