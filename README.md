# README #

This is the App Cats CrowdSOLUTIONS Framework.
    
## Getting Started ##

## Installation

CrowdSolutions is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'CrowdSolutions'
```


### Logging ###

We provide a Logger that can post to the console or a publisher which you can then use inside of your application either by posting to the console or using some other tool such as Swifty Beaver to log


```
CrowdLog.shared.logLocation = .publisher
CrowdLog.shared.allowedSubsystems = .all
CrowdLog.shared.logReceived
    .onMain
    .sink { log in
        
        switch log.level {
        case .debug:
            DDLogD(log.message, log.function, line: log.line)
        case .info:
            DDLogI(log.message, log.function, line: log.line)
        case .notice:
            DDLogW(log.message, log.function, line: log.line)
        case .error, .fault:
            DDLogE(log.message, log.function, line: log.line)
        }
    }
    .store(in: &cancellables)
```
