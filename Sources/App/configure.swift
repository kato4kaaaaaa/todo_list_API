import Fluent
import FluentPostgresDriver
import Vapor
import NIOSSL // <--- ДОДАЙТЕ ЦЕЙ ІМПОРТ! Він потрібен для TLSConfiguration.

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure PostgreSQL
    let dbHost = Environment.get("DATABASE_HOST") ?? "localhost"
    let dbPortString = Environment.get("DATABASE_PORT") ?? "5432"
    let dbUser = Environment.get("DATABASE_USERNAME") ?? "vapor_username"
    let dbPassword = Environment.get("DATABASE_PASSWORD") ?? "vapor_password"
    let dbName = Environment.get("DATABASE_NAME") ?? "vapor_database"

    guard let dbPort = Int(dbPortString) else {
        fatalError("DATABASE_PORT is not a valid integer")
    }

    // Створюємо об'єкт конфігурації для PostgreSQL
    // Оскільки параметр tls обов'язковий, ми передаємо nil, якщо TLS не потрібен
    let postgresConfig = SQLPostgresConfiguration(
        hostname: dbHost,
        port: dbPort,
        username: dbUser,
        password: dbPassword,
        database: dbName,
        tls: .disable // <--- ЗМІНА ТУТ: Явно вказуємо, що TLS вимкнено
        // Або, якщо .disable не працює, спробуйте просто nil, але переконайтесь, що tlsConfiguration: TLSConfiguration? = nil існує
        // var tlsConfiguration: TLSConfiguration? = nil
        // tls: tlsConfiguration // <--- Якщо .disable не спрацює
    )

    // Використовуємо новий спосіб з явною фабрикою
    app.databases.use(
        .postgres(configuration: postgresConfig),
        as: .psql
    )

    // Add migrations
    app.migrations.add(CreateTodo())

    if app.environment != .testing {
         try await app.autoMigrate()
    }

    // register routes
    try routes(app)
}
