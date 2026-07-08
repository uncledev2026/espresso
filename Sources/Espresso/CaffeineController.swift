import Foundation
import IOKit.pwr_mgt

enum CaffeineControllerError: LocalizedError {
    case enableFailed(IOReturn)
    case releaseFailed(IOReturn)

    var errorDescription: String? {
        switch self {
        case .enableFailed(let code):
            return L10n.format("error.caffeine.enableFailed", Int32(code))
        case .releaseFailed(let code):
            return L10n.format("error.caffeine.releaseFailed", Int32(code))
        }
    }
}

final class CaffeineController {
    private var assertionID = IOPMAssertionID(0)
    private let assertionName = "espresso is enabled" as CFString

    private(set) var isEnabled = false

    deinit {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try enable()
        } else {
            try disable()
        }
    }

    private func enable() throws {
        guard !isEnabled else {
            return
        }

        var newAssertionID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            assertionName,
            &newAssertionID
        )

        guard result == kIOReturnSuccess else {
            throw CaffeineControllerError.enableFailed(result)
        }

        assertionID = newAssertionID
        isEnabled = true
    }

    private func disable() throws {
        guard isEnabled else {
            return
        }

        let result = IOPMAssertionRelease(assertionID)
        assertionID = 0
        isEnabled = false

        guard result == kIOReturnSuccess else {
            throw CaffeineControllerError.releaseFailed(result)
        }
    }
}
