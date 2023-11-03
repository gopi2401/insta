import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstaLogin extends StatefulWidget {
  const InstaLogin({super.key});

  @override
  InstaLoginState createState() => InstaLoginState();
}

class InstaLoginState extends State<InstaLogin> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://www.instagram.com/accounts/login/'));
  @override
  void initState() {
    super.initState();
    WebViewPlatform.instance;
    // Enable virtual display.
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      // title: TextButton(
      //     child: Text('hiii'),
      //     onPressed: () async {
      //       final cookieManager = wb.WebviewCookieManager();
      //       final gotCookies =
      //           await cookieManager.getCookies('https://www.instagram.com/');
      //     },
      //   ),
      // ),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
