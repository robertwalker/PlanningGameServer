import Vapor

func routes(_ app: Application) throws {
    let socketStore = SocketStore(eventLoop: app.eventLoopGroup.next())
    let gameStore = GameStore()
    let controller = ChannelController(socketStore: socketStore, gameStore: gameStore)
    
    app.get { req async throws -> View in
        struct RootContext: Encodable {
            var showConsole: Bool
            var wsProtocol: String
        }
        let context = RootContext(showConsole: showConsole(), wsProtocol: wsProtocol());
        return try await req.view.render("index", context)
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
    
    func wsProtocol() -> String {
        switch app.environment {
        case .production:
            return "wss://"
        default:
            return "ws://"
        }
    }
}
