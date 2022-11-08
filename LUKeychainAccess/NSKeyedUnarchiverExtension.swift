//
//  NSKeyedUnarchiverExtension.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

extension NSKeyedUnarchiver {
  @objc
  class func lu_unarchiveObject(ofClasses classes: [AnyClass], with data: Data) -> Any? {
    let baseClasses = [NSString.self, NSDictionary.self, NSArray.self, NSNumber.self]
    
    return try? unarchivedObject(ofClasses: baseClasses + classes,
                                 from: data)
  }
  
  @nonobjc
  class func unarchiveObject(ofClasses classes: [AnyClass], with data: Data) throws -> Any? {
    let baseClasses = [NSString.self, NSDictionary.self, NSArray.self, NSNumber.self]
    do {
      return try unarchivedObject(ofClasses: baseClasses + classes,
                                  from: data)
    } catch let error {
      throw error
    }
  }
}
