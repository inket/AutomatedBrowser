import Foundation
import AutomatedBrowser

let browser = try AutomatedBrowser(browser: .chrome(options: []), headless: false, chromeBinaryPath: nil)
try browser.load("https://github.com/inket")
sleep(2)
print("Current URL: \(try browser.currentURL ?? "")")
print("Source: \(try browser.pageSource?.prefix(60) ?? "")...")
sleep(2)
try browser.load("https://www.google.com")
sleep(2)
try browser.back()
sleep(2)
try browser.forward()
sleep(2)
try browser.quit()
