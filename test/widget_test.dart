import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_app/main.dart';

void main() {
  testWidgets('Task Manager app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Sign In'), findsOneWidget);
  });
}