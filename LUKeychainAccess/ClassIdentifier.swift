//
//  AnyClassExtension.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

// THIS WILL BE REMOVED, UNLESS SWIFT SPECIFIC (@nonobjc) functions will be added

import Foundation

// Adopted by Any.Type vs. AnyObject to support Swift struct types
protocol ClassIdentifier {}

extension ClassIdentifier {
  // Default
  static var classIdentifier: ObjectIdentifier {
    return ObjectIdentifier(self)
    }

  var classIdentifier: ObjectIdentifier {
    return ObjectIdentifier(Self.self)
  }

  // Init
  static func identifier(object: AnyObject?) -> ObjectIdentifier? {
    guard let object = object else { return nil }

    return ObjectIdentifier(object)
  }

  static func identifier(type: Any.Type) -> ObjectIdentifier {

    return ObjectIdentifier(type)
  }
}

// Extends for standard types but custom Swift classes that don't
// inherit from these classes must be separately declared to
// adopt ClassIdentifier.
extension NSObject: ClassIdentifier {}
extension String: ClassIdentifier {}
extension Data: ClassIdentifier {}
extension Bool: ClassIdentifier {}
