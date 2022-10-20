//
//  LUKeychainErrorHandler.swift
//  LUKeychainAccess
//
//  Copyright © 2022 Grubhub. All rights reserved.
//

import Foundation

@objc public protocol LUKeychainErrorHandler: NSObjectProtocol {
  @objc (keychainAccess:receivedError:)
  func keychainAccess(_ keychainAccess: LUKeychainAccess, received error:Error)
}
