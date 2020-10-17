# flutter longPressPreview

用于任意组件长按并展示可拖动弹窗  
Long press and show draggable dialog of any widget.

可拖动弹窗以及多手势回调  
Draggable dialog and multi gesture callback provides.

上拉或者松开关闭弹窗
Drag up or Drag down close dialog.

## web demo preview

https://a62527776a.github.io/flutter-longpress-preview-demo/index.html

## preview

![ezgif-6-a56436a2339f.gif](https://upload-images.jianshu.io/upload_images/5738345-2ec8aba65f9ba445.gif?imageMogr2/auto-orient/strip)

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