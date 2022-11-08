//
//  LUKeychainAccess.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import ObjectiveC
import Foundation

public let LUKeychainAccessVersionNumber = 0.0
public let LUKeychainAccessVersionString = ""

@objc public class LUKeychainAccess: NSObject {

  // MARK: - Instance Access
  @objc
  public class var standardKeychainAccess: LUKeychainAccess {
    return LUKeychainAccess()
  }

  // MARK: - Public Static Properties
  @objc
  public static let errorDomain = "LUKeychainAccessErrorDomain"

  // MARK: - Public Settable Properties
  @objc public var errorHandler: LUKeychainErrorHandler?

  // MARK: - Public Computed Properties
  @objc
  public var accessGroup: String? { return services.accessGroup }
  @objc
  public var accessibilityState: LUKeychainAccessibility { return services.accessibilityState }
  @objc
  public var additionalQueryParams: [String: Any]? { services.additionalQueryParams }
  @objc
  public var service: String? { return services.service }

  // MARK: - Private Properties
  internal var services: LUKeychainServicesProtocol = LUKeychainServices.keychainServices

  // MARK: - Public Delete Functions
  @objc @discardableResult
  public func deleteAll() -> Bool {
    var error: NSError?
    guard services.deleteAllItems(error: &error) else {
      handle(error: error)
      return false
    }

    return true
  }

  @objc (deleteObjectForKey:)
  public func deleteObject(for key: String) {
    var error: NSError?
    if !services.deleteItem(for: key, error: &error) {
      handle(error: error)
    }
  }

  // MARK: - Public Config Functions
  @objc (setAccessGroup:)
  public func set(accessGroup: String) {
    services.accessGroup = accessGroup
  }

  @objc (setAccessibilityState:)
  public func set(accessibilityState: LUKeychainAccessibility) {
    services.accessibilityState = accessibilityState
  }

  @objc (setAdditionalQueryParams:)
  public func set(additionalQueryParams: [String: Any]) {
    services.additionalQueryParams = additionalQueryParams
  }

  // MARK: - Public Set Functions

  @objc (registerDefaults:) @discardableResult
  public func register(defaults: [String: Any]) -> Bool {
    for (key, value) in defaults {
      guard let type = value.self as? AnyClass else {
        handle(error: LUKeychainAccessError.invalidType)
        return false
      }

      if recursivelyFindObject(for: key, from: type) == nil && string(for: key) == nil {
        if let stringValue = value as? String {
          return set(string: stringValue, for: key)
        } else if let object = value as Any? {
          return set(object: object, for: key)
        } else {
          handle(error: LUKeychainAccessError.invalidType)
          return false
        }
      }
    }

    return false
  }

  @objc (setBool:forKey:) @discardableResult
  public func set(bool: Bool, for key: String) -> Bool {
    return set(object: NSNumber(value: bool), for: key)
  }

  @objc (setData:forKey:) @discardableResult
  public func set(data: Data?, for key: String) -> Bool {
    guard let data = data else {
      deleteObject(for: key)
      return true
    }

    var error: NSError?
    var success = services.add(data, for: key, error: &error)

    if !success {
      if let nSError = error, nSError.code == errSecDuplicateItem {
        error = nil
        success = services.update(data, for: key, error: &error)
      }

      handle(error: error)
      return false
    }

    return true
  }

  @objc (setDouble:forKey:) @discardableResult
  public func set(double: Double, for key: String) -> Bool {
    return set(object: NSNumber(value: double), for: key)
  }

  @objc (setFloat:forKey:) @discardableResult
  public func set(float: Float, for key: String) -> Bool {
    return set(object: NSNumber(value: float), for: key)
  }

  @objc (setInteger:forKey:) @discardableResult
  public func set(integer: Int, for key: String) -> Bool {
    return set(object: NSNumber(integerLiteral: integer), for: key)
  }

  @objc (setString:forKey:) @discardableResult
  public func set(string: String, for key: String) -> Bool {
    guard let data = string.data(using: String.Encoding.utf8) else {
      handle(error: LUKeychainAccessError.encodingFailed)
      return false
    }
    return set(data: data, for: key)
  }

  @objc (setObject:forKey:) @discardableResult
  public func set(object: Any, for key: String) -> Bool {
    do {
      if let data: Data = try NSKeyedArchiver.archivedData(with: object) {
        return self.set(data: data, for: key)
      }
    } catch let error {
      handle(error: error)
    }
    return false
  }

  // MARK: - Public Get Functions
  @objc (boolForKey:) @discardableResult
  public func bool(for key: String) -> Bool {
    return ((try? number(for: key).boolValue) != nil)
  }

  @objc (dataForKey:) @discardableResult
  public func data(for key: String) -> Data? {
    var error: NSError?
    guard let data = services.data(for: key, error: &error) else {
      handle(error: error)
      return nil
    }

    return data
  }

  @objc (doubleForKey:)
  public func double(for key: String) -> Double {
    let number = try? number(for: key)
    return (number ?? 0).doubleValue
  }

  @objc (floatForKey:)
  public func float(for key: String) -> Float {
    let number = try? number(for: key)
    return (number ?? 0).floatValue
  }

  @objc (integerForKey:)
  public func integer(for key: String) -> Int {
    let number = try? number(for: key)
    return (number ?? 0).intValue
  }

  @objc (stringForKey:)
  public func string(for key: String) -> String? {
    guard let data = data(for: key) else {
      return nil
    }

    return String(data: data, encoding: String.Encoding.utf8)
  }

  @objc (objectForKey:ofClass:)
  public func object(for key: String, ofClass aClass: AnyClass) -> Any? {
    return object(for: key, ofClasses: [aClass])
  }

  @objc (objectForKey:ofClasses:)
  public func object(for key: String, ofClasses classes: [AnyClass]) -> Any? {
    guard let data = data(for: key) else { return nil }

    guard let object = NSKeyedUnarchiver.lu_unarchiveObject(ofClasses: classes, with: data) else {
      let message = "Error while calling objectForKey: with key \(key)"
      let error = NSError(domain: LUKeychainAccess.errorDomain,
                          code: LUKeychainAccessErrorCode.LUKeychainAccessInvalidArchiveError.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
      handle(error: error)
      return nil
    }

    return object
  }

  @objc (recursivelyFindObjectForKey:fromClass:)
  public func recursivelyFindObject(for key: String, from aClass: AnyClass) -> Any? {
    if let result = object(for: key, ofClass: aClass) {
      return result
    }

    if let aSuperclass = class_getSuperclass(aClass),
       aClass != NSObject.self {
      return recursivelyFindObject(for: key, from: aSuperclass)
    }

    return nil
  }

  // MARK: - Private Functions
  private func handle(error: Error?) {
    guard let error = error else { return }
    if errorHandler != nil {
      errorHandler?.keychainAccess(self, received: error)
    }
  }

  private func number(for key: String) throws -> NSNumber {
    guard let object = object(for: key, ofClass: NSNumber.self) else {
     throw LUKeychainUnarchiveError.objectNotFound(key: key)
    }
    
    guard let number = object as? NSNumber else {
      throw LUKeychainUnarchiveError.unexpectedType(object: object, key: key, expectedType: NSNumber.self)
    }

    return number
  }
}
