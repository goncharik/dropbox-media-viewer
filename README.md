# MediaViewer

This repo contains the full source code for MediaView, an iOS app that uses raw DropBox API to login an view media files from shared app folder. 

---

* [Requirements](#requirements)
* [Getting Started](#getting-started)
* [Learn More](#learn-more)
* [Related Projects](#related-projects)
* [License](#license)

# Requirements

* iOS 15.0
* Xcode 15
* Swift 5.9

# Getting Started

### Register your application

Before using this SDK, you should register your application in the [Dropbox App Console](https://dropbox.com/developers/apps). This creates a record of your app with Dropbox that will be associated with the API calls you make.

### Configure App Enviroment with your dropbox Client ID and Client Secret 

Go to MediaView/Service/AppEnv.swift and replace 

```swift
"empty-client-id"
"empty-client-secret"
```

with your values. 

You may also update `defaultRedirectUri` to what you prefer.

# Dependencies

* [swift-identified-collections](https://github.com/pointfreeco/swift-identified-collections) - for better collection operations
* [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) - for better DI
* [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - simple keychain wrapper for sequre token storage

# License

The source code in this repository may be run and altered for education purposes only and not for commercial purposes. For more information see our full [license](LICENSE.md).