//
//  LUKeychainUnarchiveError.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

public enum LUKeychainUnarchiveError: Error {
  case objectNotFound(key: AnyHashable)
  case unexpectedType(object: Any, key: AnyHashable, expectedType: Any.Type)

}
