import Foundation
import PythonKit

public final class AutomatedBrowser {
    enum BrowserError: Error {
        case noCookiesToSave
        case couldNotSaveCookies(_ error: Error)

        case cookiesNotInExpectedFormat
        case couldNotLoadCookies(_ error: Error)
    }

    public let driver: PythonObject
    private let dependencies = PythonDependencies()

    // MARK: - Lifecycle

    public init(headless: Bool, undetected: Bool = false) throws {
        let sys = dependencies.sys
        print("[AutomatedBrowser] Python \(sys.version_info.major).\(sys.version_info.minor)")

        if undetected {
            driver = dependencies.undetectedchromedriver.Chrome(headless: headless)
        } else {
            let webdriver = dependencies.webdriver
            let options = webdriver.ChromeOptions()
            if headless {
                options.add_argument("--headless=new")
            }
            driver = webdriver.Chrome(options: options)
        }

    }

    public func quit() {
        driver.quit()
    }
}

// MARK: - Metadata

extension AutomatedBrowser {
    public var pageSource: String? {
        String(driver.page_source)
    }

    public var currentURL: String? {
        String(driver.current_url)
    }
}

// MARK: - Navigation

extension AutomatedBrowser {
    public func load(_ url: String) {
        driver.get(url)
    }

    public func forward() {
        driver.forward()
    }

    public func back() {
        driver.back()
    }

    public func refresh() {
        driver.refresh()
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
            driver.add_cookie(cookie)
        }
    }

    public func deleteAllCookies() {
        driver.delete_all_cookies()
    }
}

// MARK: - Interactions

extension AutomatedBrowser {
    public func scroll(by amount: CGSize) {
        dependencies
            .webdriver
            .ActionChains(driver)
            .scroll_by_amount(Int(amount.width), Int(amount.height))
            .perform()
    }
}
