import Foundation

enum L10n {
    private static let languageCode: String = {
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferred.hasPrefix("ko") ? "ko" : "en"
    }()

    private static let selectedBundle: Bundle = {
        guard
            let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .main
        }

        return bundle
    }()

    private static let englishFallback = [
        "app.name": "espresso",
        "menu.status.enabled": "Status: Enabled",
        "menu.status.disabled": "Status: Disabled",
        "menu.action.enable": "Enable",
        "menu.action.disable": "Disable",
        "menu.launchAtLogin": "Launch at Login",
        "menu.quit": "Quit espresso",
        "message.approveLaunchAtLogin": "Approve launch at login in System Settings.",
        "error.caffeine.enableFailed": "Could not keep this Mac awake. IOKit returned %d.",
        "error.caffeine.releaseFailed": "Could not release the power assertion. IOKit returned %d.",
        "error.loginItem.unavailable": "Launch at login requires macOS 13 or later."
    ]

    static func string(_ key: String) -> String {
        selectedBundle.localizedString(
            forKey: key,
            value: englishFallback[key] ?? key,
            table: nil
        )
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(
            format: string(key),
            locale: Locale(identifier: languageCode),
            arguments: arguments
        )
    }
}
