import Foundation
import PythonKit

public final class AutomatedBrowser {
    public enum BrowserType {
        case chrome(options: [String])
        case undetectedChrome
    }

    enum BrowserError: Error {
        case noCookiesToSave
        case couldNotSaveCookies(_ error: Error)

        case cookiesNotInExpectedFormat
        case couldNotLoadCookies(_ error: Error)
    }

    public let driver: PythonObject
    private let dependencies = PythonDependencies()

    // MARK: - Lifecycle

    public init(browser: BrowserType, headless: Bool, chromeBinaryPath: String? = nil) throws {
        let sys = dependencies.sys
        print("[AutomatedBrowser] Python \(sys.version_info.major).\(sys.version_info.minor)")

        switch browser {
        case .chrome(options: let options):
            let webdriver = dependencies.webdriver
            let chromeOptions = try webdriver.ChromeOptions.throwing.dynamicallyCall(withArguments: [])

            if headless {
                try chromeOptions.add_argument.throwing.dynamicallyCall(withArguments: "--headless=new")
            }

            for option in options {
                try chromeOptions.add_argument.throwing.dynamicallyCall(withArguments: option)
            }

            if let chromeBinaryPath {
                chromeOptions.binary_location = chromeBinaryPath.pythonObject
            }

            driver = try webdriver.Chrome.throwing.dynamicallyCall(withKeywordArguments: ["options": chromeOptions])
        case .undetectedChrome:
            let arguments: KeyValuePairs<String, PythonConvertible>

            if let chromeBinaryPath {
                arguments = [
                    "headless": headless,
                    "browser_executable_path": chromeBinaryPath
                ]
            } else {
                arguments = [
                    "headless": headless
                ]
            }

            driver = try dependencies.undetectedchromedriver.Chrome.throwing.dynamicallyCall(
                withKeywordArguments: arguments
            )
        }
    }

    public func quit() throws {
        try driver.quit.throwing.dynamicallyCall(withArguments: [])
    }
}

// MARK: - Metadata

extension AutomatedBrowser {
    public var pageSource: String? {
        get throws {
            guard let source = driver.checking[dynamicMember: "page_source"] else {
                throw PythonError.invalidCall(driver)
            }

            return String(source)
        }
    }

    public var currentURL: String? {
        get throws {
            guard let url = driver.checking[dynamicMember: "current_url"] else {
                throw PythonError.invalidCall(driver)
            }

            return String(url)
        }
    }
}

// MARK: - Navigation

extension AutomatedBrowser {
    public func load(_ url: String) throws {
        try driver.get.throwing.dynamicallyCall(withArguments: url)
    }

    public func forward() throws {
        try driver.forward.throwing.dynamicallyCall(withArguments: [])
    }

    public func back() throws {
        try driver.back.throwing.dynamicallyCall(withArguments: [])
    }

    public func refresh() throws {
        try driver.refresh.throwing.dynamicallyCall(withArguments: [])
    }
}

// MARK: - Cookies

extension AutomatedBrowser {
    public func saveCookies(toPath path: String) throws {
        guard let cookiesJSON = String(dependencies.json.dumps(driver.get_cookies())) else {
            throw BrowserError.noCookiesToSave
        }

        do {
            try cookiesJSON.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            throw BrowserError.couldNotSaveCookies(error)
        }
    }

    public func loadCookies(fromPath path: String) throws {
        let fileContents: String

        do {
            fileContents = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            throw BrowserError.couldNotLoadCookies(error)
        }

        let cookies = dependencies.json.loads(fileContents)
        for cookie in cookies {
            try driver.add_cookie.throwing.dynamicallyCall(withArguments: cookie)
        }
    }

    public func deleteAllCookies() throws {
        try driver.delete_all_cookies.throwing.dynamicallyCall(withArguments: [])
    }
}

// MARK: - Interactions

extension AutomatedBrowser {
    public func scroll(by amount: CGSize) throws {
        try dependencies
            .webdriver
            .ActionChains(driver)
            .scroll_by_amount(Int(amount.width), Int(amount.height))
            .perform
            .throwing
            .dynamicallyCall(withArguments: [])
    }
}
