//
//  LUKeychainAccess.swift
//  LUKeychainAccessibility
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

@objc public enum LUKeychainAccessibility: Int {
  case afterFirstUnlock
  case afterFirstUnlockThisDeviceOnly
  case always
  case never
  case alwaysThisDeviceOnly
  case whenUnlocked
  case whenUnlockedThisDeviceOnly
  
  var stateCFType: CFTypeRef? {
    switch self {
    case .afterFirstUnlock:
      return kSecAttrAccessibleAfterFirstUnlock
    case .afterFirstUnlockThisDeviceOnly:
      return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    case .always:
      return kSecAttrAccessibleAlways
    case .never:
      return nil
    case .alwaysThisDeviceOnly:
      return kSecAttrAccessibleAlwaysThisDeviceOnly
    case .whenUnlocked:
      return kSecAttrAccessibleWhenUnlocked
    case .whenUnlockedThisDeviceOnly:
      return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    default:
      return kSecAttrAccessibleWhenUnlocked
    }
  }
  
}
