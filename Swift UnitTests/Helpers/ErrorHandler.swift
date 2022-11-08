//
//  ErrorHandler.swift
//  Swift UnitTests
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation
import LUKeychainAccess

internal class ErrorHandler: NSObject {
  var lastError: Error?
}

extension ErrorHandler: LUKeychainErrorHandler {
  func keychainAccess(_ keychainAccess: LUKeychainAccess, received error: Error) {
    lastError = error
  }
}
