import 'dart:io';
import 'dart:ui';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
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
      NestedWebviewController('https://flutter.dev'
          //'https://flutter.cn'
          );
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    // return WebView(
    //   initialUrl: nestedWebviewController.initialUrl,
    // );
    return Scaffold(
      appBar: AppBar(
        title: const Text('NestedWebview'),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                scrollController.animateTo(
                  nestedWebviewController.scrollHeightNotifier.value,
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                );
              },
              child: const Text(
                'animate to Webview bottom',
                style: TextStyle(
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: ValueListenableBuilder<WebViewStatus>(
        valueListenable: nestedWebviewController.webViewStatusNotifier,
        builder:
            (BuildContext context, WebViewStatus webViewStatus, Widget? child) {
          return Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
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
                    valueListenable:
                        nestedWebviewController.scrollHeightNotifier,
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
                      return SliverToNestedScrollBoxAdapter(
                        childExtent: scrollHeight,
                        onScrollOffsetChanged: (double scrollOffset) {
                          double y = scrollOffset;
                          if (Platform.isAndroid) {
                            // https://github.com/flutter/flutter/issues/75841
                            y *= window.devicePixelRatio;
                          }
                          nestedWebviewController.webviewController
                              ?.scrollTo(0, y.ceil());
                        },
                        child: child,
                      );
                    },
                    child: WebViewWidget(controller:nestedWebviewController._webviewController),
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
              ),
              Container(
                height: webViewStatus != WebViewStatus.completed
                    ? double.infinity
                    : 0,
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
                                  valueListenable:
                                      nestedWebviewController.progressNotifier,
                                  builder: (BuildContext context, int progress,
                                      Widget? child) {
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
            ],
          );
        },
      ),
    );
  }
}

class NestedWebviewController {
  NestedWebviewController(this.initialUrl){
    _webviewController = 
    WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            progressNotifier.value = progress;
          },
          onPageFinished: (String url) {
            if (webViewStatusNotifier.value != WebViewStatus.failed) {
              _webviewController?.runJavaScript(scrollHeightJs);
            }
            webViewStatusNotifier.value = WebViewStatus.completed;
          },
          onWebResourceError: (WebResourceError error) {
            //webViewStatusNotifier.value = WebViewStatus.failed;
          },
          onPageStarted: (String url) {
            if (url == initialUrl ||
                webViewStatusNotifier.value == WebViewStatus.failed) {
              webViewStatusNotifier.value = WebViewStatus.loading;
            }
          }
        )
      )
      ..addJavaScriptChannel('ScrollHeightNotifier', onMessageReceived: (JavaScriptMessage message) {
          final String msg = message.message;
          final double? height = double.tryParse(msg);
          if (height != null) {
            scrollHeightNotifier.value = height;

            webViewStatusNotifier.value = WebViewStatus.completed;
          }
        })
      ..loadRequest(Uri.parse(initialUrl));
  }

  final String initialUrl;

  late WebViewController _webviewController;

  WebViewController get webviewController => _webviewController;

  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  ValueNotifier<WebViewStatus> webViewStatusNotifier =
      ValueNotifier<WebViewStatus>(WebViewStatus.loading);

  ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);
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
