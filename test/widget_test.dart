import 'package:carrom_project/Utils/splash_screen.dart';
import 'package:carrom_project/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches and shows SplashScreen',
          (WidgetTester tester) async {
        await tester.pumpWidget(const CarromApp());
        expect(find.byType(SplashScreen1), findsOneWidget);
      });
}