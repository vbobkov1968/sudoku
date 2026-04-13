import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    // Set initial and minimum window size
    // Desktop layout needs: grid(450) + gap(24) + panel(320) + padding(48) = ~842px width
    // Grid height: 450 + padding(48) = ~500px minimum
    let minSize = NSSize(width: 1000, height: 750)
    let initialSize = NSSize(width: 1100, height: 800)
    
    self.minSize = minSize
    self.setContentSize(initialSize)
    self.center()
    
    self.contentViewController = flutterViewController

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
