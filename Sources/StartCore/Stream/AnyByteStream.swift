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

public class AnyByteStream: ByteInputStream, ByteOutputStream {
    public typealias Value = UInt8

    private let provider: Provider

    public init<Stream>(input: Stream) where Stream: ByteInputStream {
        provider = Provider.input(_ByteInputStream<Stream>(input))
    }

    public init<Stream>(output: Stream) where Stream: ByteOutputStream {
        provider = Provider.output(_ByteOutputStream<Stream>(output))
    }

    public var readable: Bool {
        if case .input = provider {
            return true
        } else {
            return false
        }
    }

    public var writable: Bool {
        if case .output = provider {
            return true
        } else {
            return false
        }
    }

    public func read() -> UInt8? {
        guard case let .input(stream) = provider else {
            return nil
        }
        return stream.read()
    }

    public func read(count: Int) -> Data {
        guard case let .input(stream) = provider else {
            return Data()
        }
        return stream.read(count: count)
    }

    public func readAll() -> Data {
        guard case let .input(stream) = provider else {
            return Data()
        }
        return stream.readAll()
    }

    public func write(_ value: UInt8) {
        guard case let .output(stream) = provider else {
            return
        }
        stream.write(value)
    }

    public func write<C>(_ value: C) where C: Collection, Value == C.Element {
        guard case let .output(stream) = provider else {
            return
        }
        stream.write(value)
    }

    public func write(_ string: String) {
        guard case let .output(stream) = provider else {
            return
        }
        stream.write(string)
    }

    public func write(_ string: String, encoding: String.Encoding) {
        guard case let .output(stream) = provider else {
            return
        }
        stream.write(string, encoding: encoding)
    }

    public func write(_ data: Data) {
        guard case let .output(stream) = provider else {
            return
        }
        stream.write(data)
    }

    public func flush() {
        guard case let .output(stream) = provider else {
            return
        }
        stream.flush()
    }

    public func close() {
        switch provider {
        case let .input(input):
            input.close()
        case let .output(output):
            output.close()
        }
    }

    private enum Provider {
        case input(_AnyByteInputStream)
        case output(_AnyByteOutputStream)
    }
}

private class _AnyByteInputStream: ByteInputStream {
    typealias Value = UInt8

    func read() -> UInt8? {
        fatalError("\(#function) has not been implemented")
    }

    func read(count: Int) -> Data {
        fatalError("\(#function) has not been implemented")
    }

    func readAll() -> Data {
        fatalError("\(#function) has not been implemented")
    }

    func close() {
        fatalError("\(#function) has not been implemented")
    }
}

private class _ByteInputStream<Stream>: _AnyByteInputStream where Stream: ByteInputStream {
    private var stream: Stream

    init(_ stream: Stream) {
        self.stream = stream
    }
    
    override func read() -> UInt8? {
        stream.read()
    }
    
    override func read(count: Int) -> Data {
        stream.read(count: count)
    }
    
    override func readAll() -> Data {
        stream.readAll()
    }
    
    override func close() {
        stream.close()
    }
}

private class _AnyByteOutputStream: ByteOutputStream {
    typealias Value = UInt8
    
    func write(_ value: UInt8) {
        fatalError("\(#function) has not been implemented")
    }

    func write<C>(_ value: C) where C: Collection, Value == C.Element {
        fatalError("\(#function) has not been implemented")
    }

    func write(_ string: String) {
        fatalError("\(#function) has not been implemented")
    }

    func write(_ string: String, encoding: String.Encoding) {
        fatalError("\(#function) has not been implemented")
    }

    func write(_ data: Data) {
        fatalError("\(#function) has not been implemented")
    }

    func close() {
        fatalError("\(#function) has not been implemented")
    }

    func flush() {
        fatalError("\(#function) has not been implemented")
    }
}

private class _ByteOutputStream<Stream>: _AnyByteOutputStream where Stream: ByteOutputStream {
    private var stream: Stream
    
    init(_ stream: Stream) {
        self.stream = stream
    }
    
    override func write(_ value: UInt8) {
        stream.write(value)
    }
    
    override func write<C>(_ value: C) where C : Collection, Value == C.Element {
        stream.write(value)
    }
    
    override func write(_ string: String) {
        stream.write(string)
    }
    
    override func write(_ string: String, encoding: String.Encoding) {
        stream.write(string, encoding: encoding)
    }
    
    override func write(_ data: Data) {
        stream.write(data)
    }
    
    override func close() {
        stream.close()
    }
    
    override func flush() {
        stream.flush()
    }
}
