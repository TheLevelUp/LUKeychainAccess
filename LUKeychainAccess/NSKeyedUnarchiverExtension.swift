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
  class func lu_unarchiveObject(ofClasses classes: Set<AnyHashable>, with data: Data) -> Any? {
      var baseClasses = NSSet(objects: NSString.self, NSDictionary.self, NSArray.self, NSNumber.self) as! Set<AnyHashable>
      baseClasses.formUnion(classes)
      
      if let result = try? unarchivedObject(ofClasses: baseClasses, from: data) {
        return result
      } else {
        assertionFailure("NSKeyedUnarchiver encountered an error")
        return nil
      }
  }
  
  @objc
  class func lu_archiveObject(of aClass: AnyHashable, with data: Data)  -> Any? {
    let set: Set = [aClass]
      return lu_unarchiveObject(ofClasses: set, with: data)
  }
}
