//
//  LUKeychainServicesSpec.swift
//  Swift UnitTests
//
//  Copyright © 2022 GrubHub. All rights reserved.
//

import XCTest
import Nimble
import Quick
@testable import LUKeychainAccess

final class LUKeychainServicesSpec: QuickSpec {
  override func spec() {
    var services: LUKeychainServices!
    var error: NSError?
    var error2: NSError?
    let key = "key1"
    let key2 = "key2"
    let data =  "data".data(using: .utf8)!
    let data2 = "data2".data(using: .utf8)!
    
    beforeEach {
      services = LUKeychainServices()
      services.deleteAllItems(error: nil)
      error = nil
      error2 = nil
    }
    
    describe("modifying and retrieving data") {
      beforeEach {
        services.add(data, for: key, error: nil)
      }
      
      it("adds and retrieves data from the keychain") {
        let result = services.data(for: key, error: &error)
        expect(result).to(equal(data))
        expect(error).to(beNil())
      }
      
      it("updates data from the keychain") {
        services.update(data2, for: key, error: nil)
        let result = services.data(for: key, error: nil)
        expect(result).to(equal(data2))
        expect(error).to(beNil())
      }
    }
    
    describe("deleting items") {
      beforeEach {
        services.add(data, for: key, error: nil)
        services.add(data2, for: key2, error: nil)
      }
      
      it("deletes only the item with a given key") {
        services.deleteItem(for: key, error: &error)
        expect(error).to(beNil())
        expect(services.data(for: key, error: &error2)).to(beNil())
        expect(error2).toNot(beNil())
        expect(Int(error2!.code)).to(equal(Int(errSecItemNotFound)))
        expect(services.data(for: key2, error: nil)).to(equal(data2))
      }
      
      it("deletes all items") {
        services.deleteAllItems(error: &error)
        expect(error).to(beNil())
        expect(services.data(for: key, error: &error)).to(beNil())
        expect(error).toNot(beNil())
        expect(Int(error!.code)).to(equal(Int(errSecItemNotFound)))
        expect(services.data(for: key2, error: &error2)).to(beNil())
        expect(error2).toNot(beNil())
        expect(Int(error2!.code)).to(equal(Int(errSecItemNotFound)))
      }
    }
  }
}
