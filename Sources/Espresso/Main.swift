import AppKit

@MainActor
private var sharedAppDelegate: AppDelegate?

@main
enum EspressoMain {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()

        sharedAppDelegate = delegate
        application.delegate = delegate
        application.setActivationPolicy(.accessory)
        application.run()
    }
}
