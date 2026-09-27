import 'package:ambulance_driver/app/dependency_injection.dart';
import 'package:ambulance_driver/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    DependencyInjection.init();
  });

  testWidgets('app opens the login screen', (tester) async {
    await tester.pumpWidget(const AmbulanceDriverApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Ambulance Driver'), findsOneWidget);
  });
}

