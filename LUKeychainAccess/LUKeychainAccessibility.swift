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
      // Now defaults to after first unlock this device only due to
      // deprecation of .always in iOS12.0
      return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    case .never:
      return nil
    case .alwaysThisDeviceOnly:
      // Now defaults to after first unlock this device only due to
      // deprecation of .alwaysThisDeviceOnly in iOS12.0
      return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    case .whenUnlocked:
      return kSecAttrAccessibleWhenUnlocked
    case .whenUnlockedThisDeviceOnly:
      return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    default:
      return kSecAttrAccessibleWhenUnlocked
    }
  }
  
}
