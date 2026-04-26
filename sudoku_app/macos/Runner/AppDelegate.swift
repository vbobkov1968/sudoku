import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  @IBAction func openSettings(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openSettings", arguments: nil)
  }

  @IBAction func openAbout(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openAbout", arguments: nil)
  }
}
