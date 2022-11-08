//
//  NSCodingCompliantObject.swift
//  Swift UnitTests
//
//  Copyright © 2022 Grubhub. All rights reserved.
//

import Foundation

class NSCodingCompliantObject: NSObject, NSCoding {
  var testProperty1: Float
  var testProperty2: String
  
  func encode(with coder: NSCoder) {
    coder.encodeConditionalObject(NSNumber(value: testProperty1),
                                  forKey: "testProperty1")
    coder.encodeConditionalObject(testProperty2,
                                  forKey: "testProperty2")
  }
  
  required init?(coder: NSCoder) {
    self.testProperty1 = (coder.decodeObject(forKey: "testProperty1") as! NSNumber).floatValue
    self.testProperty2 = coder.decodeObject(forKey: "testProperty2") as! String
    super.init()
  }
}
