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

## Requirements

`LUKeychainAccess` requires iOS 5.0+. The tests are written using [Kiwi](https://github.com/allending/Kiwi).

## License

`LUKeychainAccess` is written by Costa Walcott, and is Copyright 2012 SCVNGR, Inc. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
