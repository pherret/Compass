import UIKit

extension Compass {

  public static func navigate(_ urn: String, scheme: String = Compass.scheme) {
    guard let url = URL(string: "\(scheme)\(urn)") else { return }

    UIApplication.shared.openURL(url)
  }
}
