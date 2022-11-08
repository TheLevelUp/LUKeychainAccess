//
//  LUKeychainServices.swift
//  LUKeychainAccess
//
//  Copyright © 2022 GrubHub. All rights reserved.
//
//// A wrapper for Keychain Services using the Facade pattern: http://en.wikipedia.org/wiki/Facade_pattern

import Foundation

@objc
class LUKeychainServices: NSObject, LUKeychainServicesProtocol {
  internal var service: String?
  @objc public var accessGroup: String?
  internal var accessibilityState: LUKeychainAccessibility = .whenUnlocked
  @objc public var additionalQueryParams: [String: Any]?
  
  // MARK: - Singleton
  
  @objc
  public class var keychainServices: LUKeychainServices {
    return sharedKeychainServices
  }
  
  private static var sharedKeychainServices: LUKeychainServices = {
    return LUKeychainServices()
  }()
  
  // MARK: - Public Write Functions
  
  @objc (addData:forKey:error:) @discardableResult
  public func add(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    var query = queryDictionary(for: key)
    query[kSecAttrAccessible as String] = accessibilityState.stateCFType
    query[kSecValueData as String] = data
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == noErr else {
      if let errorPointer = error {
        errorPointer.pointee = self.error(from: status, description: "SecItemAdd with key \(key)") as NSError
      }
      return false
    }
    
    return true
  }
  
  @objc (dataForKey:error:)
  public func data(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Data? {
    var query = queryDictionary(for: key)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnData as String] = kCFBooleanTrue
    
    var cfResult: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &cfResult)
    
    if let statusError = validate(operation: "SecItemCopyMatching", key: key, status: status) {
      if let errorPointer = error {
        errorPointer.pointee = statusError
      }
      return nil
    }
    
    guard let data = cfResult as? Data else {
      if let errorPointer = error {
        errorPointer.pointee =
        self.error(from: status, description: "SecItemCopyMatching failed with key \(key): Invalid item format") as NSError
      }
      return nil
    }
    
    return data
  }
  
  @objc (deleteAllItemsWithError:) @discardableResult
  public func deleteAllItems(error: UnsafeMutablePointer<NSError?>?) -> Bool {
    let query = [kSecClass: kSecClassGenericPassword]
    let status = SecItemDelete(query as CFDictionary)
    
    if let statusError = validate(operation: "SecItemDelete", status: status) {
      if let errorPointer = error {
        errorPointer.pointee = statusError
      }
      return false
    }
    
    return true
  }
  
  @objc (deleteItemWithKey:error:) @discardableResult
  public func deleteItem(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    let query = queryDictionary(for: key)
    let status = SecItemDelete(query as CFDictionary)
    
    if let statusError = validate(operation: "SecItemDelete", status: status) {
      if let errorPointer = error {
        errorPointer.pointee = statusError
      }
      return false
    }
    
    return true
  }
  
  @objc (updateData:forKey:error:) @discardableResult
  public func update(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    var query = queryDictionary(for: key)
    query[kSecValueData as String] = data
    
    let updateQuery =
    [kSecValueData: data,
kSecAttrAccessible: accessibilityState.stateCFType] as [CFString: Any?]
    
    let status = SecItemUpdate(query as CFDictionary,
                               updateQuery as CFDictionary)
    
    
    if let statusError = validate(operation: "SecItemUpdate", key: key, status: status) {
      if let errorPointer = error {
        errorPointer.pointee = statusError
      }
      return false
    }
    
    return true
  }
  
  // MARK: - Private Functions
  
  private func validate(operation secName: String,
                        key: String = "",
                        status: OSStatus) -> NSError? {
    let keyDescription = key == "" ? "" : " with key \(key)"
    guard status != errSecItemNotFound else {
      return self.error(from: status, description: "\(secName) failed\(keyDescription): Item not found") as NSError
    }
    
    guard status != errSecMissingEntitlement else {
      return self.error(from: status, description: "\(secName) failed\(keyDescription): Missing entitlement") as NSError
    }
    
    guard status == errSecSuccess else {
      return self.error(from: status, description: "\(secName) failed\(keyDescription): Error code(\(status))") as NSError
    }
    
    return nil
  }
  
  private func error(from status: OSStatus, description: String) -> Error {
    return error(from: status, descriptionFormat: description)
  }
  
  private func error(from status: OSStatus, descriptionFormat: String, args: CVarArg...) -> Error {
    var callerDescription: String = descriptionFormat
    if args.count > 0 {
      withVaList(args) {
        callerDescription = String(format: descriptionFormat, $0 as! CVarArg)
      }
    }
    
    let message = errorMessage(from: status)
    let description = "Error while calling \(callerDescription): \(message)"
    
    return NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: description]) as Error
  }
  
  private func errorMessage(from status: OSStatus) -> String {
    switch status {
    case errSecUnimplemented:
      return "Function or operation not implemented."
      
    case errSecParam:
      return "One or more parameters passed to a function where not valid."
      
    case errSecAllocate:
      return "Failed to allocate memory."
      
    case errSecNotAvailable:
      return "No keychain is available. You may need to restart your computer."
      
    case errSecDuplicateItem:
      return "The specified item already exists in the keychain."
      
    case errSecItemNotFound:
      return "The specified item could not be found in the keychain."
      
    case errSecInteractionNotAllowed:
      return "User interaction is not allowed."
      
    case errSecDecode:
      return "Unable to decode the provided data."
      
    case errSecAuthFailed:
      return "The user name or passphrase you entered is not correct."
      
    default:
      return "No error."
    }
  }
  
  private func queryDictionary(for key: String) -> [String: Any] {
    let data = key.data(using: String.Encoding(rawValue: NSUTF8StringEncoding)) as Any
    let query: NSMutableDictionary =
    [kSecClass as String: kSecClassGenericPassword,
     kSecAttrAccount as String: data
    ]
    
    if let service = service {
      query[kSecAttrService as String] = service
    }
    
    if let params = additionalQueryParams {
      query.addEntries(from: params)
    }
    
    if let group = accessGroup {
#if TARGET_IPHONE_SIMULATOR
      // Ignore the access group if running on the iPhone simulator.
      //
      // Apps that are built for the simulator aren't signed, so there's no keychain access group
      // for the simulator to check. This means that all apps can see all keychain items when run
      // on the simulator.
      //
      // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
      // simulator will return -25243 (errSecNoAccessForItem).
#else
      query[kSecAttrAccessGroup as String] = group
#endif
    }
    
    return query as! [String: Any]
  }
}
