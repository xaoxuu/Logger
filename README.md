# Logger


Logger 是为 Swift 5 设计的测试与调试工具：写日志到缓存中，并发送给开发者。

要依赖于 Logger API 包，您需要在 Package.swift 中声明依赖项：

```swift
.package(url: "https://github.com/xaoxuu/Logger.git", from: "1.0.0"),
```


**开始使用：**

```swift
// 1) let's import the Logger API package
import Logger

// 2) we're now ready to use it
Logger("测试")
```


**输出：**

```
[2020-06-06 19:27:12 +0800]() ViewController <line:23> touchesBegan(_:with:)
测试
```


**需要反馈给开发者时，可以：**

```swift
let vc = Logger.share()
self.present(vc, animated: true) {
    
}
```
