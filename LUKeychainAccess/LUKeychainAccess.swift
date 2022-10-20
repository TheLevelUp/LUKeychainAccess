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
  private var services = LUKeychainServices.keychainServices
  
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
  
  @objc (registerDefaults:)
  public func register(defaults: [String: Any]) {
    for (key, value) in defaults {
      guard let classOfValue = type(of: value) as? AnyClass else {
        assertionFailure("Type \(type(of: value)) does not conform to AnyHashable")
        return
      }
      
      if recursivelyFindObject(for: key, from: classOfValue.self) == nil && string(for: key) == nil {
        if let stringValue = value as? String {
          set(string: stringValue, for: key)
        } else if let object = value as Any? {
          set(object: object, for: key)
        } else {
          assertionFailure("Unable to register as not object type")
        }
      }
    }
  }
  
  @objc (setBool:forKey:)
  public func set(bool: Bool, for key: String) {
    set(object: NSNumber(value: bool), for: key)
  }
  
  @objc (setData:forKey:)
  public func set(data: Data?, for key: String) {
    guard let data = data else {
      deleteObject(for: key)
      return
    }
    
    var error: NSError?
    var success = services.add(data, for: key, error: &error)
    
    if !success {
      if let nSError = error, nSError.code == errSecDuplicateItem {
        error = nil
        success = services.update(data, for: key, error: &error)
      }
      
      handle(error: error)
    }
  }
  
  @objc (setDouble:forKey:)
  public func set(double: Double, for key: String) {
    set(object: NSNumber(value: double), for: key)
  }
  
  @objc (setFloat:forKey:)
  public func set(float: Float, for key: String) {
    set(object: NSNumber(value: float), for: key)
  }
  
  @objc (setInteger:forKey:)
  public func set(integer: Int, for key: String) {
    set(object: NSNumber(integerLiteral: integer), for: key)
  }
  
  @objc (setString:forKey:)
  public func set(string: String, for key: String) {
    guard let data = string.data(using: String.Encoding.utf8) else {
      assertionFailure("Unable to encode string")
      return
    }
    set(data: data, for: key)
  }
  
  @objc (setObject:forKey:)
  public func set(object: Any, for key: String) {
    guard let data: Data = NSKeyedArchiver.lu_archivedData(with: object) else {
      assertionFailure("Unable to archive with root object")
      return
    }
    
    self.set(data: data, for: key)
  }
  
  // MARK: - Public Get Functions
  @objc (boolForKey:) @discardableResult
  public func bool(for key: String) -> Bool {
    return number(for: key).boolValue
  }
  
  @objc (dataForKey:) @discardableResult
  public func data(for key: String) -> Data? {
    var error: NSError?
    guard let  data = services.data(for: key, error: &error) else {
      handle(error: error)
      return nil
    }
    
    return data
  }
  
  @objc (doubleForKey:) 
  public func double(for key: String) -> Double {
    return number(for: key).doubleValue
  }
  
  @objc (floatForKey:)
  public func float(for key: String) -> Float {
    return number(for: key).floatValue
  }
  
  @objc (integerForKey:)
  public func integer(for key: String) -> Int {
    return number(for: key).intValue
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
    let classes: [String: AnyClass] = [String(describing: type(of: aClass.self)) :aClass]
    return object(for: key, ofClasses: classes)
  }
  
  @objc (objectForKey:ofClasses:)
  public func object(for key: String, ofClasses classes: [String: AnyClass]) -> Any? {
    guard let data = data(for: key) else { return nil }
    
    guard let object = NSKeyedUnarchiver.lu_unarchiveObject(ofClasses: classes, with: data) else {
      let message = "Error while calling objectForKey: with key \(key)"
      let error = NSError(domain: LUKeychainAccess.errorDomain,
                          code: LUKeychainAccessError.LUKeychainAccessInvalidArchiveError.rawValue, userInfo:[NSLocalizedDescriptionKey: message])
      handle(error: error)
      return nil
    }
    
    return object
  }
  
  @objc (recursivelyFindObjectForKey:fromClass:)
  public func recursivelyFindObject(for key: String, from aClass: AnyClass) -> Any? {
    if let result = object(for: key, ofClass: aClass.self) {
      return result
    }
    
    if aClass.self != NSObject.self {
      return recursivelyFindObject(for: key, from: aClass)
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
  
  private func number(for key: String) -> NSNumber {
    guard let object = object(for: key, ofClass: NSNumber.self) else {
//      assertionFailure("Object not found for key \(key)")
      return 0
    }
    guard let number = object as? NSNumber else {
      return 0
    }
    
    return number
  }
}
