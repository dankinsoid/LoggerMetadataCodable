# LoggerMetadataCodable

[![CI Status](https://img.shields.io/travis/dankinsoid/LoggerMetadataCodable.svg?style=flat)](https://travis-ci.org/dankinsoid/LoggerMetadataCodable)
[![Version](https://img.shields.io/cocoapods/v/LoggerMetadataCodable.svg?style=flat)](https://cocoapods.org/pods/LoggerMetadataCodable)
[![License](https://img.shields.io/cocoapods/l/LoggerMetadataCodable.svg?style=flat)](https://cocoapods.org/pods/LoggerMetadataCodable)
[![Platform](https://img.shields.io/cocoapods/p/LoggerMetadataCodable.svg?style=flat)](https://cocoapods.org/pods/LoggerMetadataCodable)


## Description
This repository provides

## Example

```swift

```
## Usage

 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/LoggerMetadataCodable.git", from: "0.1.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["LoggerMetadataCodable"])
  ]
)
```
```ruby
$ swift build
```

2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'LoggerMetadataCodable'
```
and run `pod update` from the podfile directory first.

## Author

dankinsoid, voidilov@gmail.com

## License

LoggerMetadataCodable is available under the MIT license. See the LICENSE file for more info.
