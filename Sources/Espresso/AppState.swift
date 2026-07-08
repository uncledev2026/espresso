import Foundation

@MainActor
final class AppState {
    private enum DefaultsKey {
        static let caffeineEnabled = "caffeineEnabled"
    }

    private let caffeineController = CaffeineController()
    private let defaults: UserDefaults

    private(set) var isCaffeineEnabled = false
    private(set) var isLaunchAtLoginEnabled = false
    private(set) var message: String?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        refreshLaunchAtLoginStatus()

        if defaults.bool(forKey: DefaultsKey.caffeineEnabled) {
            setCaffeineEnabled(true, persist: false)
        }
    }

    func toggleCaffeine() {
        setCaffeineEnabled(!isCaffeineEnabled)
    }

    func setCaffeineEnabled(_ enabled: Bool, persist: Bool = true) {
        do {
            try caffeineController.setEnabled(enabled)
            isCaffeineEnabled = enabled
            if persist {
                defaults.set(enabled, forKey: DefaultsKey.caffeineEnabled)
            }
            message = nil
        } catch {
            isCaffeineEnabled = caffeineController.isEnabled
            message = error.localizedDescription
        }
    }

    func toggleLaunchAtLogin() {
        setLaunchAtLoginEnabled(!isLaunchAtLoginEnabled)
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            try LoginItemController.setEnabled(enabled)
            refreshLaunchAtLoginStatus()

            if LoginItemController.status == .requiresApproval {
                message = L10n.string("message.approveLaunchAtLogin")
            } else {
                message = nil
            }
        } catch {
            refreshLaunchAtLoginStatus()
            message = error.localizedDescription
        }
    }

    func refreshLaunchAtLoginStatus() {
        isLaunchAtLoginEnabled = LoginItemController.status == .enabled
    }

    func shutdown() {
        setCaffeineEnabled(false, persist: false)
    }
}
