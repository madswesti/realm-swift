////////////////////////////////////////////////////////////////////////////
 //
 // Copyright 2021 Realm Inc.
 //
 // Licensed under the Apache License, Version 2.0 (the "License");
 // you may not use this file except in compliance with the License.
 // You may obtain a copy of the License at
 //
 // http://www.apache.org/licenses/LICENSE-2.0
 //
 // Unless required by applicable law or agreed to in writing, software
 // distributed under the License is distributed on an "AS IS" BASIS,
 // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 // See the License for the specific language governing permissions and
 // limitations under the License.
 //
 ////////////////////////////////////////////////////////////////////////////

import Foundation

// State Updates
// Some operations will return a `SubscriptionTask` which can be used to get state updates.
internal enum SyncSubscriptionState {
    // Subscription is complete and the server is in "steady-state" synchronization.
    case complete
    // The Subscription encountered an error.
    case error(Error)
    // The server is processing the subscription and updating the Realm data
    // with new matches
    case pending
}

extension SyncSubscriptionState: Equatable {
    static func == (lhs: SyncSubscriptionState, rhs: SyncSubscriptionState) -> Bool {
        true
    }
}

internal protocol AnySyncSubscription {}

internal class SyncSubscription<Element: Object>: AnySyncSubscription {
    internal typealias QueryFunction = (Query<Element>) -> Query<Element>

    // When the subscription was created. Recorded automatically.
    internal var createdAt: Date = Date()

    // When the subscription was last updated. Recorded automatically.
    internal var updatedAt: Date = Date()

    // Name of the subscription, if not specified it will return the value in Query
    internal var name: String = ""

    #if swift(>=5.4)
    // Update query for subscription
    internal func update(@QueryBuilder _ to: () -> (AnySyncSubscription)) throws {
        fatalError()
    }
    #endif // swift(>=5.4)

    private(set) internal var query: QueryFunction
    internal init(name: String = "", query: @escaping QueryFunction) {
        self.name = name
        self.query = query
    }
}

#if swift(>=5.4)
internal protocol QueryBuilderComponent {}

@resultBuilder internal struct QueryBuilder {
    internal static func buildBlock(_ components: AnySyncSubscription...) -> [AnySyncSubscription] {
        return components
    }

    internal static func buildBlock(_ component: AnySyncSubscription) -> AnySyncSubscription {
        return component
    }
}

internal protocol AnyQueryBuilderComponent {}
#endif // swift(>=5.4)

// Realm operations
// Realm will only allow getting all the subscriptions and subscribe to a query
extension Realm {
    // Get the active subscription set for this realm.
    internal var subscriptions: [AnySyncSubscription] {
        fatalError()
    }
}

// TODO: Can we observer changes on the subscription set?
// Task to get state changes from the write transaction
// @frozen
internal struct SyncSubscriptionTask {
    // Notifies state changes for the write subscription transaction
    // if state is complete this will return complete, will
    // throw an error if someone updates the subscription set while waiting
    internal func observe(_ block: @escaping (SyncSubscriptionState) -> Void) {
        fatalError()
    }
}

#if swift(>=5.5) && canImport(_Concurrency)
@available(macOS 12.0, tvOS 15.0, iOS 15.0, watchOS 8.0, *)
extension SyncSubscriptionTask {
    // Notifies state changes for the write subscription transaction
    // if state is complete this will return complete, will
    // throw an error if someone updates the subscription set while waiting
    internal var state: AsyncStream<SyncSubscriptionState> {
        fatalError()
    }
}
#endif // swift(>=5.5)

// SubscriptionSet
extension Array where Element == AnySyncSubscription {
    // Creates a write transaction and updates the subscription set, this will not wait
    // for the server to acknowledge and see all the data associated with this collection of
    // subscriptions
    @discardableResult
    internal func write(_ block: (() throws -> Void)) throws -> SyncSubscriptionTask {
        fatalError()
    }

    // Wait for the server to acknowledge and send all the data associated with this
    // subscription set, if state is complete this will return immediately, will
    // throw an error if someone updates the subscription set will waiting
    // Completion block version
    internal func `observe`(completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError()
    }

    #if swift(>=5.4)
    // Find subscription in the subscription set by subscription properties
    internal func first<Element: Object>(`where`: @escaping (SyncSubscription<Element>) -> Bool) -> SyncSubscription<Element>? {
        fatalError()
    }

    // Find subscription in the subscription set by query
    internal func first<Element: Object>(@QueryBuilder _ `where`: () -> (AnySyncSubscription)) -> SyncSubscription<Element>? {
        fatalError()
    }

    // Add a queries to the subscription set, this has to be done within a write block
    internal func `append`(@QueryBuilder _ to: () -> ([AnySyncSubscription])) {
        fatalError()
    }

    // Add a query to the subscription set, this has to be done within a write block
    internal func `append`(@QueryBuilder _ to: () -> (AnySyncSubscription)) {
        fatalError()
    }

    // Remove subscriptions of subscription set by query, this has to be done within a write block
    internal func remove(@QueryBuilder _ to: () -> ([AnySyncSubscription])) throws {
        fatalError()
    }

    // Remove subscription of subscription set by query, this has to be done within a write block
    internal func remove(@QueryBuilder _ to: () -> (AnySyncSubscription)) throws {
        fatalError()
    }
    #endif // swift(>=5.4)

    // Remove a subscription from the subscription set, this has to be done within a write block
    internal func remove(_ subscription: AnySyncSubscription) throws {
        fatalError()
    }

    // Remove subscription of subscription set by name, this has to be done within a write block
    internal func remove(_ name: String) throws {
        fatalError()
    }

    // Remove all subscriptions from the subscriptions set
    internal func removeAll() throws {
        fatalError()
    }

    // Remove all subscriptions from the subscriptions set by type
    internal func removeAll<Element: Object>(ofType type: Element.Type) throws {
        fatalError()
    }
}

#if swift(>=5.5) && canImport(_Concurrency)
@available(macOS 12.0, tvOS 15.0, iOS 15.0, watchOS 8.0, *)
extension Array where Element == AnySyncSubscription {
    // Asynchronously creates and commit a write transaction and updates the subscription set,
    // this will not wait for the server to acknowledge and see all the data associated with this
    // collection of subscription
    @discardableResult
    internal func write(_ block: (() throws -> Void)) async throws -> SyncSubscriptionTask {
        fatalError()
    }
}
#endif // swift(>=5.5)
