# SKCardReader
A swift SDK to help you scan debit/credit cards.

## Requirements

To use the SDK the following requirements must be met:

1. **Xcode 11.0** or newer
2. **Swift 4.0** or newer (preinstalled with Xcode)
3. Deployment target SDK for the app: **iOS 13.0** or later

## Installation

------

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager, which automates and simplifies the process of using 3rd-party libraries in your projects.
You can install it with the following command:

```
$ sudo gem install cocoapods
```

### Podfile

To integrate SKCardReader into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
    
    pod 'SKCardReader'

end
```

Then, run the following command:

```
$ pod install
```



## Setup

------

1. Make sure you have added camera usage description within your **Info.plist** file.

```
Privacy - Camera Usage Description
```

2. Add a view within your application and give class to that view as **CardScannerView**.

3. Now include **SKCardReader** within your swift file.

```
import 'SKCardReader'
```

4. Create an IBOutlet of that view within your ViewController and conform it to delegate.

```
@IBOutlet weak var cardScanner: CardScannerView!

override func viewDidLoad() {
   super.viewDidLoad()
   
   cardScanner.delegate = self
}
```

5. Now finally inlcude the delegate function within your view controller.

```

extension MyViewController: CardScannerDelegate {
    func extractedCardDetails(ccNumber: String, ccName: String, ccExpiry: String, ccCVV: String) {
        // ccNumber: It contains your credit/debit card number
        // ccName: It contains your name
        // ccExpiry: It contains date of expiry
        // ccCVV: It contains your cvv number
    }
}

```


## Enjoy!!
