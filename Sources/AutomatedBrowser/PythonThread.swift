import Foundation

// We have to ensure all Python-related code runs on the same thread. (we cannot force main thread on linux)
final class PythonThread {
    private static let shared = PythonThread()

    private let condition = NSCondition()
    private var taskQueue = [() -> Void]()
    private var thread: Thread

    private init() {
        thread = Thread()
        thread = Thread { [weak self] in
            guard let self else { return }
            while true {
                self.condition.lock()
                while self.taskQueue.isEmpty {
                    self.condition.wait()
                }
                let task = self.taskQueue.removeFirst()
                self.condition.unlock()

                task()
            }
        }
        thread.name = "PythonThread"
        thread.start()
    }

    private func run<T>(_ block: @escaping () throws -> T) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, Error>!

        // Wrap block in a closure returning Void, store in queue
        let task = {
            do {
                let value = try block()
                result = .success(value)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }

        condition.lock()
        taskQueue.append(task)
        condition.signal()
        condition.unlock()

        // Wait for task to complete
        semaphore.wait()

        switch result! {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    static func run<T>(_ block: @escaping () throws -> T) throws -> T {
        if Thread.current == shared.thread {
            try block()
        } else {
            try shared.run(block)
        }
    }
}
