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

@testable import Core
import XCTest
import Dispatch

extension DispatchQueue {
    func apply(iterations: Int, work: @escaping (Int) -> Void) {
        __dispatch_apply(iterations, self, work)
    }
}

final class AtomicTests: XCTestCase {
    func testAtomicIntCreate() {
        let a = spa_int_create(0)
        XCTAssertEqual(spa_int_load(a), 0)
        spa_int_free(a)

        let b = spa_int_create(42)
        XCTAssertEqual(spa_int_load(b), 42)
        spa_int_free(b)
    }

    func testAtomicIntLoad() {
        let a = spa_int_create(0)
        XCTAssertEqual(spa_int_load_explicit(a, .relaxed), 0)
        spa_int_free(a)

        let b = spa_int_create(42)
        XCTAssertEqual(spa_int_load_explicit(b, .relaxed), 42)
        spa_int_free(b)

        let c = spa_int_create(23)
        XCTAssertEqual(spa_int_load_explicit(c, .sequentiallyConsistent), 23)
        spa_int_free(c)
    }

    func testCAtomicIntAdd() {
        let value: SPAIntRef = spa_int_create(0)
        XCTAssertEqual(spa_int_load(value), 0)

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "test", qos: .utility, attributes: .concurrent)
        queue.apply(iterations: 10) { _ in
            group.enter()
            for _ in 0 ..< 1000 {
                spa_int_add(value, 1)
            }
            group.leave()
        }
        _ = group.wait(timeout: .distantFuture)
        XCTAssertEqual(spa_int_load(value), 10000)
        spa_int_free(value)
    }

    // https://github.com/ReactiveX/RxSwift/issues/1853
    func testCAtomicIntDataRace() {
        let value = spa_int_create(0)
        let group = DispatchGroup()
        for i in 0 ... 100 {
            DispatchQueue.global(qos: .background).async {
                if i % 2 == 0 {
                    spa_int_add(value, 1)
                } else {
                    spa_int_sub(value, 1)
                }
                if i == 100 {
                    group.leave()
                }
            }
        }
        group.enter()
        _ = group.wait(timeout: .distantFuture)
        XCTAssertEqual(spa_int_load(value), 1)
        spa_int_free(value)
    }

    // https://github.com/apple/swift-evolution/blob/master/proposals/0282-atomics.md#interaction-with-implicit-pointer-conversions
    func testConcurrentMutation() {
        let counter = spa_int_create(0)
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            for _ in 0 ..< 1_000_000 {
                spa_int_add(counter, 1)
            }
        }
        XCTAssertEqual(spa_int_load(counter), 10_000_000)
        spa_int_free(counter)
    }

    #if ENABLE_PERFORMANCE_TESTS
        func testCAtomicIntPerformance() {
            measure {
                let value = spa_int_create(0)
                for _ in 0 ..< LockTests.max {
                    spa_int_add(value, 1)
                }
                spa_int_free(value)
            }
        }
    #endif // ENABLE_PERFORMANCE_TESTS
}
