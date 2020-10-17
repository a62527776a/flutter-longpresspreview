# long_press_preview

[![pub package](https://img.shields.io/pub/v/long_press_preview.svg)](https://pub.dartlang.org/packages/long_press_preview)

![ezgif-6-a56436a2339f.gif](https://i.loli.net/2020/10/17/jPXslJnTD2GewIk.gif)

用于任意组件长按并展示可拖动弹窗  
Long press and show draggable dialog of any widget.

可拖动弹窗以及多手势回调  
Draggable dialog and multi gesture callback provides.

上拉或者松开关闭弹窗  
Drag up or Drag down close dialog.

## web demo preview

https://a62527776a.github.io/flutter-longpress-preview-demo/index.html

## install
add next line to pubspec.yaml
``` yaml
long_press_preview: ^0.0.1
```

``` cmd
$ flutter pub get
```

## How to use

``` Dart
import 'package:long_press_preview/long_press_preview.dart';
```
包裹你的子组件并且构建你的弹窗样式  
Wrap your child widget and build your dialog widget
``` Dart
LongPressPreview(
    child: Container(height: 30, width: 30, color: red),
    content: Container(height: 300, width: 300, child: Text('这是一个String')),
    // dialogSize: Size(300, 300), // Optional
    onFingerCallBack: onFingerCallBack,
    dialogSize: dialogSize
)
```

onFingerCallBack 将会回调手势事件以及卸载实例的函数  
onFingerCallBack Will callback gesture events and uninstall the instance
``` Dart
// This is when the fingers are released uninstall dialog and navigator to next page example
// 这是手指松开时卸载弹窗并且跳转到下一个页面的🌰
void onFingerCallBack(LongPressPreviewFingerEvent event, Function dispose) {
    switch (event) {
        // 弹窗创建时回调 （dispose函数是空的）
        // dialog create event callback (dispose function is empty)
        case LongPressPreviewFingerEvent.long_press_start:
        break;
        // 手指将弹窗滑动到上方时回调
        // Call back when you slide the dialog with your finger
        case LongPressPreviewFingerEvent.long_press_drag_top:
        break;
        // 手指松开的时候回调
        // finger leave screen callback
        case LongPressPreviewFingerEvent.long_press_end:
        dispose();
        Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen()));
        break;
        // 手指滑动到底部时的回调（dispose函数是空的）
        // finger sliding to the bottom callback(dispose is empty)
        case LongPressPreviewFingerEvent.long_press_cancel:
        break;
        default:
    }
}

```


## Quick reference
Property | What does it do(cn) | What does it do(en)
----------------   |---------------- | ---------------
child              | 长按这个组件将弹窗口 | Long press on this widget will pop up dialog
content            | 弹窗展示的内容 | display to user by content 
onFingerCallBack   | 手势的回调 | gesture callback
dialogSize         | 弹窗的大小(可选 default 300x300) | dialog size (optional default 300x300)

## onFingerCallBack params
``` dart
onFingerCallBack(LongPressPreviewFingerEvent event, Function dispose)
```
onFingerCallBack拥有两个参数 第一个参数类型是LongPressPreviewFingerEvent 这是一个枚举值 拥有long_press_start, long_press_end, long_press_cancel, long_press_drag_top四个值。  
onFingerCallBack has tow param. One is  LongPressPreviewFingerEvent. This is an enumeration with four types. long_press_start, long_press_end, long_press_cancel, long_press_drag_top

enum LongPressPreviewFingerEvent
Property | What does it do(cn) | What does it do(en)
----------------   |---------------- | ---------------
long_press_start | 创建弹窗时回调 | Callback when create dialog
long_press_end | 松开手指时回调 | Callback when release your finger
long_press_cancel | 滑到下方时回调 | Callback when slider to bottom 
long_press_drag_top | 滑到上方时回调 | Callback when slider to top

第二个参数是一个函数，当第一个参数的类型为LongPressPreviewFingerEven.long_press_drag_top or LongPressPreviewFingerEven.long_press_end，调用第二个参数将卸载弹窗的实例。否则将什么也不会发生。这用于您希望在拖动到上方或者长按结束时卸载弹窗并且做其他事情（比如说跳转到下一个页面)  
the second param is a function. when first params is LongPressPreviewFingerEven.long_press_drag_top or LongPressPreviewFingerEven.long_press_end, call the second param will uninstall dialog instance. Otherwise nothing will happen.This is used if you want to unload the pop-up window and do something else (such as jump to the next page) when you drag above or at the end of a long press

