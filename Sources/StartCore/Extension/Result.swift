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

extension Result {
    @inlinable
    public func orNil() -> Success? {
        switch self {
        case let .success(result):
            return result
        case .failure:
            return nil
        }
    }

    @inlinable
    public func orNil(_ value: @autoclosure () -> Success?) -> Success? {
        switch self {
        case let .success(result):
            return result
        case .failure:
            return value()
        }
    }

    @inlinable
    public func or(_ value: @autoclosure () -> Success) -> Success {
        switch self {
        case let .success(result):
            return result
        case .failure:
            return value()
        }
    }

    @inlinable
    public func mapKeyPath<Value>(_ keyPath: KeyPath<Success, Value>) -> Result<Value, Failure> {
        switch self {
        case let .success(value):
            return .success(value[keyPath: keyPath])
        case let .failure(error):
            return .failure(error)
        }
    }

    @inlinable
    public func mapKeyPath<Value>(_ keyPath: KeyPath<Success, Value?>) -> Result<Value?, Failure> {
        switch self {
        case let .success(value):
            return .success(value[keyPath: keyPath])
        case let .failure(error):
            return .failure(error)
        }
    }

    @inlinable
    public func mapKeyPath<Value>(_ keyPath: KeyPath<Success, Value?>,
                                  whenNil: @autoclosure () -> Failure) -> Result<Value, Failure> {
        switch self {
        case let .success(value):
            if let t = value[keyPath: keyPath] {
                return .success(t)
            } else {
                return .failure(whenNil())
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result where Success: Equatable {
    public static func == (lhs: Result, rhs: Success) -> Bool {
        switch lhs {
        case let .success(result):
            return result == rhs
        case .failure:
            return false
        }
    }

    public static func != (lhs: Result, rhs: Success) -> Bool {
        switch lhs {
        case let .success(result):
            return result != rhs
        case .failure:
            return true
        }
    }

    public static func == (lhs: Success, rhs: Result) -> Bool {
        switch rhs {
        case let .success(result):
            return result == lhs
        case .failure:
            return false
        }
    }

    public static func != (lhs: Success, rhs: Result) -> Bool {
        switch rhs {
        case let .success(result):
            return result != lhs
        case .failure:
            return true
        }
    }
}
