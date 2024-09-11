import 'package:encrypt/encrypt.dart' as encrypt;

String title(String title) {
  return title
      .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
      .replaceAll("\n", "_")
      .replaceAll("|", "_");
}

// Cleans and formats the filename
String filename(String input) {
  var text = input
      .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
      .replaceAll("\n", "_")
      .replaceAll("|", "_");
  return text.length >= 60 ? text.substring(0, 60) : text;
}

String encryption(String input) {
  final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
  final iv = encrypt.IV.fromLength(16);
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));
  return encrypter.encrypt(input, iv: iv).base16;
}

String decrypt(String encryptedHex) {
  final key = encrypt.Key.fromUtf8('qwertyuioplkjhgf');
  final iv = encrypt.IV.fromLength(16); // IV length is 16 for AES
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));

  // Convert the hex string back to encrypted bytes
  final encryptedBytes = encrypt.Encrypted.fromBase16(encryptedHex);

  // Decrypt the encrypted bytes
  final decrypted = encrypter.decrypt(encryptedBytes, iv: iv);

  return decrypted;
}
