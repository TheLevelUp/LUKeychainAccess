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
public let LUKeychainAccessErrorDomain = "LUKeychainAccessErrorDomain"

@objc public class LUKeychainAccess: NSObject {
  
  // MARK: - Singleton
  @objc
  public class var standardKeychainAccess: LUKeychainAccess {
    return sharedKeychainAccess
  }
  
  private static var sharedKeychainAccess: LUKeychainAccess = {
      return LUKeychainAccess()
  }()
  
  // MARK: - Settable Properties
  @objc public var errorHandler: LUKeychainErrorHandler?
  
  // MARK: - Computed Properties
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
  @objc
  public func deleteAll() -> Bool {
    var error: Error?
    guard services.deleteAllItems(error: &error) else {
      handle(error: error)
      return false
    }
    
    return true
  }
  
  @objc
  public func deleteObject(for key: String) {
    var error: Error?
    if !services.deleteItem(for: key, error: &error) {
      handle(error: error)
    }
  }
  
  // MARK: - Public Config Functions
  @objc
  public func set(accessGroup: String) {
    services.accessGroup = accessGroup
  }
  
  @objc
  public func set(accessibilityState: LUKeychainAccessibility) {
    services.accessibilityState = accessibilityState
  }
  
  @objc
  public func set(additionalQueryParams: [String: Any]) {
    services.additionalQueryParams = additionalQueryParams
  }
  
  // MARK: - Public Set Functions
  
  @objc
  public func register(defaults: [String: Any]) {
    for (key, value) in defaults {
      if recursivelyFindObject(for: key, from: type(of: value)) == nil && string(for: key) == nil {
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
  
  @objc
  public func set(bool: Bool, for key: String) {
    set(object: NSNumber(value: bool), for: key)
  }
  
  @objc
  public func set(data: Data?, for key: String) {
    guard let data = data else {
      deleteObject(for: key)
      return
    }
    
    var error: Error?
    var success = services.add(data, for: key, error: &error)
    
    if !success {
      if let nSError = error as? NSError, nSError.code == errSecDuplicateItem {
        error = nil
        success = services.update(data, for: key, error: &error)
      }
      
      handle(error: error)
    }
  }
  
  @objc
  public func set(double: Double, for key: String) {
    set(object: NSNumber(value: double), for: key)
  }
  
  @objc
  public func set(float: Float, for key: String) {
    set(object: NSNumber(value: float), for: key)
  }
  
  @objc
  public func set(integer: Int, for key: String) {
    set(object: NSNumber(integerLiteral: integer), for: key)
  }
  
  @objc
  public func set(string: String, for key: String) {
    guard let data = string.data(using: String.Encoding.utf8) else {
      assertionFailure("Unable to encode string")
      return
    }
    set(data: data, for: key)
  }
  
  @objc
  public func set(object: Any, for key: String) {
    guard let data: Data = NSKeyedArchiver.lu_archivedData(with: object) else {
      assertionFailure("Unable to archive with root object")
      return
    }
    
    self.set(data: data, for: key)
  }
  
  // MARK: - Public Get Functions
  @objc
  public func bool(for key: String) -> Bool {
    guard let number = object(for: key, ofClass: NSNumber.Type) as? NSNumber else {
      assertionFailure("Unable to unarchive NSNumber")
    }

    return number.boolValue
  }
  
  @objc
  public func data(for key: String) -> Data? {
    var error: Error
    guard let  data = services.data(for: key, error: &error) else {
      handle(error: error)
      return nil
    }
    
    return data
  }
  
  @objc
  public func double(for key: String) -> Double {
    return (object(for: key, ofClass: NSNumber.self) as? NSNumber).doubleValue
  }
  
  @objc
  public func float(for key: String) -> Float {
    return (object(for: key, ofClass: NSNumber.self) as? NSNumber).floatValue
  }
  
  @objc
  public func integer(for key: String) -> Int {
    return (object(for: key, ofClass: NSNumber.self) as? NSNumber).intValue
  }
  
  @objc
  public func string(for key: String) -> String? {
    guard let data = data(for: key) else {
      return nil
    }
    
    return String(data: data, encoding: String.Encoding.utf8)
  }
  
  @objc
  public func object(for key: String, ofClass: AnyHashable) -> Any? {
    let classes: Set = [ofClass]
    return object(for: key, ofClasses: classes)
  }
  
  @objc
  public func object(for key: String, ofClasses: Set<AnyHashable>) -> Any? {
    guard let data = data(for: key) else { return nil }
    
    guard let object = NSKeyedUnarchiver.lu_unarchiveObject(of: ofClasses, with: data) else {
      let message = "Error while calling objectForKey: with key \(key)"
      let error = NSError(domain: LUKeychainAccessErrorDomain,
                          code: LUKeychainAccessError.LUKeychainAccessInvalidArchiveError.rawValue, userInfo:[NSLocalizedDescriptionKey: message])
      handle(error: error)
    }
    
    guard let hashableObject = object as? AnyHashable else {
      return nil
    }
    
    return hashableObject
  }
  
  @objc
  public func recursivelyFindObject(for key: String, from aClass: AnyHashable) -> Any? {
    if let result = object(for: key, ofClass: aClass) {
      return result
    }
    
    if let hashableClass = aClass as? AnyClass,
       let aSuperclass = hashableClass.superclass as? AnyHashable,
       hashableClass.self != NSObject.self {
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
}
