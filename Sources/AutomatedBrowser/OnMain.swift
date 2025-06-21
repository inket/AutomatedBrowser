import Foundation

// This is needed because @MainActor is not respected on Linux for some reason, so we have to
// manually ensure all Python-related code runs on the main thread.
@MainActor
func onMain<T>(_ block: () throws -> T) throws -> T {
    if Thread.isMainThread {
        return try block()
    } else {
        return try DispatchQueue.main.sync {
            try block()
        }
    }
} 
