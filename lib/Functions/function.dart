import 'package:encrypt/encrypt.dart' as encrypt;

class Functions {
  static String titleFun(String title) {
    return title
        .replaceAll(RegExp(r"[&/\\#,+()$~%.\':*?<>{}]+"), '')
        .replaceAll("\n", "_")
        .replaceAll("|", "_");
  }

  static String decryptFun(String encryptedHex) {
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
}
