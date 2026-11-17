import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Finestra di partenza da tablet orizzontale; sotto il minimo le card
    // della modalità bambino non stanno più in pagina.
    self.setContentSize(NSSize(width: 1100, height: 780))
    self.contentMinSize = NSSize(width: 480, height: 640)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
