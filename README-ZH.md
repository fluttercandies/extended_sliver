# extended_sliver

[![pub package](https://img.shields.io/pub/v/extended_sliver.svg)](https://pub.dartlang.org/packages/extended_sliver) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

语言: [English](README.md) | 中文简体

## 描述

强大的Sliver扩展库, 包括 SliverToNestedScrollBoxAdapter, SliverPinnedPersistentHeader, SliverPinnedToBoxAdapter 和 ExtendedSliverAppbar.

- [extended_sliver](#extended_sliver)
  - [描述](#描述)
  - [使用](#使用)
    - [添加引用](#添加引用)
  - [SliverPinnedPersistentHeader](#sliverpinnedpersistentheader)
  - [SliverPinnedToBoxAdapter](#sliverpinnedtoboxadapter)
  - [ExtendedSliverAppbar](#extendedsliverappbar)
  - [SliverToNestedScrollBoxAdapter](#slivertonestedscrollboxadapter)
  - [复杂的例子](#复杂的例子)


## 使用

### 添加引用

添加引用到 `pubspec.yaml` 下面的 `dependencies`

```yaml
dependencies:
  extended_sliver: latest-version
```

执行 `flutter packages get` 下载

## SliverPinnedPersistentHeader

跟官方的`SliverPersistentHeader(pinned: true)`一样, 不同的是你不需要去设置 minExtent 和 maxExtent。

它是通过设置 `minExtentProtoType` 和 `maxExtentProtoType` 来计算 minExtent 和 maxExtent。

当Widget没有layout之前，你没法知道Widget的实际大小，这将是非常有用的组件。

```dart
    SliverPinnedPersistentHeader(
      delegate: MySliverPinnedPersistentHeaderDelegate(
        minExtentProtoType: Container(
          height: 120.0,
          color: Colors.red.withOpacity(0.5),
          child: FlatButton(
            child: const Text('minProtoType'),
            onPressed: () {
              print('minProtoType');
            },
          ),
          alignment: Alignment.topCenter,
        ),
        maxExtentProtoType: Container(
          height: 200.0,
          color: Colors.blue,
          child: FlatButton(
            child: const Text('maxProtoType'),
            onPressed: () {
              print('maxProtoType');
            },
          ),
          alignment: Alignment.bottomCenter,
        ),
      ),
    )
```
## SliverPinnedToBoxAdapter

你可以轻松创建一个锁定的Sliver。

当child没有layout之前，你没法知道child的实际大小，这将是非常有用的组件。

```dart
    SliverPinnedToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.blue.withOpacity(0.5),
        child: Column(
          children: <Widget>[
            const Text(
                '[love]Extended text help you to build rich text quickly. any special text you will have with extended text. '
                '\n\nIt\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love]'
                '\n\nif you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]'),
            FlatButton(
              child: const Text('I\'m button. click me!'),
              onPressed: () {
                debugPrint('click');
              },
            ),
          ],
        ),
      ),
    )
```
## ExtendedSliverAppbar

你可以创建一个SliverAppbar，不用去设置expandedHeight。

```dart
return CustomScrollView(
  slivers: <Widget>[
    ExtendedSliverAppbar(
      title: const Text(
        'ExtendedSliverAppbar',
        style: TextStyle(color: Colors.white),
      ),
      leading: const BackButton(
        onPressed: null,
        color: Colors.white,
      ),
      background: Image.asset(
        'assets/cypridina.jpeg',
        fit: BoxFit.cover,
      ),
      actions: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          Icons.more_horiz,
          color: Colors.white,
        ),
      ),
    ),
  ],
);
```

## SliverToNestedScrollBoxAdapter

你可以在 CustomScrollView/NestedScrollView 中创建一个嵌套滚动的组件(比如 Webview).

```dart
return CustomScrollView(
  slivers: <Widget>[
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
        return SliverToNestedScrollBoxAdapter(
          childExtent: scrollHeight,
          onScrollOffsetChanged: (double scrollOffset) {
            double y = scrollOffset;
            if (Platform.isAndroid) {
              // https://github.com/flutter/flutter/issues/75841
              y *= window.devicePixelRatio;
      
            nestedWebviewController.webviewController
                ?.scrollTo(0, y.ceil());
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
      ),
    ),
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
```

## 复杂的例子

[例子地址](https://github.com/fluttercandies/extended_sliver/blob/master/example/lib/pages/complex/home_page.dart)

![image](http://zmtzawqlp.gitee.io/my_images/images/extended_sliver/extended_sliver.gif)



