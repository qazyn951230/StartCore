// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Dispatch

public final class Log {
    public let level: LogLevel
    public let destinations: [LogDestination]
    public let tag: String

    @usableFromInline
    let queue: DispatchQueue?
    @usableFromInline
    let useDebugFormat: Bool
    @usableFromInline
    var messages: [Message] = []
    @usableFromInline
    var writing = spa_bool_create(false)

    deinit {
        spa_bool_free(writing)
    }
    
    public init(_ level: LogLevel, tag: String, to destinations: [LogDestination],
                debugFormat: Bool = false) {
        self.level = level
        self.destinations = destinations
        self.tag = tag
        self.useDebugFormat = debugFormat
        self.queue = nil
    }

    public init(_ level: LogLevel, tag: String, queue: DispatchQueue?,
                to destinations: [LogDestination], debugFormat: Bool = false) {
        self.level = level
        self.destinations = destinations
        self.tag = tag
        self.queue = queue ?? DispatchQueue(label: tag, qos: .utility)
        self.useDebugFormat = debugFormat
    }

    @inlinable
    public func verbose(_ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= .verbose && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: .verbose, tag: self.tag, subject: value(), file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func debug(_ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= .debug && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: .debug, tag: self.tag, subject: value(), file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func info(_ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= .info && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: .info, tag: self.tag, subject: value(), file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func warn(_ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= .warn && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: .warn, tag: self.tag, subject: value(), file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func error(_ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= .error && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: .error, tag: self.tag, subject: value(), file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func verbose(_ value: Any..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .verbose && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .verbose, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func debug(_ value: Any..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .debug && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .debug, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func info(_ value: Any..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .info && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .info, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func warn(_ value: Any..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .warn && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .warn, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func error(_ value: Any..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .error && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .error, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func verbose(any value: Any?..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .verbose && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .verbose, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func debug(any value: Any?..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .debug && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .debug, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func info(any value: Any?..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .info && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .info, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func warn(any value: Any?..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .warn && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .warn, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    @inlinable
    public func error(any value: Any?..., file: String = #file, function: String = #function,
        line: UInt = #line, column: UInt = #column) {
        guard self.level >= .error && self.level > LogLevel.off else {
            return
        }
        let subject = useDebugFormat ? value.reduce("", Log.debugFormat(result:next:)) :
            value.reduce("", Log.format(result:next:))
        let message = Message(level: .error, tag: self.tag, subject: subject, file: file,
            function: function, line: line, column: column)
        self.write(message: message)
    }

    public func write(message: Message) {
        guard self.level >= message.level && self.level > LogLevel.off else {
            return
        }
        messages.append(message)
        scheduleFlush()
    }

    @inlinable
    public func write(level: LogLevel, _ value: @autoclosure () -> String, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= level && self.level > LogLevel.off else {
            return
        }
        let message = Message(level: level, tag: tag, subject: value(), file: file,
            function: function, line: line, column: column)
        write(message: message)
    }

    @inlinable
    public func write(level: LogLevel, any value: @autoclosure () -> String?, file: String = #file,
        function: String = #function, line: UInt = #line, column: UInt = #column) {
        guard self.level >= level && self.level > LogLevel.off, let subject = value() else {
            return
        }
        let message = Message(level: level, tag: tag, subject: subject, file: file,
            function: function, line: line, column: column)
        write(message: message)
    }
    
    @inline(__always)
    func scheduleFlush() {
        if let queue = self.queue {
            queue.async {
                self.flush()
            }
        } else {
            flush()
        }
    }

    func flush() {
        if spa_bool_load(writing) {
            return
        }
        spa_bool_store(writing, true)
        let messages = self.messages
        self.messages.removeAll()
        let destinations = self.destinations
        for destination in destinations {
            destination.write(messages: messages)
        }
        spa_bool_store(writing, false)
        if self.messages.isNotEmpty {
            scheduleFlush()
        }
    }

    public struct Message {
        public let level: LogLevel
        public let tag: String
        public let subject: String
        public let file: String
        public let function: String
        public let line: UInt
        public let column: UInt

        public init(level: LogLevel,
            tag: String,
            subject: String,
            file: String,
            function: String,
            line: UInt,
            column: UInt) {
            self.level = level
            self.tag = tag
            self.subject = subject
            self.file = file
            self.function = function
            self.line = line
            self.column = column
        }
    }

    @usableFromInline
    @inline(__always)
    static func debugFormat(result: String, any value: Any?) -> String {
        if let temp = value {
            return result.isEmpty ? debugFormat(temp) : "\(result) \(debugFormat(temp))"
        } else {
            return result
        }
    }

    @usableFromInline
    @inline(__always)
    static func debugFormat(result: String, next value: Any) -> String {
        result.isEmpty ? debugFormat(value) : "\(result) \(debugFormat(value))"
    }

    @usableFromInline
    @inline(__always)
    static func debugFormat(_ value: Any) -> String {
        switch value {
        case let a as CustomStringConvertible:
            return a.description
        case let b as CustomDebugStringConvertible:
            return b.debugDescription
        default:
            return String(describing: value)
        }
    }

    @usableFromInline
    @inline(__always)
    static func format(result: String, any value: Any?) -> String {
        if let temp = value {
            return result.isEmpty ? format(temp) : "\(result) \(format(temp))"
        } else {
            return result
        }
    }

    @usableFromInline
    @inline(__always)
    static func format(result: String, next value: Any) -> String {
        result.isEmpty ? format(value) : "\(result) \(format(value))"
    }

    @usableFromInline
    @inline(__always)
    static func format(_ value: Any) -> String {
        switch value {
        case let a as CustomStringConvertible:
            return a.description
        default:
            return String(describing: value)
        }
    }
}
