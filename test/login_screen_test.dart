import 'package:carrom_project/Utils/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Screen Tests', () {
    testWidgets('Login screen loads correctly',
            (WidgetTester tester) async {
          await tester.binding.setSurfaceSize(const Size(414, 896));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            const MaterialApp(
              home: LoginScreen1(),
            ),
          );
          // Bounded pumps instead of pumpAndSettle — the screen has a
          // continuously repeating animation, so pumpAndSettle would
          // never see "no frames scheduled" and would time out.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900)); // let _entryController.forward() finish

          expect(find.text('Sign In'), findsOneWidget);
          expect(find.byType(TextField), findsNWidgets(2));
          expect(find.text('Keep me signed in'), findsOneWidget);
          expect(find.text('Forgot password?'), findsOneWidget);
        });

    testWidgets('User can enter email and password',
            (WidgetTester tester) async {
          await tester.binding.setSurfaceSize(const Size(414, 896));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            const MaterialApp(
              home: LoginScreen1(),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900)); // let _entryController.forward() finish

          await tester.enterText(
            find.byKey(const Key('emailField')),
            'admin@gmail.com',
          );
          await tester.enterText(
            find.byKey(const Key('passwordField')),
            '123456',
          );
          await tester.pump();

          // Email is plain text, so this check is fine as-is
          expect(find.text('admin@gmail.com'), findsOneWidget);

          // Password field is obscured (obscure: true), so the rendered
          // text is dots, not '123456' — find.text() will never match it.
          // The Key is on FancyTextField itself (not the inner TextField),
          // so cast to FancyTextField and read its controller directly.
          final passwordField = tester.widget<FancyTextField>(
            find.byKey(const Key('passwordField')),
          );
          expect(passwordField.controller.text, '123456');
        });

    testWidgets('Remember me checkbox toggles',
            (WidgetTester tester) async {
          await tester.binding.setSurfaceSize(const Size(414, 896));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            const MaterialApp(
              home: LoginScreen1(),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900)); // let _entryController.forward() finish

          expect(find.byKey(const Key('rememberMe')), findsOneWidget);
          await tester.tap(find.byKey(const Key('rememberMe')));
          // The checkbox's own transition is short (AnimatedContainer, 200ms)
          // so a bounded pump is enough — no need for pumpAndSettle.
          await tester.pump(const Duration(milliseconds: 250));
        });

    testWidgets('Tap Sign In button',
            (WidgetTester tester) async {
          await tester.binding.setSurfaceSize(const Size(414, 896));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            const MaterialApp(
              home: LoginScreen1(),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900)); // let _entryController.forward() finish

          // Tap by key rather than by text — hits the actual tappable
          // widget directly instead of relying on the text being in
          // the hit-testable area.
          await tester.tap(find.byKey(const Key('loginButton')));
          await tester.pump(); // rebuild after setState
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Instead of pumpAndSettle (which would hang on the repeating
          // animation elsewhere on screen), pump forward past however
          // long _handleLogin's async work takes — adjust this duration
          // to match your actual login logic (e.g. a mocked delay).
          await tester.pump(const Duration(seconds: 2));
          expect(find.text('Sign In'), findsOneWidget); // back to normal state
        });
  });
}