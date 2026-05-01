import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  // Must match Flutter layout constants in game_screen.dart:
  //   hOffset = left padding (24) + right padding (24)
  //   vOffset = topPadding (52) + gap (16) + toolbar (64) + gap (12) + numpad (192) + bottomPad (24)
  private static let hOffset: CGFloat = 48
  private static let vOffset: CGFloat = 360
  private static let minGrid: CGFloat = 320
  private static let sizeKey  = "com.sudoku.windowSize"

  static var menuChannel: FlutterMethodChannel?

  private var lastFrameSize = NSSize.zero
  private var flutterVC: FlutterViewController?
  private var didFixLayers = false

  override func awakeFromNib() {
    let vc = FlutterViewController()
    flutterVC = vc

    let screen = NSScreen.main ?? NSScreen.screens[0]
    let visible = screen.visibleFrame
    let maxGrid = min(visible.width - Self.hOffset, visible.height - Self.vOffset)

    let initialGrid: CGFloat
    if let saved = Self.loadSavedGrid(maxGrid: maxGrid) {
      initialGrid = saved
    } else {
      initialGrid = min(max(maxGrid * 0.75, Self.minGrid), 520)
    }

    let initialSize = NSSize(width: initialGrid + Self.hOffset,
                             height: initialGrid + Self.vOffset)
    let minSize    = NSSize(width: Self.minGrid + Self.hOffset,
                            height: Self.minGrid + Self.vOffset)

    self.minSize = minSize
    self.setContentSize(initialSize)
    self.center()
    lastFrameSize = initialSize

    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    self.backgroundColor = .clear
    self.isOpaque = false

    self.delegate = self

    // FlutterViewController.backgroundColor defaults to black; clear it before engine starts.
    vc.backgroundColor = .clear

    // The blur must be a subview of the Flutter view (not a sibling), so that
    // the Flutter view itself remains the window's contentView and receives all
    // events.  Placing it at the very back keeps it behind Flutter's Metal layer.
    let flutterView = vc.view
    let blur = NSVisualEffectView(frame: flutterView.bounds)
    blur.material       = .underWindowBackground
    blur.blendingMode   = .behindWindow
    blur.state          = .active
    blur.alphaValue     = 0.75
    blur.autoresizingMask = [.width, .height]
    flutterView.addSubview(blur, positioned: .below, relativeTo: nil)

    self.contentView = flutterView

    RegisterGeneratedPlugins(registry: vc)

    MainFlutterWindow.menuChannel = FlutterMethodChannel(
      name: "com.sudoku/menu",
      binaryMessenger: vc.engine.binaryMessenger
    )
    MainFlutterWindow.menuChannel?.setMethodCallHandler { call, result in
      switch call.method {
      case "setLocale":
        if let lang = call.arguments as? String {
          (NSApp.delegate as? AppDelegate)?.applyLocale(lang)
        }
        result(nil)
      case "getPendingFile":
        result((NSApp.delegate as? AppDelegate)?.consumePendingFile())
      default:
        result(nil)
      }
    }

    super.awakeFromNib()
  }

  // MARK: - Persistence

  private static func loadSavedGrid(maxGrid: CGFloat) -> CGFloat? {
    let raw = UserDefaults.standard.double(forKey: sizeKey)
    guard raw > 0 else { return nil }
    return min(max(CGFloat(raw), minGrid), maxGrid)
  }

  private func saveWindowSize() {
    let grid = lastFrameSize.width - Self.hOffset
    UserDefaults.standard.set(Double(grid), forKey: Self.sizeKey)
  }

  // MARK: - NSWindowDelegate

  func windowDidBecomeKey(_ notification: Notification) {
    guard !didFixLayers else { return }
    didFixLayers = true
    // The Flutter engine resets layer opacity during init; fix it post-start.
    if let layer = flutterVC?.view.layer {
      layer.isOpaque = false
      layer.backgroundColor = CGColor.clear
    }
  }

  func windowDidEndLiveResize(_ notification: Notification) {
    saveWindowSize()
  }

  func windowWillClose(_ notification: Notification) {
    saveWindowSize()
  }

  func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
    let dw = abs(frameSize.width  - lastFrameSize.width)
    let dh = abs(frameSize.height - lastFrameSize.height)

    // Block corner resize — both axes moving simultaneously causes oscillation.
    if dw > 1.5 && dh > 1.5 { return lastFrameSize }

    let gridFromWidth  = frameSize.width  - Self.hOffset
    let gridFromHeight = frameSize.height - Self.vOffset
    let rawGrid = dw >= dh ? gridFromWidth : gridFromHeight
    var gridSize = max(rawGrid, Self.minGrid)

    if let screen = sender.screen ?? NSScreen.main {
      let maxGrid = min(screen.visibleFrame.width  - Self.hOffset,
                        screen.visibleFrame.height - Self.vOffset)
      gridSize = min(gridSize, maxGrid)
    }

    let constrained = NSSize(width: gridSize + Self.hOffset, height: gridSize + Self.vOffset)
    lastFrameSize = constrained
    return constrained
  }
}
