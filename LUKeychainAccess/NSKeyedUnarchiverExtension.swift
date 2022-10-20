//
//  NSKeyedUnarchiverExtension.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

@objc public extension NSKeyedUnarchiver {
  // Not sure the type specifier as AnyClasses does not conform to hashable
  @objc
  class func lu_unarchiveObject(ofClasses classes: Dictionary<String, AnyClass>, with data: Data) -> Any? {
    var baseClasses: [String: AnyClass] = [String(describing: type(of: NSString.self)): NSString.self,
                                           String(describing: type(of: NSDictionary.self)): NSDictionary.self,
                                           String(describing: type(of: NSArray.self)): NSArray.self,
                                           String(describing: type(of: NSNumber.self)): NSNumber.self]

    classes.forEach { (key, value) in
      baseClasses[key] = value
    }

    if let result = try? unarchivedObject(ofClasses: Array(baseClasses.values), from: data) {
      return result
    } else {
      assertionFailure("NSKeyedUnarchiver encountered an error")
      return nil
    }
  }
  
  @objc
  class func lu_archiveObject(of aClass: Dictionary<String, AnyClass>, with data: Data)  -> Any? {
    return lu_unarchiveObject(ofClasses: aClass, with: data)
  }
}
