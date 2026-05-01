import Cocoa
import FlutterMacOS

private class AppleMenuDelegate: NSObject, NSMenuDelegate {
  private let showSolutionSel = NSSelectorFromString("showSolution:")

  func menuWillOpen(_ menu: NSMenu) {
    for item in menu.items.reversed()
      where item.isAlternate && item.action != showSolutionSel {
      menu.removeItem(item)
    }
  }
}

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
  private let appleMenuDelegate = AppleMenuDelegate()
  private let viewMenuTranslator = ViewMenuTranslator()
  private var helpMenuItemAdded = false
  private var secretMenuItemAdded = false
  private var editMenuItemsAdded = false
  private var quitActionReplaced = false
  private(set) var pendingFileData: FlutterStandardTypedData?

  func consumePendingFile() -> FlutterStandardTypedData? {
    defer { pendingFileData = nil }
    return pendingFileData
  }

  override func application(_ application: NSApplication, open urls: [URL]) {
    guard let url = urls.first, url.pathExtension == "sudoku" else { return }
    guard let data = try? Data(contentsOf: url) else { return }
    let typed = FlutterStandardTypedData(bytes: data)
    if let ch = MainFlutterWindow.menuChannel {
      ch.invokeMethod("openGameFile", arguments: typed)
    } else {
      pendingFileData = typed
    }
  }

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
    NSApp.mainMenu?.item(at: 0)?.submenu?.delegate = appleMenuDelegate
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
    guard let appleMenu = NSApp.mainMenu?.item(at: 0)?.submenu else { return }
    let showSel = #selector(showSolution(_:))
    if appleMenu.items.contains(where: { $0.action == showSel }) {
      secretMenuItemAdded = true
      return
    }
    // Flutter replaces the standard About item's action with openAbout:
    let aboutSel = #selector(openAbout(_:))
    guard let aboutItem = appleMenu.items.first(where: { $0.action == aboutSel }),
          let aboutIdx = appleMenu.items.firstIndex(of: aboutItem) else { return }
    let title = currentLocale == "ru" ? "Показать решение" : "Show Solution"
    let secret = NSMenuItem(title: title, action: showSel, keyEquivalent: "")
    secret.isAlternate = true
    secret.keyEquivalentModifierMask = .option
    secret.target = self
    appleMenu.insertItem(secret, at: aboutIdx + 1)
    secretMenuItemAdded = true
  }

  private func ensureEditMenuItemsAdded() {
    guard !editMenuItemsAdded else { return }
    let importSel = #selector(importGame(_:))
    // Find existing Edit menu or create one after the Apple menu.
    let editMenu: NSMenu
    if let existing = NSApp.mainMenu?.items.first(where: {
      $0.title == "Edit" || $0.title == "Правка"
    })?.submenu {
      editMenu = existing
    } else {
      let title = currentLocale == "ru" ? "Правка" : "Edit"
      editMenu = NSMenu(title: title)
      let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
      item.submenu = editMenu
      NSApp.mainMenu?.insertItem(item, at: 1)
    }
    guard !editMenu.items.contains(where: { $0.action == importSel }) else {
      editMenuItemsAdded = true; return
    }
    let isRu = currentLocale == "ru"
    let openItem = NSMenuItem(
      title: isRu ? "Открыть игру" : "Open Game",
      action: importSel, keyEquivalent: "o")
    openItem.keyEquivalentModifierMask = .command
    openItem.target = self
    let exportItem = NSMenuItem(
      title: isRu ? "Экспортировать" : "Export Game",
      action: #selector(exportGame(_:)), keyEquivalent: "e")
    exportItem.keyEquivalentModifierMask = .command
    exportItem.target = self
    editMenu.insertItem(openItem,   at: 0)
    editMenu.insertItem(exportItem, at: 1)
    if editMenu.items.count > 2 { editMenu.insertItem(.separator(), at: 2) }
    editMenuItemsAdded = true
  }

  override func applicationWillUpdate(_ notification: Notification) {
    ensureHelpMenuItemAdded()
    ensureSecretMenuItemAdded()
    ensureEditMenuItemsAdded()
    ensureQuitActionReplaced()
    let toggleFS = NSSelectorFromString("toggleFullScreen:")
    let importSel = #selector(importGame(_:))
    let exportSel = #selector(exportGame(_:))
    for item in NSApp.mainMenu?.items ?? [] {
      if currentLocale == "ru" {
        if item.title == "View"  { item.title = "Вид";     item.submenu?.title = "Вид" }
        if item.title == "Help"  { item.title = "Справка"; item.submenu?.title = "Справка" }
        if item.title == "Edit"  { item.title = "Правка";  item.submenu?.title = "Правка" }
      } else {
        if item.title == "Правка" { item.title = "Edit"; item.submenu?.title = "Edit" }
      }
      if let sub = item.submenu {
        sub.items.first(where: { $0.action == importSel })?.title =
          currentLocale == "ru" ? "Открыть игру" : "Open Game"
        sub.items.first(where: { $0.action == exportSel })?.title =
          currentLocale == "ru" ? "Экспортировать" : "Export Game"
        if sub.items.contains(where: { $0.action == toggleFS }),
           !(sub.delegate === viewMenuTranslator) {
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
    appleMenuItem(selector: #selector(openAbout(_:)))?.title = "О приложении"
    appleMenuItem(selector: #selector(openSettings(_:)))?.title = "Настройки"
    appleMenuItem(selector: NSSelectorFromString("hide:"))?.title = "Скрыть \(name)"
    appleMenuItem(selector: NSSelectorFromString("hideOtherApplications:"))?.title = "Скрыть остальные"
    appleMenuItem(selector: NSSelectorFromString("unhideAllApplications:"))?.title = "Показать все"
    appleMenuItem(selector: #selector(quitApp(_:)))?.title = "Завершить \(name)"
    appleMenuItem(selector: #selector(showSolution(_:)))?.title = "Показать решение"
    appleSubMenu()?.items.first { $0.title == "Services" || $0.title == "Службы" }?.title = "Службы"
  }

  private func revertAppleMenuToEnglish() {
    let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Sudoku"
    appleMenuItem(selector: #selector(openAbout(_:)))?.title = "About \(name)"
    appleMenuItem(selector: #selector(openSettings(_:)))?.title = "Settings\u{2026}"
    appleMenuItem(selector: NSSelectorFromString("hide:"))?.title = "Hide \(name)"
    appleMenuItem(selector: NSSelectorFromString("hideOtherApplications:"))?.title = "Hide Others"
    appleMenuItem(selector: NSSelectorFromString("unhideAllApplications:"))?.title = "Show All"
    appleMenuItem(selector: #selector(quitApp(_:)))?.title = "Quit \(name)"
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

  private func ensureQuitActionReplaced() {
    guard !quitActionReplaced else { return }
    guard let appleMenu = NSApp.mainMenu?.item(at: 0)?.submenu else { return }
    let terminateSel = NSSelectorFromString("terminate:")
    guard let quitItem = appleMenu.items.first(where: { $0.action == terminateSel }) else { return }
    quitItem.action = #selector(quitApp(_:))
    quitItem.target = self
    quitActionReplaced = true
  }

  @objc func quitApp(_ sender: Any?) {
    NSApp.terminate(sender)
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

  @objc func importGame(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("importGame", arguments: nil)
  }

  @objc func exportGame(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("exportGame", arguments: nil)
  }
}
