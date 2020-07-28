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

@testable import StartCore
import XCTest

final class LogTests: XCTestCase {
    func testSimpleLog() {
        let destination = TestLogDestination()
        let log = Log(.verbose, tag: #function, to: [destination])
        log.verbose("verbose")
        log.debug("debug")
        log.info("info")
        log.warn("warn")
        log.error("error")
        XCTAssertEqual(destination.actions, [.verbose, .debug, .info, .warn, .error])
        XCTAssertEqual(destination.messages, ["verbose", "debug", "info", "warn", "error"])
    }
    
    func testConcurrentLog() {
        let counter = spa_int_create(0)
        let queue = DispatchQueue(label: "test")
        let destination = TestLogDestination()
        let log = Log(.verbose, tag: #function, to: [destination])
        let group = DispatchGroup()
        for i in 0..<100 {
            queue.async {
                log.debug(spa_int_load(counter))
                spa_int_add(counter, 1)
                if i == 99 {
                    group.leave()
                }
            }
        }
        group.enter()
        _ = group.wait(timeout: .distantFuture)
        XCTAssertEqual(spa_int_load(counter), 100)
        for i in 0..<100 {
            XCTAssertEqual(destination.messages[i], "\(i)")
        }
    }
}
