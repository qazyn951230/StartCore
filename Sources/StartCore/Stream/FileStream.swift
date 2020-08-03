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

import Darwin.C
import Foundation

public struct FileStream {
    private init() {
        // Do nothing.
    }

    public enum Deallocator {
        case close
        case none
    }

    public static var standardInput: FileInputStream {
        FileInputStream(file: stderr, deallocator: .none)
    }

    public static var standardOutput: FileOutputStream {
        FileOutputStream(file: stdout, deallocator: .none)
    }

    public static var standardError: FileOutputStream {
        FileOutputStream(file: stderr, deallocator: .none)
    }
}

public final class FileInputStream: ByteInputStream {
    public typealias Value = UInt8

    private let file: UnsafeMutablePointer<FILE>
    private let deallocator: FileStream.Deallocator

    // nonzero value if the end of the stream has been reached, otherwise ​`0​`
    var eof: Bool { feof(file) != 0 }

    public init(file: UnsafeMutablePointer<FILE>, deallocator: FileStream.Deallocator = .close) {
        self.file = file
        self.deallocator = deallocator
    }

    public init(path: Path, mode: String = "rb") throws {
        guard let file = fopen(path.string, mode) else {
            throw Errors.posix()
        }
        self.file = file
        deallocator = .close
    }

    deinit {
        close()
    }

    public func read() -> UInt8? {
        if eof {
            return nil
        }
        var i: UInt8 = 0
        let count = withUnsafeMutablePointer(to: &i) { p in
            _read(to: p, count: 1).or(-1)
        }
        return count > 0 ? i : nil
    }

//    public func read(count: Int) -> [UInt8] {
//        if count <= 0 || eof {
//            return []
//        }
//        var size = -1
//        let result = Array<UInt8>.init(unsafeUninitializedCapacity: count) { (pointer, initializedCount) in
//            size = _read(to: pointer.baseAddress!, size: count)
//            initializedCount = count
//        }
//        if size == count {
//            return result
//        } else if size > 0 {
//            return Array(result[0..<count])
//        } else {
//            return []
//        }
//    }

    public func read(count: Int) -> Data {
        if count <= 0 || eof {
            return Data()
        }
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        let size = _read(to: data, count: count).or(-1)
        if size > 0 {
            return Data(bytesNoCopy: UnsafeMutableRawPointer(data), count: size, deallocator: .free)
        } else {
            return Data()
        }
    }

    public func readAll() -> Data {
        guard let current = position().orNil(),
            fseek(file, 0 , SEEK_END) == 0,
            let fileSize = position().orNil(),
            fseek(file, current, SEEK_SET) == 0 else {
            return Data()
        }
        let count = fileSize - current
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        let size = _read(to: data, count: count).or(-1)
        if size > 0 {
            return Data(bytesNoCopy: UnsafeMutableRawPointer(data), count: size, deallocator: .free)
        } else {
            return Data()
        }
    }
    
    private func position() -> Result<Int, Error> {
        let n = ftell(file)
        return n == -1 ? .failure(Errors.posix()) : .success(n)
    }

    private func _read(to pointer: UnsafeMutablePointer<UInt8>, count: Int) -> Result<Int, Error> {
        assert(count > 0)
        var n = -1
        repeat {
            // https://en.cppreference.com/w/c/io/fread
            n = fread(pointer, 1, count, file)
        } while n == -1 && errno == EINTR
        if n == -1 {
            return .failure(Errors.posix())
        }
        return .success(n)
    }

    public func close() {
        if case .close = deallocator {
            fclose(file)
        }
    }
}

public final class FileOutputStream: ByteOutputStream {
    public typealias Value = UInt8

    private let file: UnsafeMutablePointer<FILE>
    private let deallocator: FileStream.Deallocator

    public init(file: UnsafeMutablePointer<FILE>, deallocator: FileStream.Deallocator = .close) {
        self.file = file
        self.deallocator = deallocator
    }

    public init(path: Path, mode: String = "wb") throws {
        guard let file = fopen(path.string, mode) else {
            throw Errors.posix()
        }
        self.file = file
        deallocator = .close
    }

    deinit {
        close()
    }

    public func write(_ value: UInt8) {
        _ = withUnsafePointer(to: value) { p in
            _write(pointer: p, count: MemoryLayout<UInt8>.size)
        }
    }

    public func write<C>(_ value: C) where C: Collection, Value == C.Element {
        let count = value.count
        let sucssess = value.withContiguousStorageIfAvailable { (pointer: UnsafeBufferPointer<UInt8>) -> Bool in
            guard let base = pointer.baseAddress else {
                return false
            }
            return _write(pointer: base, count: count)
        }
        if sucssess != nil {
            return
        }
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        var current = data
        for item in value {
            current.initialize(to: item)
            current += 1
        }
        _ = _write(pointer: UnsafePointer<UInt8>(data), count: count)
        data.deallocate()
    }

    private func _write(pointer: UnsafePointer<UInt8>, count: Int) -> Bool {
        guard count > 0 else {
            return false
        }
        let raw = UnsafeRawPointer(pointer)
        while true {
            // https://en.cppreference.com/w/c/io/fwrite
            let n = fwrite(raw, 1, count, file)
            if n == count {
                return true
            } else if errno != EINTR {
                return false
            } else {
                continue
            }
        }
    }

    public func flush() {
        fflush(file)
    }

    public func close() {
        if case .close = deallocator {
            fclose(file)
        }
    }
}
