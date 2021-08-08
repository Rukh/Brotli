//
//  Test.swift
//  Brotli
//
//  Created by Dmitry Gulyagin on 08.08.2021.
//

import XCTest
import Brotli
import Foundation

class Test: XCTestCase {
    
    private func makeTestData(size: Int = 1_000_000) -> Data {
        let encodedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        for index in 0 ..< size {
            encodedBytes[index] = .random(in: .min ... . max)
        }
        return Data(bytesNoCopy: encodedBytes, count: size, deallocator: .free)
    }
    
    func testHelloWorld() throws {
        func printBytes(_ data: Data) {
            let string = data
                .map { String(format: "%.2X", $0) }
                .joined(separator: " ")
            print("hex bytes \(data.count):", string)
        }
        
        // This code throws error: Data is too small to be encoded. Size must be >= 16.
        let shortData = "Hello World!".data(using: .utf8)!
        printBytes(shortData)
        XCTAssertThrowsError(try Brotli.encoded(shortData))
        
        // Correct way
        let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.".data(using: .utf8)!
        printBytes(data)
        let encoded = try Brotli.encoded(data)
        let decoded = try Brotli.decoded(encoded)
        XCTAssertFalse(encoded.isEmpty)
        XCTAssertEqual(data, decoded)
    }

    func testCoding() throws {
        let data = makeTestData()
        let encoded = try Brotli.encoded(data)
        let decoded = try Brotli.decoded(encoded)
        XCTAssertFalse(encoded.isEmpty)
        XCTAssertEqual(data, decoded)
    }

    func testPerformanceEncode() throws {
        let data = makeTestData()
        self.measure {
            let encoded = try? Brotli.encoded(data)
            XCTAssertNotNil(encoded)
        }
    }
    
    func testPerformanceDecode() throws {
        let data = makeTestData()
        let encoded = try Brotli.encoded(data)
        self.measure {
            let decoded = try? Brotli.decoded(encoded)
            XCTAssertNotNil(decoded)
        }
    }

}
