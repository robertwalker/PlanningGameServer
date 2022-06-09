@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testPlanningGame() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "", afterResponse: { (res) in
            let html = res.body.string
            
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers["Content-Type"], ["text/html; charset=utf-8"])
            XCTAssertTrue(html.contains("<title>Planning Game</title>"))
            XCTAssertTrue(html.contains("<script src=\"scripts/main.js\"></script>"))
        })
        
        try app.test(.GET, "scripts/main.js", afterResponse: { (res) in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers["Content-Type"], ["application/javascript"])
        })
    }
}
