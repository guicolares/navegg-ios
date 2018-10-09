# Documentação
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
https://www.navegg.com/documentacao/como-instalar/insercao-da-sdk-ios-em-seu-aplicativo/

## Generate SDK

Change Scheme to SdkNaveggIOS-Universal and Emulator to Generic IOS Device.

Menu -> Clean

Menu -> Build

In Navigator inside products, click right in the SdkNaveggIOS.Framework and Show in Finder.



# local DEV

## put HTTP local.navdmp.com
 - Add the following lines into SDKNaveggIOS -> Info.plist

        `<key>NSAppTransportSecurity</key>
        <dict>
                <key>NSAllowsArbitraryLoads</key>
                <true/>
                <key>NSExceptionDomains</key>
                <dict>
                        <key>navdmp.com</key>
                        <dict>
                                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                                <true/>
                                <key>NSIncludesSubdomains</key>
                                <true/>
                                <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
                                <false/>
                        </dict>
                </dict>
        </dict>`

## Using pod

 `pod update
  pod install 
`
