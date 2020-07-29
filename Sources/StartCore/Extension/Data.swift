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

extension Data {
    public func load<T>(_ target: inout T, offset: Int = 0) {
        assert(count >= MemoryLayout<T>.size + offset)
        withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
            if let base = pointer.baseAddress {
                let raw = base + offset
                withUnsafeMutablePointer(to: &target) { (t: UnsafeMutablePointer<T>) -> Void in
                    t.initialize(from: raw.assumingMemoryBound(to: T.self), count: 1)
                }
            } else {
                fatalError()
            }
        }
    }

    public func load<T>(offset: Int = 0, _ creator: () -> T) -> T {
        assert(count >= MemoryLayout<T>.size + offset)
        var target = creator()
        withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
            if let base = pointer.baseAddress {
                let raw = base + offset
                withUnsafeMutablePointer(to: &target) { (t: UnsafeMutablePointer<T>) -> Void in
                    t.initialize(from: raw.assumingMemoryBound(to: T.self), count: 1)
                }
            } else {
                fatalError()
            }
        }
        return target
    }

    public func load<T>(offset: Int = 0, as type: T.Type) -> T {
        assert(count >= MemoryLayout<T>.size + offset)
        return withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> T in
            if let base = pointer.baseAddress {
                let raw = base + offset
                return raw.load(as: type)
            } else {
                fatalError()
            }
        }
    }

    public func loadCString(offset: Int) -> String? {
        return withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> String? in
            ((pointer.baseAddress?.advanced(by: offset))?
                .assumingMemoryBound(to: UInt8.self))
                .map(String.init(cString:))
        }
    }
}
