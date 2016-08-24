import Foundation
import Sugar

public struct Compass {

  typealias Result = (route: String, arguments: [String: String],
    concreteMatchCount: Int, wildcardMatchCount: Int)

  fileprivate static var internalScheme = ""

  public static var delimiter: String = ":"

  public static var scheme: String {
    set { Compass.internalScheme = newValue }
    get { return "\(Compass.internalScheme)://" }
  }

  public static var routes = [String]()

  public typealias ParseCompletion = (_ route: String, _ arguments: [String : String], _ fragments: [String : AnyObject]) -> Void
  
  @discardableResult
  public static func parse(_ url: URL, fragments: [String : AnyObject] = [:], completion: ParseCompletion) -> Bool {

    let path = url.absoluteString.substring(from: scheme.endIndex)

    guard !(path.contains("?") || path.contains("#"))
      else { return parseAsURL(url, completion: completion) }

    let results: [Result] = routes.flatMap {
      return findMatch($0, pathString: path)
    }.sorted { (r1: Result, r2: Result) in
      if r1.concreteMatchCount == r2.concreteMatchCount {
        return r1.wildcardMatchCount > r2.wildcardMatchCount
      }

      return r1.concreteMatchCount > r2.concreteMatchCount
    }

    if let result = results.first {
      completion(result.route, result.arguments, fragments)
      return true
    }

    return false
  }

  static func parseAsURL(_ url: URL, completion: ParseCompletion) -> Bool {
    guard let route = url.host else { return false }

    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)

    var arguments = [String : String]()

    urlComponents?.queryItems?.forEach { queryItem in
        arguments[queryItem.name] = queryItem.value
    }

    if let fragment = urlComponents?.fragment {
        arguments = fragment.queryParameters()
    }

    completion(route, arguments, [:])

    return true
  }

  static func findMatch(_ routeString: String, pathString: String)
    -> Result? {

    let routes = routeString.split(delimiter)
    let paths = pathString.split(delimiter)

    guard routes.count == paths.count else { return nil }

    var arguments: [String: String] = [:]
    var concreteMatchCount = 0
    var wildcardMatchCount = 0

    for (route, path) in zip(routes, paths) {
      if route.hasPrefix("{") {
        let key = route.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
        arguments[key] = path

        wildcardMatchCount += 1
        continue
      }

      if route == path {
        concreteMatchCount += 1
      } else {
        return nil
      }
    }

    return (route: routeString, arguments: arguments,
            concreteMatchCount: concreteMatchCount, wildcardMatchCount: wildcardMatchCount)
  }
}

private extension String {

    func queryParameters() -> [String: String] {
        var parameters = [String: String]()

        let separatorCharacters = CharacterSet(charactersIn: "&;")
        self.components(separatedBy: separatorCharacters).forEach { (pair) in

            if let equalSeparator = pair.range(of: "=") {
                let name = pair.substring(to: equalSeparator.lowerBound)
                let value = pair.substring(from: equalSeparator.upperBound)
                let cleaned = value.removingPercentEncoding ?? value
                
                parameters[name] = cleaned
            }
        }

        return parameters
    }

}
