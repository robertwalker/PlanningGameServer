import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Use Leaf
    app.views.use(.leaf)
    
    // Register routes
    try routes(app)
}
