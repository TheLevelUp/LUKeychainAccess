//
//  LUKeychainServicesProtocol.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation

protocol LUKeychainServicesProtocol: NSObject {
  var accessGroup: String? { get set }
  var accessibilityState: LUKeychainAccessibility { get set }
  var additionalQueryParams: [String: Any]? { get set }
  var service: String? { get set }
  
  // MARK: - Public Read Write Functions
  @discardableResult
  func add(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool
  
  func data(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Data?
  
  @discardableResult
  func deleteAllItems(error: UnsafeMutablePointer<NSError?>?) -> Bool
  
  @discardableResult
  func deleteItem(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool
  
  @discardableResult
  func update(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool
}
