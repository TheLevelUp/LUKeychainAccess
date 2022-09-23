//
//  NSKeyedArchiver.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

@objc public extension NSKeyedArchiver {
  @objc class func lu_archivedData(with object: AnyObject?) -> Data? {
    guard let object = object else { return nil }

    if let data = try? archivedData(withRootObject: object, requiringSecureCoding: false) {
      return data
    }
    
    return nil
  }
}
