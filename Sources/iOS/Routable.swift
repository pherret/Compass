import UIKit

public protocol Routable {

  func resolve(_ arguments: [String: String], fragments: [String : AnyObject], currentController: UIViewController)
}
