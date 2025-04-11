# AutomatedBrowser

A Swift package for interacting with [selenium](https://github.com/SeleniumHQ/selenium) and [undetected-chromedriver](https://github.com/ultrafunkamsterdam/undetected-chromedriver) (a selenium chromedriver) through python by using [PythonKit](https://github.com/pvieito/PythonKit).

Target is macOS/Linux where you can install python, Chrome, and the required python dependencies.

### How to use

```sh
pip install selenium undetected-chromedriver

# Run example
cd Example
swift run
```

```swift
import AutomatedBrowser

// Regular Chrome
let browser = try! AutomatedBrowser(headless: false)
// Undetected Chrome
let browser = try! AutomatedBrowser(headless: false, undetected: true)

// Do some stuff
browser.load("https://example.org")
print(browser.pageSource)
browser.quit()
```

### Contact

[mahdi.jp](https://mahdi.jp)
