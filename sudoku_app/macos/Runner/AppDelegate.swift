import Cocoa
import FlutterMacOS

private class ViewMenuTranslator: NSObject, NSMenuDelegate {
  var isRussian = false

  func menuWillOpen(_ menu: NSMenu) {
    guard isRussian else { return }
    applyRussianFullScreenTitle(menu)
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

@main
class AppDelegate: FlutterAppDelegate {
  private var currentLocale = "en"
  private let viewMenuTranslator = ViewMenuTranslator()
  private var helpMenuItemAdded = false
  private var secretMenuItemAdded = false

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    let lang = UserDefaults.standard.string(forKey: "flutter.settings_locale") ?? "en"
    applyLocale(lang)
  }

  // MARK: - Lazy menu additions (called from applicationWillUpdate once menu is ready)

  private func ensureHelpMenuItemAdded() {
    guard !helpMenuItemAdded else { return }
    guard let helpMenu = NSApp.mainMenu?.items.first(where: {
      $0.title == "Help" || $0.title == "Справка"
    })?.submenu else { return }
    guard !helpMenu.items.contains(where: { $0.action == #selector(openHelp(_:)) }) else {
      helpMenuItemAdded = true
      return
    }
    let title = currentLocale == "ru" ? "Справка по Судоку" : "Sudoku Help"
    let item = NSMenuItem(title: title, action: #selector(openHelp(_:)), keyEquivalent: "/")
    item.keyEquivalentModifierMask = .command
    item.target = self
    helpMenu.addItem(.separator())
    helpMenu.addItem(item)
    helpMenuItemAdded = true
  }

  private func ensureSecretMenuItemAdded() {
    guard !secretMenuItemAdded else { return }
    guard let appleMenu = NSApp.mainMenu?.item(at: 0)?.submenu else { return }
    let aboutSel = NSSelectorFromString("orderFrontStandardAboutPanel:")
    guard let aboutItem = appleMenu.items.first(where: { $0.action == aboutSel }),
          let aboutIdx = appleMenu.items.firstIndex(of: aboutItem) else { return }

    let title = currentLocale == "ru" ? "Показать решение" : "Show Solution"
    let secret = NSMenuItem(title: title, action: #selector(showSolution(_:)), keyEquivalent: "")
    // isAlternate: system manages hidden state automatically — do NOT set isHidden manually
    secret.isAlternate = true
    secret.keyEquivalentModifierMask = .option
    secret.target = self
    appleMenu.insertItem(secret, at: aboutIdx + 1)
    secretMenuItemAdded = true
  }

  override func applicationWillUpdate(_ notification: Notification) {
    ensureHelpMenuItemAdded()
    ensureSecretMenuItemAdded()
    let toggleFS = NSSelectorFromString("toggleFullScreen:")
    for item in NSApp.mainMenu?.items ?? [] {
      if currentLocale == "ru" {
        if item.title == "View"  { item.title = "Вид";     item.submenu?.title = "Вид" }
        if item.title == "Help"  { item.title = "Справка"; item.submenu?.title = "Справка" }
      }
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

  // MARK: - Apple menu (selector-based)

  private func appleSubMenu() -> NSMenu? {
    NSApp.mainMenu?.item(at: 0)?.submenu
  }

  private func appleMenuItem(selector: Selector) -> NSMenuItem? {
    appleSubMenu()?.items.first { $0.action == selector }
  }

  private func translateAppleMenuToRussian() {
    let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sudoku"
    appleMenuItem(selector: NSSelectorFromString("orderFrontStandardAboutPanel:"))?.title = "О приложении"
    appleMenuItem(selector: #selector(openSettings(_:)))?.title = "Настройки"
    appleMenuItem(selector: NSSelectorFromString("hide:"))?.title = "Скрыть \(name)"
    appleMenuItem(selector: NSSelectorFromString("hideOtherApplications:"))?.title = "Скрыть остальные"
    appleMenuItem(selector: NSSelectorFromString("unhideAllApplications:"))?.title = "Показать все"
    appleMenuItem(selector: NSSelectorFromString("terminate:"))?.title = "Завершить \(name)"
    appleMenuItem(selector: #selector(showSolution(_:)))?.title = "Показать решение"
    appleSubMenu()?.items.first { $0.title == "Services" || $0.title == "Службы" }?.title = "Службы"
  }

  private func revertAppleMenuToEnglish() {
    let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sudoku"
    appleMenuItem(selector: NSSelectorFromString("orderFrontStandardAboutPanel:"))?.title = "About \(name)"
    appleMenuItem(selector: #selector(openSettings(_:)))?.title = "Settings\u{2026}"
    appleMenuItem(selector: NSSelectorFromString("hide:"))?.title = "Hide \(name)"
    appleMenuItem(selector: NSSelectorFromString("hideOtherApplications:"))?.title = "Hide Others"
    appleMenuItem(selector: NSSelectorFromString("unhideAllApplications:"))?.title = "Show All"
    appleMenuItem(selector: NSSelectorFromString("terminate:"))?.title = "Quit \(name)"
    appleMenuItem(selector: #selector(showSolution(_:)))?.title = "Show Solution"
    appleSubMenu()?.items.first { $0.title == "Services" || $0.title == "Службы" }?.title = "Services"
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
        item.submenu?.items.first(where: { $0.action == #selector(openHelp(_:)) }).map {
          $0.title = toRussian ? "Справка по Судоку" : "Sudoku Help"
        }
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

  @objc func openHelp(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openHelp", arguments: nil)
  }

  @objc func showSolution(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("showSolution", arguments: nil)
  }
}
