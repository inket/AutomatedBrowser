import Foundation
import PythonKit

@MainActor
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
    private static let dependencies = PythonDependencies()

    // MARK: - Lifecycle

    public init(browser: BrowserType, headless: Bool, chromeBinaryPath: String? = nil) throws {
        #if os(macOS)
        print("""
        WARNING: It seems you are running this on macOS. There is a bug with chromium/selenium that creates a copy of Chrome every time it's ran (which ends up filling up your disk).
        See https://issues.chromium.org/issues/379125944
        Run the following command to find and delete them from time to time:
            find /private/var/folders -name "com.google.Chrome.code_sign_clone" -exec rm -r -- {} + 2>/dev/null 
        """)
        #endif

        driver = try onMain {
            let sys = Self.dependencies.sys
            print("[AutomatedBrowser] Python \(sys.version_info.major).\(sys.version_info.minor)")

            switch browser {
            case .chrome(options: let options):
                let webdriver = Self.dependencies.webdriver
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

                return try webdriver.Chrome.throwing.dynamicallyCall(withKeywordArguments: ["options": chromeOptions])
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

                return try Self.dependencies.undetectedchromedriver.Chrome.throwing.dynamicallyCall(
                    withKeywordArguments: arguments
                )
            }
        }
    }

    public func quit() throws {
        try onMain {
            try driver.quit.throwing.dynamicallyCall(withArguments: [])
        }
    }
}

// MARK: - Metadata

extension AutomatedBrowser {
    public var pageSource: String? {
        get throws {
            try onMain {
                guard let source = driver.checking[dynamicMember: "page_source"] else {
                    throw PythonError.invalidCall(driver)
                }

                return String(source)
            }
        }
    }

    public var currentURL: String? {
        get throws {
            try onMain {
                guard let url = driver.checking[dynamicMember: "current_url"] else {
                    throw PythonError.invalidCall(driver)
                }

                return String(url)
            }
        }
    }
}

// MARK: - Navigation

extension AutomatedBrowser {
    public func load(_ url: String) throws {
        try onMain {
            try driver.get.throwing.dynamicallyCall(withArguments: url)
        }
    }

    public func forward() throws {
        try onMain {
            try driver.forward.throwing.dynamicallyCall(withArguments: [])
        }
    }

    public func back() throws {
        try onMain {
            try driver.back.throwing.dynamicallyCall(withArguments: [])
        }
    }

    public func refresh() throws {
        try onMain {
            try driver.refresh.throwing.dynamicallyCall(withArguments: [])
        }
    }
}

// MARK: - Cookies

extension AutomatedBrowser {
    public func saveCookies(toPath path: String) throws {
        let cookiesJSON: String = try onMain {
            guard let cookiesJSON = String(Self.dependencies.json.dumps(driver.get_cookies())) else {
                throw BrowserError.noCookiesToSave
            }

            return cookiesJSON
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

        try onMain {
            let cookies = Self.dependencies.json.loads(fileContents)
            for cookie in cookies {
                try driver.add_cookie.throwing.dynamicallyCall(withArguments: cookie)
            }
        }
    }

    public func deleteAllCookies() throws {
        try onMain {
            try driver.delete_all_cookies.throwing.dynamicallyCall(withArguments: [])
        }
    }
}

// MARK: - Interactions

extension AutomatedBrowser {
    public func scroll(by amount: CGSize) throws {
        try onMain {
            try Self.dependencies
                .webdriver
                .ActionChains(driver)
                .scroll_by_amount(Int(amount.width), Int(amount.height))
                .perform
                .throwing
                .dynamicallyCall(withArguments: [])
        }
    }
}
