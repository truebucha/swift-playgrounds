//import OrderedCollections
import Apollo
import GraphiOSAutogenerated
import Foundation

public typealias ItemID = String

public struct User: Identifiable {
    public let id: ItemID
    public let name: String
}

public struct Task: Identifiable {
    public let id: ItemID
    public let name: String
    public let completed: Bool
}

public struct CreateTaskInput {
    public let name: String
    public let completed: Bool
    public let userId: String
    
    public init(name: String, completed: Bool, userId: String) {
        self.name = name
        self.completed = completed
        self.userId = userId
    }
}

public enum GraphError: Error {
    case noData
}

public struct GraphClientPackage {
    private let client = ApolloClient(url: URL(string: "http://localhost:3001/graphql")!)
    
    public init() {}
    
    public func fetchAllUsers() async throws -> [User] {
        try await withCheckedThrowingContinuation { continuation in
            self.client.fetch(query: AllUsersQuery()) { result in
                guard let clientUsers = try? result.get().data?.users else {
                    continuation.resume(throwing: result.error ?? GraphError.noData)
                    return
                }
                continuation.resume(returning: clientUsers.map {
                    User(id: $0.id, name: $0.name)
                })
            }
        }
    }
    
    public func fetchUserBy(id: ItemID) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            self.client.fetch(query: UserByIDQuery(id: id)) { result in
                guard let clientUser = try? result.get().data?.user else {
                    continuation.resume(throwing: result.error ?? GraphError.noData)
                    return
                }
                continuation.resume(returning:
                    User(id: clientUser.id, name: clientUser.name)
                )
            }
        }
    }
    
    public func fetchUserWithTasksBy(id: ItemID) async throws -> (user: User, tasks: [Task]) {
        try await withCheckedThrowingContinuation { continuation in
            self.client.fetch(query: UserWithTasksByIDQuery(id: id)) { result in
                guard let clientUser = try? result.get().data?.user else {
                    continuation.resume(throwing: result.error ?? GraphError.noData)
                    return
                }
                let tasks = (clientUser.tasks ?? []).map {
                    Task(id: $0.id, name: $0.name, completed: $0.completed)
                }
                continuation.resume(returning:
                    (User(id: clientUser.id, name: clientUser.name), tasks)
                )
            }
        }
    }
    
    public func fetchTaskBy(id: ItemID) async throws -> Task {
        try await withCheckedThrowingContinuation { continuation in
            self.client.fetch(query: TaskByIDQuery(id: id)) { result in
                guard let clientTask = try? result.get().data?.task else {
                    continuation.resume(throwing: result.error ?? GraphError.noData)
                    return
                }
                continuation.resume(returning:
                    Task(id: clientTask.id, name: clientTask.name, completed: clientTask.completed)
                )
            }
        }
    }
    
    public func createTask(input: CreateTaskInput) async throws -> ItemID {
        let clientInput = GraphiOSAutogenerated.CreateTaskInput(
            name: input.name,
            completed: input.completed,
            userId: input.userId
        )
        return try await withCheckedThrowingContinuation { continuation in
            _ = self.client.perform(
                mutation: CreateTaskMutation(input: clientInput),
                resultHandler: { result in
                    guard let clientTask = try? result.get().data?.createTask else {
                        continuation.resume(throwing: result.error ?? GraphError.noData)
                        return
                    }
                    continuation.resume(returning: clientTask.id as ItemID)
            })
        }
    }
}

extension Result {
    var error: Failure? {
        if case .failure(let failure) = self {
            return failure
        }
        return nil
    }
}
