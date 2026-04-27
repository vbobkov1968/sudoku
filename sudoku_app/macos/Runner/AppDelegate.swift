import Cocoa
import FlutterMacOS

private class ViewMenuTranslator: NSObject, NSMenuDelegate {
  var isRussian = false

  func menuWillOpen(_ menu: NSMenu) {
    guard isRussian else { return }
    applyRussianFullScreenTitle(menu)
    // macOS may update the title after menuWillOpen returns, so patch again async
    DispatchQueue.main.async { [weak self] in
      guard self?.isRussian == true else { return }
      self?.applyRussianFullScreenTitle(menu)
    }
  }

  func menuNeedsUpdate(_ menu: NSMenu) {
    guard isRussian else { return }
    applyRussianFullScreenTitle(menu)
  }

  private func applyRussianFullScreenTitle(_ menu: NSMenu) {
    let isFS = NSApp.mainWindow?.styleMask.contains(.fullScreen) ?? false
    let toggleFS = NSSelectorFromString("toggleFullScreen:")
    for item in menu.items where item.action == toggleFS {
      item.title = isFS ? "Выйти из полноэкранного режима" : "На весь экран"
    }
  }
}

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  private var savedAppleMenuTitles: [Int: String] = [:]
  private var currentLocale = "en"
  private let viewMenuTranslator = ViewMenuTranslator()

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    saveOriginalAppleMenuTitles()
    let lang = UserDefaults.standard.string(forKey: "flutter.settings_locale") ?? "en"
    applyLocale(lang)
  }

  override func applicationWillUpdate(_ notification: Notification) {
    let toggleFS = NSSelectorFromString("toggleFullScreen:")
    for item in NSApp.mainMenu?.items ?? [] {
      if currentLocale == "ru" {
        if item.title == "View"  { item.title = "Вид";     item.submenu?.title = "Вид" }
        if item.title == "Help"  { item.title = "Справка"; item.submenu?.title = "Справка" }
      }
      // Re-attach delegate every update in case macOS replaced the submenu object
      if let sub = item.submenu, sub.items.contains(where: { $0.action == toggleFS }) {
        if !(sub.delegate === viewMenuTranslator) {
          sub.delegate = viewMenuTranslator
        }
      }
    }
  }

  func applyLocale(_ lang: String) {
    currentLocale = lang
    viewMenuTranslator.isRussian = (lang == "ru")
    if lang == "ru" {
      translateAppleMenuToRussian()
      localizeTopMenus(toRussian: true)
    } else {
      revertAppleMenuToEnglish()
      localizeTopMenus(toRussian: false)
    }
  }

  // MARK: - Apple menu

  private func saveOriginalAppleMenuTitles() {
    guard let items = NSApp.mainMenu?.item(at: 0)?.submenu?.items else { return }
    for i in [0, 2, 4, 6, 7, 8, 10] {
      if items.indices.contains(i) { savedAppleMenuTitles[i] = items[i].title }
    }
  }

  private func translateAppleMenuToRussian() {
    guard let items = NSApp.mainMenu?.item(at: 0)?.submenu?.items else { return }
    if items.indices.contains(0)  { items[0].title  = "О приложении" }
    if items.indices.contains(2)  { items[2].title  = "Настройки" }
    if items.indices.contains(4)  { items[4].title  = "Службы" }
    if items.indices.contains(6)  { items[6].title  = "Скрыть" }
    if items.indices.contains(7)  { items[7].title  = "Скрыть остальные" }
    if items.indices.contains(8)  { items[8].title  = "Показать все" }
    if items.indices.contains(10) { items[10].title = "Завершить" }
  }

  private func revertAppleMenuToEnglish() {
    guard let items = NSApp.mainMenu?.item(at: 0)?.submenu?.items else { return }
    if savedAppleMenuTitles.isEmpty { saveOriginalAppleMenuTitles() }
    if savedAppleMenuTitles.isEmpty {
      // Fallback: reconstruct from bundle name in case save ran before menu was ready
      let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sudoku"
      let english: [Int: String] = [
        0: "About \(name)",
        2: "Settings\u{2026}",
        4: "Services",
        6: "Hide \(name)",
        7: "Hide Others",
        8: "Show All",
        10: "Quit \(name)"
      ]
      for (i, title) in english {
        if items.indices.contains(i) { items[i].title = title }
      }
      return
    }
    for (i, title) in savedAppleMenuTitles {
      if items.indices.contains(i) { items[i].title = title }
    }
  }

  // MARK: - View / Help menus

  private func localizeTopMenus(toRussian: Bool) {
    let toggleFS = NSSelectorFromString("toggleFullScreen:")
    for item in NSApp.mainMenu?.items ?? [] {
      if let sub = item.submenu, sub.items.contains(where: { $0.action == toggleFS }) {
        item.title = toRussian ? "Вид" : "View"
        item.submenu?.title = toRussian ? "Вид" : "View"
        sub.delegate = viewMenuTranslator
        sub.items.filter { $0.action == toggleFS }.forEach {
          $0.title = toRussian ? "На весь экран" : "Enter Full Screen"
        }
      }
      let t = item.title
      if t == "Help" || t == "Справка" {
        item.title = toRussian ? "Справка" : "Help"
        item.submenu?.title = toRussian ? "Справка" : "Help"
      }
    }
  }

  // MARK: - Menu actions

  @IBAction func openSettings(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openSettings", arguments: nil)
  }

  @IBAction func openAbout(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openAbout", arguments: nil)
  }
}
