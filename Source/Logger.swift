//
//  Logger.swift
//  Logger
//
//  Created by xaoxuu on 2020/6/6.
//  Copyright © 2020 xaoxuu.com. All rights reserved.
//

import UIKit

/// 日期格式化
private let dateFormatter = DateFormatter()

/// 文件管理器
private let fm = FileManager.default

private struct InfoDict {
    static var appName: String {
        return (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "unknown"
    }
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "unknown"
    }
    static var appVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
    }
    static var appBuild: String {
        return (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "unknown"
    }
    static var device: String {
        return UIDevice.current.localizedModel
    }
    static var deviceName: String {
        return UIDevice.current.name
    }
    static var systemVersion: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
}

/// 是否启用（可根据debug/release决定）
private var enableLogger = true

/// 打印等级（不低于此等级的会打印到控制台）
private var printLevel = Logger.Level.low

/// 缓存等级（不低于此等级的会缓存到沙盒）
private var cacheLevel = Logger.Level.low


// MARK: 日志
public struct Logger {
    
    /// 日志存放的文件夹
    public static var folder = "Logs"
    
    /// 日志文件扩展名
    public static var ext = "md"
    
    /// 日志输出线程
    internal static let queue = DispatchQueue(label: "com.xaoxuu.logger")
    
    /// 日志等级
    public enum Level: Int, Codable, CaseIterable {
        case low = 0
        case trace
        case debug
        case info
        case notice
        case warning
        case error
        case critical
        
        public var emoji: String? {
            switch self {
            case .critical:
                return "‼️"
            case .error:
                return "❗️"
            case .warning:
                return "⚠️"
            default:
                return nil
            }
        }
    }
    
    /// 设置是否使用
    /// - Parameter flag: 是否使用
    public static func setEnable(_ flag: Bool) {
        enableLogger = flag
    }
    
    /// 设置打印等级（不低于此等级的会打印到控制台）
    /// - Parameter level: 打印等级
    public static func setPrint(level: Level) {
        printLevel = level
    }
    
    /// 设置缓存等级（不低于此等级的会缓存到沙盒）
    /// - Parameter level: 缓存等级
    public static func setCache(level: Level) {
        cacheLevel = level
    }
    
    private static let shared = Logger()
    /// 初始化
    private init() {
        // 创建文件夹
        try? fm.createDirectory(at: Logger.baseURL(), withIntermediateDirectories: true, attributes: nil)
        // 路径
        let path = Logger.fileURL().path
        if let _ = FileHandle.init(forWritingAtPath: path) {
            // 已经有文件了，往后加空行
            Logger.write("\n\n")
        } else {
            // 没有文件就创建文件
            fm.createFile(atPath: path, contents: nil, attributes: nil)
        }
        // 记录一次启动事件
        let msg = "## Launch at: " + Logger.time()
        Logger.write(msg)
        var str = "\n```yaml\n"
        str += "appName: \(InfoDict.appName)\n"
        str += "bundleIdentifier: \(InfoDict.bundleIdentifier)\n"
        str += "appVersion: \(InfoDict.appVersion)\n"
        str += "appBuild: \(InfoDict.appBuild)\n"
        str += "device: \(InfoDict.device)\n"
        str += "systemVersion: \(InfoDict.systemVersion)\n"
        str += "```\n"
        Logger.write(str)
        // 输出文件路径
        print("[\(Logger.time())] Logger初始化成功！")
        print("日志文件路径: \(Logger.fileURL().path)")
    }
    
    /// 输出日志
    /// - Parameters:
    ///   - level: 等级
    ///   - items: 要输出的内容
    ///   - file: 当前文件
    ///   - line: 当前行
    ///   - function: 当前函数
    @discardableResult public init(level: Level = .low, _ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: level, items: items, file: file, line: line, function: function)
    }
    
    /// 通过 UIActivityViewController 分享日志
    /// - Parameter logs: 日志数
    /// - Returns: UIActivityViewController
    public static func share(logs count: Int = 7) -> UIActivityViewController {
        let ac = UIActivityViewController.init(activityItems: Logger.read(logs: count) ?? [URL](), applicationActivities: nil)
        ac.excludedActivityTypes = [.airDrop, .mail]
        return ac
    }
    
    
}

// MARK: 记录日志
extension Logger {
    
    /// 时间
    /// - Returns: 时间
    static func time() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return dateFormatter.string(from: Date())
    }
    
    /// 今日
    /// - Returns: 今日
    static func today() -> String {
        let t = time()
        let ts = t.split(separator: " ")
        return ts.first?.description ?? "2020-01-01"
    }
    
    /// 元数据
    /// - Parameters:
    ///   - file: 文件
    ///   - line: 代码行
    ///   - function: 函数
    /// - Returns: 元数据
    static func meta(file: String = #file, line: Int = #line, function: String = #function) -> String {
        return ((file as NSString).lastPathComponent as NSString).deletingPathExtension + " <line:\(line)> " + "`\(function)`"
    }
    
    /// 内容描述
    /// - Parameter items: 可变参数
    /// - Returns: 内容描述
    static func body(_ items: [Any]) -> String {
        if items.count > 0 {
            var str = "\n"
            for i in 0 ..< items.count {
                str += "\(items[i])"
                if i < items.count - 1 {
                    str += " "
                }
            }
            str += "\n"
            return str
        } else {
            return ""
        }
    }
    
    /// 记录日志
    /// - Parameters:
    ///   - level: 日志等级
    ///   - items: 日志内容
    ///   - file: 记录所在文件
    ///   - line: 记录所在行
    ///   - function: 记录所在函数
    static func record(level: Level = .low, items: [Any], file: String = #file, line: Int = #line, function: String = #function) {
        guard enableLogger == true else { return }
        let _ = shared
        // 标题
        var str = "\n"
        str += "[\(time())](\(level.rawValue)) "
        if let emoji = level.emoji {
            str += emoji + " "
        }
        str += meta(file: file, line: line, function: function)
        if level.rawValue >= printLevel.rawValue {
            print(str.replacingOccurrences(of: "`", with: ""))
        }
        
        // 内容
        if items.count > 0 {
            let bodyStr = body(items)
            str += "\n```" + bodyStr + "```\n"
            if level.rawValue >= printLevel.rawValue {
                print(bodyStr.replacingOccurrences(of: "\n", with: ""))
            }
        }
        if level.rawValue >= cacheLevel.rawValue {
            write(str)
        }
    }
    
}

// MARK: 读写缓存
extension Logger {
    
    /// 路径
    /// - Returns: 路径
    static func baseURL() -> URL {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(folder, isDirectory: true)
    }
    
    /// 当前日志文件路径
    /// - Returns: 当前日志文件路径
    static func fileURL() -> URL {
        // app名称 + 日期 + 设备名
        let fileName = "\(InfoDict.appName)-\(today())-\(InfoDict.deviceName).\(ext)"
        return baseURL().appendingPathComponent(fileName, isDirectory: true)
    }
    
    /// 获取所有日志的子路径
    /// - Returns: 所有日志的子路径
    static func subpaths() -> [String] {
        var all = [String]()
        if let dirEnum = FileManager.default.enumerator(atPath: baseURL().path) {
            all = (dirEnum.allObjects as? [String]) ?? [String]()
        }
        if let idx = all.firstIndex(of: ".DS_Store") {
            all.remove(at: idx)
        }
        return all.sorted().reversed()
    }
    
    /// 获取最新的几份日志
    /// - Parameter latest: 最新的几份
    /// - Returns: 日志
    public static func read(logs count: Int) -> [URL]? {
        var logs = subpaths()
        if logs.count > count {
            logs = logs.dropLast(logs.count - count)
        }
        return logs.map({ (str) -> URL in
            return baseURL().appendingPathComponent(str)
        })
    }
    
    /// 写日志到文件
    /// - Parameter str: 日志内容
    static func write(_ str: String) {
        queue.async {
            let path = self.fileURL().path
            if let handle = FileHandle.init(forWritingAtPath: path), let data = str.data(using: .utf8) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            } else {
                print("写日志失败！")
            }
        }
    }
    
}

public extension Logger {
    
    static func trace(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .trace, items: items, file: file, line: line, function: function)
    }
    static func debug(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .debug, items: items, file: file, line: line, function: function)
    }
    static func info(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .info, items: items, file: file, line: line, function: function)
    }
    static func notice(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .notice, items: items, file: file, line: line, function: function)
    }
    static func error(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .error, items: items, file: file, line: line, function: function)
    }
    static func warning(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .warning, items: items, file: file, line: line, function: function)
    }
    static func critical(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        Logger.record(level: .critical, items: items, file: file, line: line, function: function)
    }
    
}
