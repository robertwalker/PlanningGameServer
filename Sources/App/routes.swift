import Vapor

func routes(_ app: Application) throws {
    let socketStore = SocketStore(eventLoop: app.eventLoopGroup.next())
    let gameStore = GameStore()
    let controller = ChannelController(socketStore: socketStore, gameStore: gameStore)
    
    app.get { req async throws -> View in
        return try await req.view.render("index", ["showConsole": showConsole()])
    }
    
    app.webSocket("channel") { req, ws in
        controller.channel(req: req, ws: ws)
    }
    
    func showConsole() -> Bool {
        switch app.environment {
        case .development:
            return Environment.process.CONSOLE?.lowercased() == "true"
        default:
            return false
        }
    }
}
