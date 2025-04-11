//
//  MockURLProtocol.swift
//  Radio_Sphere
//
//  Created by Beatrix Bauer on 07.05.25.
//

import XCTest
@testable import Radio_Sphere

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
         return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
         return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler ist nicht gesetzt.")
            return
        }
        do {
            let (response, data) = try handler(self.request)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        } catch {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Keine zusätzliche Logik nötig.
    }
}
