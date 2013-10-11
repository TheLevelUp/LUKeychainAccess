LUKeychainAccess
================

A wrapper for iOS Keychain Services that behaves just like `NSUserDefaults`.

## Usage

Import the following files into your project, then `#import` the `LUKeychainAccess.h` file.

- `LUKeychainAccess.h`
- `LUKeychainAccess.m`

Add `Security.framework` under "Link Binary With Libraries" in "Build Phases" of your build target.

Use `LUKeychainAccess` just as you would use `NSUserDefaults`:

    [[LUKeychainAccess standardKeychainAccess] setBool:NO forKey:@"authorized"];
    BOOL authorized = [[LUKeychainAccess standardKeychainAccess] boolForKey:@"authorized"];

There are methods for getting and setting BOOL, double, float and NSInteger types, as well as `NSString`, `NSData` and generic `NSObject` objects. You may use any object that can be encoded with `NSKeyedArchiver`.

## Accessibility

Keychain Services has several options for when a keychain item can be readable.

This option can be set in `LUKeychainAccess` through the `accessibilityState` parameter. Its possible values match those [provided by Apple](https://developer.apple.com/library/ios/DOCUMENTATION/Security/Reference/keychainservices/Reference/reference.html#//apple_ref/doc/constant_group/Keychain_Item_Accessibility_Constants):

- `LUKeychainAccessAttrAccessibleAfterFirstUnlock`
- `LUKeychainAccessAttrAccessibleAfterFirstUnlockThisDeviceOnly`
- `LUKeychainAccessAttrAccessibleAlways`
- `LUKeychainAccessAttrAccessibleAlwaysThisDeviceOnly`
- `LUKeychainAccessAttrAccessibleWhenUnlocked`
- `LUKeychainAccessAttrAccessibleWhenUnlockedThisDeviceOnly`

The default value is `LUKeychainAccessAttrAccessibleWhenUnlocked`.

## Error Handling

An instance of `LUKeychainAccess` may be optionally given a error handler, which can be any object that implements the `LUKeychainErrorHandler` protocol. This error handler will be notified if an error occurs.

## Requirements

`LUKeychainAccess` requires iOS 5.0+. The tests are written using [Kiwi](https://github.com/allending/Kiwi).

## License

`LUKeychainAccess` is written by Costa Walcott, and is Copyright 2012-2013 SCVNGR, Inc D.B.A. LevelUp. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
