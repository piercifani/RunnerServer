import App
import Service
import Vapor
import Foundation

var config = Config.default()
var env = try Environment.detect()
var services = Services.default()

let defaultConfig = NIOServerConfig.default()
var serverConfig = NIOServerConfig(
    hostname: "0.0.0.0",
    port: 8080,
    backlog: defaultConfig.backlog,
    workerCount: defaultConfig.workerCount,
    maxBodySize: defaultConfig.maxBodySize,
    reuseAddress: defaultConfig.reuseAddress,
    tcpNoDelay: defaultConfig.tcpNoDelay
)
services.register { container in
    return serverConfig
}

try App.configure(&config, &env, &services)

let app = try Application(
    config: config,
    environment: env,
    services: services
)

try App.boot(app)

try app.run()
