import Fluent
import Vapor

struct TodoController: RouteCollection {
    // Змінюємо 'RoutesBuilder' на 'any RoutesBuilder'
    func boot(routes: any RoutesBuilder) throws { 
        let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
            todo.put(use: update)
            todo.get(use: getOne)
        }
    }

    // GET /todos
    func index(req: Request) async throws -> [Todo] {
        try await Todo.query(on: req.db).all()
    }

    // POST /todos
    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        try await todo.save(on: req.db)
        return todo
    }
    
    // GET /todos/:todoID
    func getOne(req: Request) async throws -> Todo {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return todo
    }

    // PUT /todos/:todoID
    func update(req: Request) async throws -> Todo {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let input = try req.content.decode(Todo.self)
        
        todo.title = input.title
        todo.isCompleted = input.isCompleted
        
        try await todo.update(on: req.db)
        return todo
    }

    // DELETE /todos/:todoID
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }
}
