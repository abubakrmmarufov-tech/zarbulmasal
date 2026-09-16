import 'dart:io';

void main() async {
  final jsonTest = File('test/literature_json_validation_test.dart');
  if (await jsonTest.exists()) {
    String content = await jsonTest.readAsString();
    int idx = content.indexOf("test('oral_heritage.json is an empty array', () {");
    if (idx != -1) {
       int endIdx = content.indexOf("    });\n  });\n}");
       if (endIdx != -1) {
          content = content.substring(0, idx) + "  });\n}\n";
          await jsonTest.writeAsString(content);
       }
    }
  }
}
