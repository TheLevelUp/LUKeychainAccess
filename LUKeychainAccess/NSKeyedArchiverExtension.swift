//
//  NSKeyedArchiver.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

@objc public extension NSKeyedArchiver {
  @objc (lu_archivedDataWithRootObject:)
  class func lu_archivedData(with object: Any?) -> Data? {
    guard let object = object else { return nil }

    if let data = try? archivedData(withRootObject: object, requiringSecureCoding: false) {
      return data
    }
    
    return nil
  }
}
