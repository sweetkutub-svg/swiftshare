import Cocoa
import FlutterMacOS
import receive_sharing_intent

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    override func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            ReceiveSharingIntentPlugin.instance.receive(url.absoluteString)
        }
    }

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Keep app running in background for incoming transfers
    }
}
