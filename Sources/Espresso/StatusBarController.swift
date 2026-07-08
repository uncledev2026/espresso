import AppKit

@MainActor
final class StatusBarController: NSObject {
    private let appState: AppState
    private let statusItem: NSStatusItem
    private let menu = NSMenu()

    private let statusMenuItem = NSMenuItem()
    private let toggleCaffeineMenuItem = NSMenuItem()
    private let launchAtLoginMenuItem = NSMenuItem()
    private let messageSeparatorMenuItem = NSMenuItem.separator()
    private let messageMenuItem = NSMenuItem()

    init(appState: AppState) {
        self.appState = appState
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
        configureMenu()
        refresh()
    }

    private func configureStatusItem() {
        statusItem.isVisible = true
        statusItem.length = NSStatusItem.squareLength
        statusItem.button?.toolTip = L10n.string("app.name")
        statusItem.button?.imagePosition = .imageOnly
        statusItem.menu = menu
    }

    private func configureMenu() {
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        toggleCaffeineMenuItem.target = self
        toggleCaffeineMenuItem.action = #selector(toggleCaffeine)
        toggleCaffeineMenuItem.keyEquivalent = "j"
        menu.addItem(toggleCaffeineMenuItem)

        menu.addItem(.separator())

        launchAtLoginMenuItem.target = self
        launchAtLoginMenuItem.action = #selector(toggleLaunchAtLogin)
        menu.addItem(launchAtLoginMenuItem)

        messageMenuItem.isEnabled = false
        menu.addItem(messageSeparatorMenuItem)
        menu.addItem(messageMenuItem)

        menu.addItem(.separator())

        let quitMenuItem = NSMenuItem(
            title: L10n.string("menu.quit"),
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
    }

    @objc private func toggleCaffeine() {
        appState.toggleCaffeine()
        refresh()
    }

    @objc private func toggleLaunchAtLogin() {
        appState.toggleLaunchAtLogin()
        refresh()
    }

    @objc private func quit() {
        appState.shutdown()
        NSApp.terminate(nil)
    }

    private func refresh() {
        appState.refreshLaunchAtLoginStatus()

        statusMenuItem.title = appState.isCaffeineEnabled
            ? L10n.string("menu.status.enabled")
            : L10n.string("menu.status.disabled")
        toggleCaffeineMenuItem.title = appState.isCaffeineEnabled
            ? L10n.string("menu.action.disable")
            : L10n.string("menu.action.enable")
        toggleCaffeineMenuItem.state = appState.isCaffeineEnabled ? .on : .off
        launchAtLoginMenuItem.title = L10n.string("menu.launchAtLogin")
        launchAtLoginMenuItem.state = appState.isLaunchAtLoginEnabled ? .on : .off

        if let message = appState.message {
            messageSeparatorMenuItem.isHidden = false
            messageMenuItem.title = message
            messageMenuItem.isHidden = false
        } else {
            messageSeparatorMenuItem.isHidden = true
            messageMenuItem.title = ""
            messageMenuItem.isHidden = true
        }

        refreshIcon()
    }

    private func refreshIcon() {
        guard let button = statusItem.button else {
            return
        }

        button.image = MenuBarIcon.makeImage(isEnabled: appState.isCaffeineEnabled)
        button.title = ""
    }
}
