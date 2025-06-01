import Fluent

struct CreateTodo: AsyncMigration {
    // Змінюємо 'Database' на 'any Database'
    func prepare(on database: any Database) async throws { // <--- ЗМІНА ТУТ
        try await database.schema("todos")
            .id()
            .field("title", .string, .required)
            .field("is_completed", .bool, .required, .sql(.default(false)))
            .create()
    }

    // Змінюємо 'Database' на 'any Database'
    func revert(on database: any Database) async throws { // <--- ЗМІНА ТУТ
        try await database.schema("todos").delete()
    }
}
