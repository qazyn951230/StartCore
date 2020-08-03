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

public struct MemoryBuffer {
    public typealias Element = UInt8

    public private(set) var end: UnsafePointer<UInt8>
    public private(set) var start: UnsafePointer<UInt8>
    @usableFromInline
    private(set) var current: UnsafeMutablePointer<UInt8>
    @usableFromInline
    private(set) var storage: Storage

    public init(capacity: Int) {
        assert(capacity > 0)
        current = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        storage = Storage(bytes: current)
        start = UnsafePointer(current)
        end = UnsafePointer(current).advanced(by: capacity)
    }

    @inlinable
    public var count: Int {
        start.distance(to: current)
    }

    @inlinable
    public var capacity: Int {
        start.distance(to: end)
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        ensureUnique()
        guard minimumCapacity > capacity else {
            return
        }
        let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: minimumCapacity)
        storage.move(to: temp)
        let oldStart = UnsafeMutablePointer(mutating: start)
        let oldCount = count
        temp.moveAssign(from: oldStart, count: oldCount)
        start = UnsafePointer(temp)
        end = start.advanced(by: minimumCapacity)
        current = temp.advanced(by: oldCount)
    }

    @inlinable
    public mutating func append(_ newElement: UInt8) {
        precondition(UnsafePointer(current).distance(to: end) >= 1)
        ensureUnique()
        current.pointee = newElement
        current = current.advanced(by: 1)
    }

    @inlinable
    public mutating func append(_ buffer: UnsafePointer<UInt8>, count: Int) {
        precondition(UnsafePointer(current).distance(to: end) >= count)
        ensureUnique()
        current.initialize(from: buffer, count: count)
        current += count
    }

    @inlinable
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, S.Element == UInt8  {
        ensureUnique()
        var iterator = newElements.makeIterator()
        while let next = iterator.next() {
            self.append(next)
        }
    }

    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        ensureUnique()
        current = UnsafeMutablePointer(mutating: start)
    }

    @usableFromInline
    mutating func ensureUnique() {
        if (isKnownUniquelyReferenced(&storage)) {
            return
        }
        let capacity = self.capacity
        let count = self.count
        let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
        storage = Storage(bytes: temp)
        start = UnsafePointer(temp)
        current = temp + count
        end = start + capacity
    }

    @usableFromInline
    final class Storage {
        @usableFromInline
        private(set) var bytes: UnsafeMutablePointer<UInt8>?

        init(bytes: UnsafeMutablePointer<UInt8>) {
            self.bytes = bytes
        }

        @inline(__always)
        @usableFromInline
        func remove() {
            bytes = nil
        }

        @inline(__always)
        @usableFromInline
        func move(to pointer: UnsafeMutablePointer<UInt8>) {
            bytes?.deallocate()
            bytes = pointer
        }

        deinit {
            bytes?.deallocate()
        }
    }
}
