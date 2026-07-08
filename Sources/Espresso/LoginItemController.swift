import Foundation
import ServiceManagement

enum LoginItemStatus {
    case disabled
    case enabled
    case requiresApproval
    case unavailable
}

enum LoginItemControllerError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return L10n.string("error.loginItem.unavailable")
        }
    }
}

enum LoginItemController {
    static var status: LoginItemStatus {
        guard #available(macOS 13.0, *) else {
            return .unavailable
        }

        switch SMAppService.mainApp.status {
        case .enabled:
            return .enabled
        case .requiresApproval:
            return .requiresApproval
        case .notFound, .notRegistered:
            return .disabled
        @unknown default:
            return .disabled
        }
    }

    static func setEnabled(_ enabled: Bool) throws {
        guard #available(macOS 13.0, *) else {
            throw LoginItemControllerError.unavailable
        }

        let service = SMAppService.mainApp

        if enabled {
            if service.status == .notRegistered || service.status == .notFound {
                try service.register()
            }
        } else {
            if service.status == .enabled || service.status == .requiresApproval {
                try service.unregister()
            }
        }
    }
}
