//
//  LUKeychainAccessError.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

@objc(LUKeychainAccessError)
enum LUKeychainAccessErrorCode: Int {
  case LUKeychainAccessInvalidArchiveError
}

enum LUKeychainAccessError: Error {
  case invalidArchiveError
  case invalidType
  case encodingFailed
  case decodingFailed
}
