import XCTest @testable import Radio_Sphere

// MARK: – MockURLProtocol zum Simulieren von API-Antworten class MockURLProtocol: URLProtocol { static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

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
        let (response, data) = try handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    } catch {
        client?.urlProtocol(self, didFailWithError: error)
    }
}

override func stopLoading() {
    // Keine zusätzliche Logik nötig.
}

}