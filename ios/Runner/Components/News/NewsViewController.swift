
import UIKit
import DigioEsignSDK

class NewsViewController: UIViewController {

    var coordinatorDelegate: NewsCoordinatorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDigio()
    }

    func initDigio()  {
        print("Hey ashhh")
        print("Phone Number is ",phoneNumber ?? "88779559898")
        print("Doc id is  ", docID ?? "DID211208160039285CQQIK33CBR3P6U")
                // additionalParam is optional and need to add only for eNach/Mandate, if you want to add additional params
        var additionalParam = [String:String]()
                 additionalParam["dg_preferred_auth_type"] = "debit"

              DigioBuilder()
                 .withController(viewController: self) // Mandatory pass your view controller here
                 .setLogo(logo: "") //optional your logo link
                 .setDocumentId(documentId: docID ?? "DID211208160039285CQQIK33CBR3P6U") // Mandatory pass Document ID
                 .setIdentifier(identifier: phoneNumber ?? "88779559898") // Mandatory pass identifier
                 .setEnvironment(environment: DigioEnvironment.PRODUCTION) // Mandatory: SANDBOX / PRODUCTION
                 .setServiceMode(serviceMode: DigioServiceMode.OTP) // Mandatory
                 .setAdditionalParams(additionalParams: additionalParam) // optional use for eNach/mandate only
                 .build()

    }
    
    @IBAction func goToFlutter(_ sender: UIButton) {
        coordinatorDelegate?.navigateToFlutter()
    }
    

}

/** Implement DigioEsignDelegate, And add onDigioResponseSuccess & onDigioResponseFailure protocol stubs **/
    extension NewsViewController : DigioEsignDelegate {
        func onDigioResponseSuccess(response: String) {
            print("Success \(response)")
            //Call the Check Esign Apis here

            coordinatorDelegate?.navigateToFlutter()
        }

        func onDigioResponseFailure(response: String) {
            print("Failure \(response)")
            coordinatorDelegate?.navigateToFlutter()
        }
    }
