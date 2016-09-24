import Foundation
@testable import Compass

// MARK: - Routes

class TestRoute: Routable {

  var resolved = false

  func navigate(to location: Location, from currentController: Controller) throws {
    resolved = true
  }
}

class ThrowableRoute: Routable {

  enum CompassError: Error {
    case unknown
  }

  func navigate(to location: Location, from currentController: Controller) throws {
    throw CompassError.unknown
  }
}

class ErrorRoute: ErrorRoutable {

  var error: Error?

  func handle(_ routeError: Error, from currentController: Controller) {
    error = routeError
  }
}

// MARK: - Shuffle

extension Collection {
  /// Return a copy of `self` with its elements shuffled
  func shuffle() -> [Iterator.Element] {
    var list = Array(self)
    list.shuffleInPlace()
    return list
  }
}

extension MutableCollection where Index == Int {
  /// Shuffle the elements of `self` in-place.
  mutating func shuffleInPlace() {
    // empty and single-element collections don't shuffle
    if count < 2 { return }

    // for i in 0..<count.toIntMax() - 1 {
    for i in startIndex..<endIndex {
      let j = Int(arc4random_uniform(UInt32(count.toIntMax() - i))) + i
      guard i != j else { continue }
      (self[i], self[j]) = (self[j], self[i])
      // instead of swap(&self[i], &self[j])
    }
  }
}
