#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

#if os(OSX)
  public typealias Controller = NSViewController

  func openURL(_ URL: Foundation.URL) {
    NSWorkspace.shared().open(URL)
  }
#else
  public typealias Controller = UIViewController

  func openURL(_ URL: Foundation.URL) {
    UIApplication.shared.openURL(URL)
  }
#endif
