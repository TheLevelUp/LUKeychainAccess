//
//  NSKeyedArchiver.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

extension NSKeyedArchiver {
  @objc (lu_archivedDataWithRootObject:)
  class func lu_archivedData(with object: Any?) -> Data? {
    guard let object = object else { return nil }

    do {
      return try archivedData(withRootObject: object, requiringSecureCoding: false)
    } catch let error {
      assertionFailure("Failure archiving data withRootObject \(object) with error \(error)")
    }

    return nil
  }
}
