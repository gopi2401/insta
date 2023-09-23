import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart' as wb;

class InstaLogin extends StatefulWidget {
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
      appBar: AppBar(
        title: TextButton(
          child: Text('hiii'),
          onPressed: () async {
            final cookieManager = wb.WebviewCookieManager();
            final gotCookies =
                await cookieManager.getCookies('https://www.instagram.com/');
            print('hiii...$gotCookies');
          },
        ),
      ),
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cookies =
              await controller.runJavaScriptReturningResult('document.cookie');
          print('cookies$cookies');
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
    // child: WebView(
    //   javascriptMode: JavascriptMode.unrestricted,
    //   initialUrl: 'https://www.instagram.com/accounts/login/',
    //   navigationDelegate: (navigation) {
    //     if (!navigation.url.contains("https://www.instagram.com/accounts/login/")) {
    //       Navigator.pop(context);
    //       return NavigationDecision.prevent;
    //     } else {
    //       return NavigationDecision.navigate;
    //     }
    //   },
    // ),
    // );
  }
}
