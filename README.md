# extended_sliver

[![pub package](https://img.shields.io/pub/v/extended_sliver.svg)](https://pub.dartlang.org/packages/extended_sliver) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/network) [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/blob/master/LICENSE) [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_sliver)](https://github.com/fluttercandies/extended_sliver/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: English | [中文简体](README-ZH.md)

## Description

A powerful extension library of Sliver, which include SliverToNestedScrollBoxAdapter, SliverPinnedPersistentHeader, SliverPinnedToBoxAdapter and ExtendedSliverAppbar.

- [extended_sliver](#extended_sliver)
  - [Description](#description)
  - [Usage](#usage)
    - [Add packages to dependencies](#add-packages-to-dependencies)
  - [SliverPinnedPersistentHeader](#sliverpinnedpersistentheader)
  - [SliverPinnedToBoxAdapter](#sliverpinnedtoboxadapter)
  - [ExtendedSliverAppbar](#extendedsliverappbar)
  - [SliverToNestedScrollBoxAdapter](#slivertonestedscrollboxadapter)
  - [Complex Demo](#complex-demo)


## Usage

### Add packages to dependencies

Add the package to  `pubspec.yaml` under `dependencies`.

```yaml
dependencies:
  extended_sliver: latest-version
```

Download with `flutter packages get`

## SliverPinnedPersistentHeader

It's the same as `SliverPersistentHeader(pinned: true)`, but you don't have to force values of minExtent and maxExtent.

It provides `minExtentProtoType` and `maxExtentProtoType` to calculate minExtent and maxExtent automatically.

It's useful that you don't know the final extent before the widgets are laid out.

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

You can create a pinned Sliver easily with it.

It's useful that you don't know the final extent before the child are laid out.

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

You can create SliverAppbar with out force the expandedHeight.

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

You can create nested scrollable widget(like Webview) in CustomScrollView/NestedScrollView.

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

## Complex Demo

[Complex Demo](https://github.com/fluttercandies/extended_sliver/blob/master/example/lib/pages/complex/home_page.dart)

![image](https://github.com/fluttercandies/flutter_candies/blob/master/gif/extended_sliver/extended_sliver.gif)



