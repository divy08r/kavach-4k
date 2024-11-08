// ignore: unused_import
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class SafeWebView extends StatelessWidget {
  final String? url;
  SafeWebView({this.url});

  WebViewController webViewController = WebViewController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebViewWidget(
          controller: webViewController..loadRequest(Uri.parse(url!))),
    );
  }
}
