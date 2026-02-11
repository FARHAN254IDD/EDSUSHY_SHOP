import 'dart:async';
import 'dart:html' as html;
// dart:typed_data not required here; bytes produced via base64Decode
import 'dart:convert';

Future<Map<String, dynamic>?> pickImageWeb() {
  final completer = Completer<Map<String, dynamic>?>();
  try {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.multiple = false;
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }
      final file = files.first;
      final reader = html.FileReader();
      // Use Data URL for broader compatibility and easier conversion
      reader.readAsDataUrl(file);
      reader.onLoad.first.then((_) {
        try {
          final result = reader.result;
          if (result is String) {
            // result is like: data:<mime>;base64,<base64data>
            final parts = result.split(',');
            if (parts.length == 2) {
              final base64Str = parts[1];
              final bytes = base64Decode(base64Str);
              completer.complete({'bytes': bytes, 'name': file.name});
              return;
            }
          }
          completer.complete(null);
        } catch (e) {
          completer.completeError(e);
        }
      });
      reader.onError.first.then((event) {
        completer.completeError(event);
      });
    });
  } catch (e) {
    completer.completeError(e);
  }
  return completer.future;
}
