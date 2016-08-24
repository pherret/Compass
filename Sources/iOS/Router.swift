import UIKit

public struct Router {

  public var routes = [String: Routable]()

  public init() {}

  public func navigate(_ route: String, arguments: [String: String], fragments: [String : AnyObject] = [:], from controller: UIViewController) {
    guard let route = routes[route] else { return }

    route.resolve(arguments, fragments: fragments, currentController: controller)
  }
}
