import 'package:ambulance_driver/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens the home placeholder', (tester) async {
    await tester.pumpWidget(const AmbulanceDriverApp());
    await tester.pumpAndSettle();

    expect(find.text('HomeView is working'), findsOneWidget);
  });
}
