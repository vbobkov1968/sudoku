import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    localizeMenuForRussian()
  }

  func localizeMenuForRussian() {
    // shared_preferences stores values with "flutter." prefix in UserDefaults.
    let lang = UserDefaults.standard.string(forKey: "flutter.settings_locale")
            ?? Locale.current.languageCode
            ?? "en"
    guard lang == "ru" else { return }
    guard let appMenu = NSApp.mainMenu?.item(at: 0)?.submenu else { return }
    let items = appMenu.items
    // 0: About, 1: sep, 2: Preferences, 3: sep, 4: Services,
    // 5: sep, 6: Hide, 7: Hide Others, 8: Show All, 9: sep, 10: Quit
    if items.indices.contains(0)  { items[0].title  = "О приложении" }
    if items.indices.contains(2)  { items[2].title  = "Настройки" }
    if items.indices.contains(4)  { items[4].title  = "Службы" }
    if items.indices.contains(6)  { items[6].title  = "Скрыть" }
    if items.indices.contains(7)  { items[7].title  = "Скрыть остальные" }
    if items.indices.contains(8)  { items[8].title  = "Показать все" }
    if items.indices.contains(10) { items[10].title = "Завершить" }
    NSApp.mainMenu?.item(at: 1)?.title = "Вид"
    NSApp.mainMenu?.item(at: 1)?.submenu?.item(at: 0)?.title = "На весь экран"
    NSApp.mainMenu?.item(at: 2)?.title = "Справка"
  }

  @IBAction func openSettings(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openSettings", arguments: nil)
  }

  @IBAction func openAbout(_ sender: Any) {
    MainFlutterWindow.menuChannel?.invokeMethod("openAbout", arguments: nil)
  }
}
