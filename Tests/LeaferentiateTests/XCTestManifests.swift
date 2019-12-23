import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LeaferentiateTests.allTests),
    ]
}
#endif
