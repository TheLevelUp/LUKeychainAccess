//
//  NSKeyedArchiver.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

extension NSKeyedArchiver {
  
  @objc (lu_archivedDataWithRootObject:)
  /// Archive a data object and its children.
  /// This method should only be used for Objective-C and not swift.
  /// - Parameter object: Root data object to archive
  /// - Returns: `Data` if object successfully archived, otherwise `nil`
  class func lu_archivedData(with object: Any?) -> Data? {
    guard let object = object else { return nil }

    return try? archivedData(withRootObject: object, requiringSecureCoding: false)
  }
  
  
  @nonobjc
  /// Archive a data object and its children.
  /// Throws error from NSKeyedArchiver.archivedData
  /// - Parameter object: Root data object to archive
  /// - Returns: `Data` if object successfully archived, otherwise  throws error.
  class func archivedData(with object: Any?) throws -> Data? {
    guard let object = object else { return nil }

    do {
      return try archivedData(withRootObject: object, requiringSecureCoding: false)
    } catch let error {
      throw error
    }
  }
}
