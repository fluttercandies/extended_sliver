import 'dart:convert';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

@FFRoute(
  name: 'fluttercandies://NestedWebviewDemo',
  routeName: 'NestedWebviewDemo',
  description: 'show how to nested webview in customscrollview',
  exts: <String, dynamic>{
    'group': 'Nested',
    'order': 0,
  },
)
class NestedWebviewDemo extends StatelessWidget {
  NestedWebviewDemo({Key? key}) : super(key: key);

  final NestedWebviewController nestedWebviewController =
      NestedWebviewController('https://flutter.cn');
  @override
  Widget build(BuildContext context) {
    // return WebView(
    //   initialUrl: nestedWebviewController.initialUrl,
    // );
    return ValueListenableBuilder<WebViewStatus>(
        valueListenable: nestedWebviewController.webViewStatusNotifier,
        builder:
            (BuildContext context, WebViewStatus webViewStatus, Widget? child) {
          return CustomScrollView(
            slivers: <Widget>[
              if (webViewStatus == WebViewStatus.completed)
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'Header',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ValueListenableBuilder<double>(
                valueListenable: nestedWebviewController.scrollHeightNotifier,
                builder: (
                  BuildContext context,
                  double scrollHeight,
                  Widget? child,
                ) {
                  // return SliverToBoxAdapter(
                  //   child: SizedBox(
                  //     height: scrollHeight,
                  //     child: child,
                  //   ),
                  // );
                  return SliverToScrollableBoxAdapter(
                    childExtent: scrollHeight,
                    onScrollOffsetChanged: ({
                      required double scrollOffset,
                      required double childLayoutExtent,
                      required double targetEndScrollOffsetForPaint,
                    }) {
                      nestedWebviewController.webviewController
                          ?.scrollTo(0, scrollOffset.toInt());
                    },
                    child: child,
                  );
                },
                child: WebView(
                  initialUrl: nestedWebviewController.initialUrl,
                  onPageStarted: nestedWebviewController.onPageStarted,
                  onPageFinished: nestedWebviewController.onPageFinished,
                  onWebResourceError:
                      nestedWebviewController.onWebResourceError,
                  onWebViewCreated: nestedWebviewController.onWebViewCreated,
                  onProgress: nestedWebviewController.onProgress,
                  javascriptChannels: <JavascriptChannel>{
                    nestedWebviewController
                        .scrollHeightNotifierJavascriptChannel
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureRecognizers: const <
                      Factory<OneSequenceGestureRecognizer>>{},
                ),
              ),
              if (webViewStatus != WebViewStatus.completed)
                SliverFillRemaining(
                  child: webViewStatus == WebViewStatus.loading
                      ? Container(
                          alignment: Alignment.center,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(
                                  width: 45.0,
                                  height: 45.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 14.0,
                                ),
                                ValueListenableBuilder<int>(
                                    valueListenable: nestedWebviewController
                                        .progressNotifier,
                                    builder: (BuildContext context,
                                        int progress, Widget? child) {
                                      return Text(
                                        '${(progress / 100 * 100).toInt()}%',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: const Text('loading failed'),
                        ),
                ),
              if (webViewStatus == WebViewStatus.completed)
                SliverToBoxAdapter(
                  child: Container(
                    height: 300,
                    color: Colors.green,
                    child: const Center(
                      child: Text(
                        'Footer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        });
  }
}

class NestedWebviewController {
  NestedWebviewController(this.initialUrl);

  final String initialUrl;

  WebViewController? _webviewController;

  WebViewController? get webviewController => _webviewController;

  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  ValueNotifier<WebViewStatus> webViewStatusNotifier =
      ValueNotifier<WebViewStatus>(WebViewStatus.loading);

  ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  void onWebViewCreated(WebViewController controller) {
    _webviewController = controller;
  }

  void onPageStarted(String url) {
    if (url == initialUrl ||
        webViewStatusNotifier.value == WebViewStatus.failed) {
      webViewStatusNotifier.value = WebViewStatus.loading;
    }
  }

  void onPageFinished(String url) {
    if (webViewStatusNotifier.value != WebViewStatus.failed) {
      //webViewStatusNotifier.value = WebViewStatus.completed;
      _webviewController?.runJavascript(scrollHeightJs);
    }
  }

  void onWebResourceError(WebResourceError error) {
    webViewStatusNotifier.value = WebViewStatus.failed;
  }

  void onProgress(int progress) {
    progressNotifier.value = progress;
  }

  JavascriptChannel get scrollHeightNotifierJavascriptChannel =>
      JavascriptChannel(
        name: 'ScrollHeightNotifier',
        onMessageReceived: (JavascriptMessage message) {
          final String msg = message.message;
          final double? height = double.tryParse(msg);
          if (height != null) {
            scrollHeightNotifier.value = height;
            if (height > 100) {
              webViewStatusNotifier.value = WebViewStatus.completed;
            }
          }
        },
      );
}

enum WebViewStatus {
  loading,
  failed,
  completed,
}

const String scrollHeightJs = '''(function() {
  var height = 0;
  var notifier = window.ScrollHeightNotifier || window.webkit.messageHandlers.ScrollHeightNotifier;
  if (!notifier) return;

  function checkAndNotify() {
    var curr = document.body.scrollHeight;
    if (curr !== height) {
      height = curr;
      notifier.postMessage(height.toString());
    }
  }

  var timer;
  var ob;
  if (window.ResizeObserver) {
    ob = new ResizeObserver(checkAndNotify);
    ob.observe(document.body);
  } else {
    timer = setTimeout(checkAndNotify, 200);
  }
  window.onbeforeunload = function() {
    ob && ob.disconnect();
    timer && clearTimeout(timer);
  };
})();''';

final String testHtml = Uri.dataFromString(
  '''<!DOCTYPE html>
<html>
<head>
  <style>
  table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
  }
  th, td, p {
    padding: 5px;
    text-align: left;
  }
  </style>
</head>
  <body>
    <h2>PDF Generated with flutter_html_to_pdf plugin</h2>
    <table style="width:100%">
      <caption>Sample HTML Table</caption>
      <tr>
        <th>Month</th>
        <th>Savings</th>
      </tr>
      <tr>
        <td>January</td>
        <td>100</td>
      </tr>
      <tr>
        <td>February</td>
        <td>50</td>
      </tr>
    </table>
    <p>Image loaded from web</p>

  </body>
</html>
''',
  mimeType: 'text/html',
  encoding: Encoding.getByName('utf-8'),
).toString();
