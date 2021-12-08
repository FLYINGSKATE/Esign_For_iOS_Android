import UIKit
import Flutter

var docID: String!
var phoneNumber: String!

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  private var mainCoordinator: AppCoordinator?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //
      GeneratedPluginRegistrant.register(with: self)

      let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
      let tstChannel = FlutterMethodChannel(name:"samples.flutter.dev/battery",binaryMessenger: flutterViewController.binaryMessenger)
       tstChannel.setMethodCallHandler({(call: FlutterMethodCall, result:   FlutterResult) -> Void in
         guard call.method == "doEsign" else {

         result(FlutterMethodNotImplemented)
         return
       }
       print("Place a string here, and a variable")
       if let args = call.arguments as? Dictionary<String, Any>,
             let docId = args["docId"] as? String {
             // please check the "as" above  - wasn't able to test
             // handle the method
                docID=docId
                print(docId)
             }
       else {
             result(FlutterError.init(code: "84", message: "Doc id not found", details: nil))
       }

       if let args = call.arguments as? Dictionary<String, Any>,
              let PhoneNumber = args["phoneNumber"] as? String {
                                    // please check the "as" above  - wasn't able to test
                                    // handle the method
                                    phoneNumber=PhoneNumber
                                    print(phoneNumber)
                                 }
              else {
                    result(FlutterError.init(code: "85", message: "PhoneNumber not found", details: nil))
              }


       self.mainCoordinator?.start()

      })
    //

    let navigationController = UINavigationController(rootViewController: flutterViewController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        mainCoordinator = AppCoordinator(navigationController: navigationController)
        window?.makeKeyAndVisible()
      
    return super.application(application,didFinishLaunchingWithOptions: launchOptions)
  }
    
}
