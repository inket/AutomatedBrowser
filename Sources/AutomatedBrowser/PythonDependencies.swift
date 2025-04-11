import PythonKit

final class PythonDependencies {
    enum DependencyError: Error {
        case missingDependency(_ error: Error)
    }

    private(set) lazy var sys = loadDependency("sys")
    private(set) lazy var json = loadDependency("json")
    private(set) lazy var undetectedchromedriver = loadDependency("undetected_chromedriver")
    private(set) lazy var webdriver = loadDependency("selenium.webdriver")

    private func loadDependency(_ name: String) -> PythonObject {
        let loadOrThrow: (String) throws -> PythonObject = { name in
            do {
                return try Python.attemptImport(name)
            } catch {
                throw DependencyError.missingDependency(error)
            }
        }

        return try! loadOrThrow(name)
    }
}
