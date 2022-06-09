@testable import App
import XCTVapor
import PlanningGame

final class ValidatorTests: XCTestCase {
    func testIsNotBlank() {
        // Given: A non-whitespace only string
        let testString = " \t\nSome string \t\n"
        
        // When/Then
        XCTAssertTrue(Validator.isNotBlank(testString))
    }
    
    func testIsNotBlankWithWhitespaceOnly() {
        // Given: A non-whitespace only string
        let testString = " \t\n"
        
        // When/Then
        XCTAssertFalse(Validator.isNotBlank(testString))
    }
    
    func testTrimmedAndSanitized() {
        // Given
        let xssString = " \t\nSome invalid string <script>alert(\"xss\")</script> \t\n"
        
        // When
        let cleanString = Validator.trimmedAndSanitized(xssString)
        
        // Then
        XCTAssertEqual(cleanString, "Some invalid string scriptalertxssscript")
    }
    
    func testTrimmedAndSanitizedWithWhitespaceAndSpecialCharactersOnly() {
        // Given
        let invalidString = " \t\n <>(\"\")</> \t\n"
        
        // When
        let cleanString = Validator.trimmedAndSanitized(invalidString)
        
        // Then
        XCTAssertEqual(cleanString, "")
    }
}
