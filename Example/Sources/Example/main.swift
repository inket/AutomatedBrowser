import Foundation
import AutomatedBrowser

let browser = try! AutomatedBrowser(browser: .chrome(options: []), headless: false)
browser.load("https://github.com/inket")
print("Current URL: \(browser.currentURL ?? "")")
print("Source: \(browser.pageSource?.prefix(60) ?? "")...")
sleep(2)
browser.load("https://www.google.com")
sleep(2)
browser.back()
sleep(2)
browser.forward()
sleep(2)
browser.quit()
