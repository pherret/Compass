import Foundation

public struct Compass {

  typealias Result = (
    route: String,
    arguments: [String: String],
    concreteMatchCount: Int,
    wildcardMatchCount: Int)

  private static var internalScheme = ""
  public static var delimiter: String = ":"

  public static var scheme: String {
    set { Compass.internalScheme = newValue }
    get { return "\(Compass.internalScheme)://" }
  }

  public static var routes = [String]()

  public static func parse(url: NSURL, payload: Any? = nil) -> Location? {
    guard let absoluteUrl = optionalize(url.absoluteString) else {
      return nil
    }

    let path = absoluteUrl.substringFromIndex(scheme.endIndex)

    guard !(path.containsString("?") || path.containsString("#")) else {
      return parseAsURL(url, payload: payload)
    }

    let results: [Result] = routes.flatMap {
      return findMatch($0, pathString: path)
      }.sort { (r1: Result, r2: Result) in
        if r1.concreteMatchCount == r2.concreteMatchCount {
          return r1.wildcardMatchCount > r2.wildcardMatchCount
        }

        return r1.concreteMatchCount > r2.concreteMatchCount
    }

    if let result = results.first {
      return Location(path: result.route, arguments: result.arguments, payload: payload)
    }

    return nil
  }

  static func parseAsURL(url: NSURL, payload: Any? = nil) -> Location? {
    guard let route = url.host else { return nil }

    let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
    var arguments = [String : String]()

    urlComponents?.queryItems?.forEach { queryItem in
      arguments[queryItem.name] = queryItem.value
    }

    if let fragment = urlComponents?.fragment {
      arguments = fragment.queryParameters()
    }

    return Location(path: route, arguments: arguments, payload: payload)
  }

  static func findMatch(routeString: String, pathString: String) -> Result? {
    let routes = routeString.split(delimiter)
    let paths = pathString.split(delimiter)

    guard routes.count == paths.count else { return nil }

    var arguments: [String: String] = [:]
    var concreteMatchCount = 0
    var wildcardMatchCount = 0

    for (route, path) in zip(routes, paths) {
      if route.hasPrefix("{") {
        let key = route.replace("{", with: "").replace("}", with: "")
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

    return (route: routeString,
            arguments: arguments,
            concreteMatchCount: concreteMatchCount,
            wildcardMatchCount: wildcardMatchCount)
  }
}

extension Compass {

  public static func navigate(urn: String, scheme: String = Compass.scheme) {
    guard let url = NSURL(string: "\(scheme)\(urn)") else { return }
    openURL(url)
  }
}
