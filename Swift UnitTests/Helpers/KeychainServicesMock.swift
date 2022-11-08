//
//  KeychainServicesMock.swift
//  Swift UnitTests
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import Foundation
@testable import LUKeychainAccess

typealias Stub = (error: NSError?, result: Any?)

internal class KeychainServicesMock: NSObject {
  // MARK: - Observer
  var observer: KeychainServicesMockObserver?
  
  // MARK: - Settable Configs
  var stubbedAccessGroup: String?
  var stubbedAccessibilityState: LUKeychainAccessibility = .always
  var stubbedAdditionalQueryParams: [String : Any]?
  var stubbedService: String?
  
  // MARK: - Stubbed References
  var addStub: Stub = (error: nil, result: true)
  var dataStub: Stub = (error: nil, result: Data())
  var deleteAllStub: Stub = (error: nil, result: true)
  var deleteItemStub: Stub = (error: nil, result: true)
  var updateStub: Stub = (error: nil, result: true)
  
  // MARK: - Stubbing Errors & Results for Functions
  func stubAdd(with error: NSError?, result: Bool) {
    addStub = (error: error, result: result)
  }
  
  func stubData(with error: NSError?, result: Data?) {
    dataStub = (error: error, result: result)
  }
  
  func stubDeleteAll(with error: NSError?, result: Bool) {
    deleteAllStub = (error: error, result: result)
  }
  
  func stubDeleteItem(with error: NSError?, result: Bool) {
    deleteItemStub = (error: error, result: result)
  }
  
  func stubUpdate(with error: NSError?, result: Data) {
    updateStub = (error: error, result: result)
  }
}

extension KeychainServicesMock: LUKeychainServicesProtocol {
  var accessGroup: String? {
    get { stubbedAccessGroup }
    set(newValue) { stubbedAccessGroup = newValue }
  }
  
  var accessibilityState: LUKeychainAccessibility {
    get { stubbedAccessibilityState }
    set(newValue) { stubbedAccessibilityState = newValue }
  }
  
  var additionalQueryParams: [String : Any]? {
    get { stubbedAdditionalQueryParams }
    set(newValue) { stubbedAdditionalQueryParams = newValue }
  }
  
  var service: String? {
    get { stubbedService }
    set(newValue) { stubbedService = newValue }
  }
  
  func add(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    observer?.addWasCalled(data: data, key: key)
    return errorAndResult(error: error, stub: addStub) as! Bool
  }
  
  func data(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Data? {
    observer?.dataWasCalled(key: key)
    return errorAndResult(error: error, stub: dataStub) as? Data
  }
  
  func deleteAllItems(error: UnsafeMutablePointer<NSError?>?) -> Bool {
    observer?.deleteAllItemsWasCalled()
    return errorAndResult(error: error, stub: deleteAllStub) as! Bool
  }
  
  func deleteItem(for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    observer?.deleteItemWasCalled(key: key)
    return errorAndResult(error: error, stub: deleteItemStub) as! Bool
  }
  
  func update(_ data: Data, for key: String, error: UnsafeMutablePointer<NSError?>?) -> Bool {
    observer?.updateWasCalled(data: data, key: key)
    return errorAndResult(error: error, stub: updateStub) as! Bool
  }
  
  private func errorAndResult(error: UnsafeMutablePointer<NSError?>?, stub: Stub) -> Any {
    if let errorPointer = error {
      errorPointer.pointee = stub.error
    }
    return stub.result
  }
}

protocol KeychainServicesMockObserver {
  func addWasCalled(data: Data, key: String)
  func dataWasCalled(key: String)
  func deleteAllItemsWasCalled()
  func deleteItemWasCalled(key: String)
  func updateWasCalled(data: Data, key: String)
}
