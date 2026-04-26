import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    // Rewire the standard "About AppName" menu item to our Flutter dialog.
    if let appMenu = NSApp.mainMenu?.item(at: 0)?.submenu {
      for item in appMenu.items {
        if item.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:)) {
          item.target = self
          item.action = #selector(openAbout(_:))
          break
        }
      }
    }
  }

  @IBAction func openSettings(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openSettings", arguments: nil)
  }

  @IBAction func openAbout(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openAbout", arguments: nil)
  }
}
