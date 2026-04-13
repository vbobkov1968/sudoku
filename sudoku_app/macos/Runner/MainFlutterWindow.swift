import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    // Set initial and minimum window size
    let minSize = NSSize(width: 950, height: 750)
    let initialSize = NSSize(width: 1050, height: 800)
    
    self.minSize = minSize
    self.setContentSize(initialSize)
    self.center()
    
    self.contentViewController = flutterViewController

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
