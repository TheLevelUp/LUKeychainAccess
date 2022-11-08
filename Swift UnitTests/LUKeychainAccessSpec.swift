//
//  LUKeychainAccessSpec.swift
//  Swift UnitTests
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import XCTest
import Foundation
import Nimble
import Quick
import ObjectiveC
@testable import LUKeychainAccess

struct Observer {
  struct Key {
    static let Add = "add"
    static let GetData = "getData"
    static let DeleteAll = "deleteAll"
    static let DeleteItem = "deleteItem"
    static let Update = "update"
    static let Data = "data"
    static let Key = "key"
  }
  
  var record: [String: Dictionary<String, Any>] = [:]
  
  func functionWasCalled(key: String) -> Bool {
    return record[key] != nil
  }
}

final class LUKeychainAccessSpec: QuickSpec {
  var servicesObserver: Observer = Observer()
  
  override func spec() {
    var access: LUKeychainAccess!
    var mockServices: KeychainServicesMock!
    var errorHandler: ErrorHandler!
    let testGroup = "test_group"
    let testAdditionalParams = ["test": "test"]
    let testError = NSError(domain: "test", code: 32)
    
    beforeEach {
      errorHandler = ErrorHandler()
      access = LUKeychainAccess.standardKeychainAccess
      access.errorHandler = errorHandler
      mockServices = KeychainServicesMock()
      access.services = mockServices
      mockServices.observer = self
      self.servicesObserver.record = [:]
    }
    
    // MARK: - standardKeychainAccess
    describe("standardKeychainAccess") {
      it("returns a LUKeychainAccess") {
        expect(access).to(beAKindOf(LUKeychainAccess.self))
      }
      
      it("returns a new LUKeychainAccess each time") {
        let access1 = LUKeychainAccess.standardKeychainAccess
        let access2 = LUKeychainAccess.standardKeychainAccess
        
        expect(access1).toNot(equal(access2))
      }
    }
    
    // MARK: - Deletes
    describe("deleteAll") {
      it("deleteAll") {
        access.deleteAll()
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.DeleteAll)).to(beTrue())
      }
      
      context("if the delete fails") {
        beforeEach {
          mockServices.stubDeleteAll(with: testError, result: false)
        }
        
        it("notifies the error handler") {
          access.deleteAll()
          expect(errorHandler.lastError).toNot(beNil())
          expect((errorHandler.lastError! as NSError).code).to(equal(testError.code))
        }
      }
    }
    
    describe("deleteObjectForkey:") {
      let testKeyToDelete = "test_key_to_delete"
      it("deletes the item with the given key from the keychain") {
        access.deleteObject(for: testKeyToDelete)
        
        if let arguments = self.servicesObserver.record[Observer.Key.DeleteItem],
           let keyArg: String = arguments[Observer.Key.Key] as? String {
          expect(keyArg).to(equal(testKeyToDelete))
        } else {
          fail("deleteObject was not called with key")
        }
      }
      
      context("if the delete fails") {
        beforeEach {
          mockServices.stubDeleteItem(with: testError, result: false)
        }
        
        it("notifies the error handler") {
          access.deleteObject(for: testKeyToDelete)
          expect(errorHandler.lastError).toNot(beNil())
          expect((errorHandler.lastError! as NSError).code).to(equal(testError.code))
        }
      }
    }
    
    // MARK: - Getters
    describe("accessGroup") {
      beforeEach {
        mockServices.stubbedAccessGroup = testGroup
      }
      
      it("returns the accessGroup of keychain services") {
        expect(access.accessGroup).to(equal(testGroup))
      }
    }
    
    describe("additionalQueryParams") {
      beforeEach {
        mockServices.stubbedAdditionalQueryParams = testAdditionalParams
      }
      
      it("returns the additionalQueryParams of keychain services") {
        expect(access.additionalQueryParams as? [String: String]).to(equal(testAdditionalParams))
      }
    }
    
    describe("boolForKey:") {
      let key = "boolTest"
      let testBool = true
      let testBoolData = data(for: NSNumber(value: testBool))
      
      it("returns the boolValue of the object stored at the key") {
        mockServices.stubData(with: nil, result: testBoolData)
        expect(access.bool(for: key)).to(equal(testBool))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
    }
    
    describe("dataForKey:") {
      let expectedResult = "value".data(using: String.Encoding.utf8)!
      let key = "dataTest"
      
      it("returns the data stored in keychain at the key") {
        mockServices.stubData(with: nil, result: expectedResult)
        expect(access.data(for: key)).to(equal(expectedResult))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
      
      context("if the services command fails") {
        beforeEach {
          mockServices.stubData(with: testError, result: nil)
        }
        
        it("notifies the error handler") {
          expect(access.data(for: key)).to(beNil())
          expect(errorHandler.lastError).toNot(beNil())
          expect((errorHandler.lastError! as NSError).code).to(equal(testError.code))
        }
      }
    }
    
    describe("doubleForKey:") {
      let key = "doubleTest"
      let testValue: Double = 123.0
      let testData: Data? = data(for: NSNumber(value: testValue))
      
      it("returns the doubleValue of the object stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.double(for: key)).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
    }
    
    describe("floatForKey:") {
      let key = "floatTest"
      let testValue: Float = 123.0
      let testData: Data? = data(for: NSNumber(value: testValue))
      
      it("returns the floatValue of the object stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.float(for: key)).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
    }
    
    describe("integerForKey:") {
      let key = "integerTest"
      let testValue: Int = 123
      let testData: Data? = data(for: NSNumber(value: testValue))
      
      it("returns the integerValue of the object stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.integer(for: key)).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
    }
    
    describe("stringForKey:") {
      let key = "stringTest"
      let testValue = "testString"
      let testData = testValue.data(using: String.Encoding.utf8)
      
      it("returns a UTF-8 encoded string form teh data stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.string(for: key)).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
    }
    
    describe("objectForKey:ofClasses") {
      let key = "objectTest"
      let testValue = [NSNumber(value: 1), NSNumber(value: 2)]
      let testData = NSKeyedArchiver.lu_archivedData(with: testValue)
      
      it("returns the unarchived object from the data stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.object(for: key, ofClasses: [NSArray.self]) as? [NSNumber]).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
      
      context("when the incorrect class types are passed in") {
        let set = Set(["A", "B", "C"])
        let testObject = [set]
        let testData = NSKeyedArchiver.lu_archivedData(with: testObject)
        
        it("notifies the error handler") {
          mockServices.stubData(with: nil, result: testData)
          expect(access.object(for: key, ofClasses: [NSArray.self])).to(beNil())
          expect(errorHandler.lastError).toNot(beNil())
        }
      }
    }
    
    describe("objectForKey:ofClass") {
      let key = "objectTest"
      let testValue = [NSNumber(value: 1), NSNumber(value: 2)]
      let testData = NSKeyedArchiver.lu_archivedData(with: testValue)
      
      it("returns the unarchived object from the data stored at the key") {
        mockServices.stubData(with: nil, result: testData)
        expect(access.object(for: key, ofClass: NSArray.self) as? [NSNumber]).to(equal(testValue))
        expect(self.servicesObserver.functionWasCalled(key: Observer.Key.GetData)).to(beTrue())
      }
      
      context("when the object is not NSCoding compliant") {
        let testObject = NSCodingNonCompliantObject()
        testObject.testProperty2 = "test"
        testObject.testProperty1 = 2
        
        it("notify the error handler") {
          expect(access.set(object: testObject, for: key)).to(beFalse())
          expect(errorHandler.lastError).toNot(beNil())
        }
      }
      
//      context("when the object is not NSSecureCoding compliant") {
//        let testObject = NSCodingCompliantObject(coder: NSCoder())
//        testObject!.testProperty2 = "test"
//        testObject!.testProperty1 = 2
//        let testData = data(for: testObject!)!
//
//        it("continues to store the archived data of the object with the key") {
//          mockServices.stubUpdate(with: nil, result: testData)
//          expect(access.set(object: testObject!, for: key)).to(beTrue())
//          expect(errorHandler.lastError).to(beNil())
//        }
//      }
    }
    
    describe("recursivelyFindObjectForKey:fromClass:") {
      let key = "objectTest"
      let testValue = [NSNumber(value: 1), NSNumber(value: 2)]
      let testObject = data(for: testValue)!
      
      context("when the object has been added") {
        it("finds the object recursively") {
          mockServices.stubData(with: nil, result: testObject)
          expect(access.object(for: key, ofClass: NSArray.self) as? [NSNumber]).to(equal(testValue))
          expect(access.recursivelyFindObject(for: key, from: NSArray.self) as? [NSNumber]).to(equal(testValue))
        }
      }
      
      context("when the object has not been added") {
        it("returns nil") {
          expect(access.object(for: key, ofClass: NSArray.self)).to(beNil())
          expect(access.recursivelyFindObject(for: key, from: NSArray.self)).to(beNil())
        }
      }
    }
    
    // MARK: - Setters
    describe("registerDefaults:") {
      beforeEach {
        access.services = LUKeychainServices()
      }
      
      it("doesn't overwrite existing values") {
        
        access.register(defaults: ["key": "value1"])
        access.register(defaults: ["key": "value2"])
        expect(access.string(for: "key")).to(equal("value1"))
      }
      
      it("is able to check existing values recursively") {
        access.services = LUKeychainServices()
        access.set(bool: false, for: "existingBool")
        access.set(object: ["existingValue"], for: "existingArray")
        let set: Set = ["existingValue"]
        access.set(object: set, for: "existingSet")
        access.set(object: ["key":"existingValue"], for: "existingDic")
        access.set(string: "existingValue", for: "existingString")
        
        let newSet: Set = ["newValue"]
        let dictionary: Dictionary<String, Any> =
        ["existingBool": true,
         "newBool": true,
         "existingArray": ["newValue"],
         "newArray": ["newValue"],
         "existingSet": newSet,
         "newSet": newSet,
         "existingDic": ["key":"newValue"],
         "newDic": ["key":"newValue"],
         "existingString": "newValue",
         "newString": "newValue"]
        
        access.register(defaults: dictionary)
        
        expect(access.bool(for: "existingBool")).to(beFalse())
        expect(access.bool(for: "newBool")).to(beTrue())
        expect(access.object(for: "existingArray", ofClass: NSArray.self) as? [String]).to(equal(["existingValue"]))
        expect(access.object(for: "newArray", ofClass: NSArray.self) as? [String]).to(equal(["newValue"]))
        expect(access.object(for: "existingSet", ofClass: NSSet.self) as? Set).to(equal(set))
        expect(access.object(for: "newSet", ofClass: NSSet.self) as? Set).to(equal(newSet))
        expect(access.object(for: "existingDic", ofClass: NSDictionary.self) as? Dictionary<String, String>).to(equal(["key":"existingValue"]))
        expect(access.object(for: "newDic", ofClass: NSDictionary.self) as? Dictionary<String, String>).to(equal(["key":"newValue"]))
        expect(access.string(for: "existingString")).to(equal("existingValue"))
        expect(access.string(for:"newString")).to(equal("newValue"))
      }
      
      it("sets the value for new keys") {
        expect(access.register(defaults: ["newKey": NSNumber(value: true)])).to(beTrue())
        expect(access.bool(for: "newKey")).to(beTrue())
      }
      
      it("can set multiple keys") {
        let dic = ["foo": NSNumber(value: true), "bar": NSNumber(value: 100)]
        expect(access.register(defaults: dic)).to(beTrue())
        expect(access.bool(for: "foo")).to(beTrue())
        expect(access.integer(for: "bar")).to(equal(100))
      }
    }
    
    
  }
}

// MARK: - Private Helper Functions
private func data(for object: Any) -> Data? {
  if let data: Data = try? NSKeyedArchiver.archivedData(with: object) {
    return data
  }
  
  return nil
}


extension LUKeychainAccessSpec: KeychainServicesMockObserver {
  func addWasCalled(data: Data, key: String) {
    servicesObserver.record[Observer.Key.Add] =
    [Observer.Key.Data: data, Observer.Key.Key: key]
  }
  
  func dataWasCalled(key: String) {
    servicesObserver.record[Observer.Key.GetData] =
    [Observer.Key.Key: key]
  }
  
  func deleteAllItemsWasCalled() {
    servicesObserver.record[Observer.Key.DeleteAll] = [:]
  }
  
  func deleteItemWasCalled(key: String) {
    servicesObserver.record[Observer.Key.DeleteItem] =
    [Observer.Key.Key: key]
  }
  
  func updateWasCalled(data: Data, key: String) {
    servicesObserver.record[Observer.Key.Update] =
    [Observer.Key.Data: data, Observer.Key.Key: key]
  }
}
