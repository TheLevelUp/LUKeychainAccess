//
//  LUKeychainArchiveError.swift
//  LUKeychainAccess
//
//  Copyright © 2022 Grubhub. All rights reserved.
//

import Foundation

public enum LUKeychainArchiveError: Error {
  case unexpectedType(object: Any, key: AnyHashable, expectedType: Any.Type)
}
