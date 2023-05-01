import UIKit
import Flutter
import OPPWAMobile

enum PaymentCard: String, CaseIterable {
  case vise = "VISA"
  case master = "MASTERCARD"
  case mada = "MADA"
  case apple = "APPLEPAY"
    
  var displayName: String {
    switch self {
    case .vise:
      return "Visa"
    case .master:
      return "Master Card"
    case .mada:
      return "Mada"
    case .apple:
      return "Apple"
    }
  }
}

struct Constants {
    static let bundleId = "com.hyperpay.Demo.hyperpay-Dem.payments"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, OPPCheckoutProviderDelegate {
    
    let provider = OPPPaymentProvider(mode: .test)
    var checkoutProvider: OPPCheckoutProvider?
    
    private var result: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let myChannel = FlutterMethodChannel(name: "hyperPay.dev/startPayment",
        binaryMessenger: controller.binaryMessenger)
        
        
        
        
        myChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, pathResult: @escaping FlutterResult) -> Void in
            
            if call.method == "createPayment" {
                self?.result = pathResult
                let args = call.arguments
                let myArgs = args as? [String: Any], 
                price = myArgs?["price"] as? String,
                brand = myArgs?["brand"] as? String,
                user = myArgs?["user"] as? String
                print("_______> \(String(describing:  myArgs?["user"] as? String))")                              
                //------start payment
                self?.callApiAndGetCheckoutId(card:brand ?? "", userId:user ?? "", amount:price ?? "" )
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.caseInsensitiveCompare(Constants.bundleId) == .orderedSame {
            checkoutProvider?.dismissCheckout(animated: true) {
                // request payment status
                self.result?(self.checkoutID ?? "")
            }
            return true
        }
        return false
    }
    
    fileprivate func callApiAndGetCheckoutId(card: String, userId: String, amount: String) {
        print("___________xxxxxxxxxxx__________ \(card)")
        self.getCheckoutId(paymentBrand: card, userId: userId, amount: amount) { checkoutID, usedPaymentBrand in
            print("___________checkout__________ \(checkoutID)", card)
            DispatchQueue.main.async {
              
                switch card {
                case "APPLEPAY":
                    self.openApplePayFromSDK(checkoutID: checkoutID, paymentBrand: card)
                  

                default:
                    self.openPayment(checkoutID: checkoutID, paymentBrand: usedPaymentBrand)
                }
               
            }
            print("___________ddddddddd___________ \(card)")

        } onError: { error in
            print("___________Error___________ \(card)")
            DispatchQueue.main.async {
                self.showPaymentError(error: error)
            }
        }
    }
    private func openApplePayFromSDK(checkoutID: String, paymentBrand: String) {
        
        let checkoutSettings = OPPCheckoutSettings()
        let paymentRequest = OPPPaymentProvider.paymentRequest(withMerchantIdentifier: "merchant.com.hyperpay.Demo.hyperpay-Dem", countryCode: "SA")
        paymentRequest.supportedNetworks = [.masterCard, .visa] // set up supported payment networks
        checkoutSettings.applePayPaymentRequest = paymentRequest
        let checkoutProvider = OPPCheckoutProvider(paymentProvider: provider, checkoutID: checkoutID, settings: checkoutSettings)
        checkoutProvider?.presentCheckout(withPaymentBrand: paymentBrand,
                                          loadingHandler: { (inProgress) in
            // Executed whenever SDK sends request to the server or receives the answer.
            // You can start or stop loading animation based on inProgress parameter.
        }, completionHandler: { (transaction, error) in
            if let error {
                self.showPaymentError(error: error.localizedDescription)
            } else {
                if transaction?.redirectURL != nil {
                    // Shopper was redirected to the issuer web page.
                    // Request payment status when shopper returns to the app using transaction.resourcePath or just checkout id.
                } else {
                    // Request payment status for the synchronous transaction from your server using transactionPath.resourcePath or just checkout id.
                }
            }
        }, cancelHandler: {
            // Executed if the shopper closes the payment page prematurely.
        })
        
    }
    func getCheckoutId(paymentBrand: String, userId: String, amount: String, completionHandler: @escaping (_ checkoutID: String, _ usedPaymentBrand: String) -> (), onError: @escaping (String?) -> ()) {
        let url = "url/\(paymentBrand)/\(userId)/\(amount)"
        let merchantServerRequest = URLRequest(url: URL(string: url)!)
        print(url)
        URLSession.shared.dataTask(with: merchantServerRequest as URLRequest) { (data, response, error) in
            print(JSON(data))
            if let data = data, let model = try? JSONDecoder.decodeFromData(PaymentCheckoutIdResonse.self, data: data) {
                if let newCheckoutID = model.data?.res?.id {
                completionHandler(newCheckoutID, paymentBrand)
                } else {
                print("=========>>>>>>Server")
                print("=========>>>>>>Error")
                self.result?(["Status": "Error_Payment",])
                print("=========>>>>>>result")
                onError(model.message)
                }
            } else {
                print("=========>>>>>>Error")
                self.result?(["Status": "Error",])
                print("=========>>>>>>result")
                onError(error?.localizedDescription)
            }
        }.resume()
    }
    
    func openPayment(checkoutID: String, paymentBrand: String) {
        let checkoutSettings = OPPCheckoutSettings()
        
        // Set available payment brands for your shop
        checkoutSettings.paymentBrands = [paymentBrand]
        checkoutSettings.shopperResultURL = "com.hyperpay.Demo.hyperpay-Dem.payments://result"
        checkoutProvider = OPPCheckoutProvider(paymentProvider: provider, checkoutID: checkoutID, settings: checkoutSettings)
        checkoutProvider?.delegate = self
        
        checkoutProvider?.presentCheckout(forSubmittingTransactionCompletionHandler: { (transaction, error) in
            
            guard let transaction = transaction else {
                // Handle invalid transaction, check error
                self.showPaymentError(error: error?.localizedDescription)
                return
            }
            
            self.resourcePath = transaction.resourcePath
            self.checkoutID = checkoutID
            self.paymentBrand = paymentBrand
                        
            if transaction.type == .synchronous, self.resourcePath != nil {
                print("synchronous")
                // If a transaction is synchronous, just request the payment status
                // You can use transaction.resourcePath or just checkout ID to do it
                // self.result?(self.checkoutID ?? "")
                self.result?(["Status": "Success", "checkoutID":self.checkoutID ?? ""])
                
            } else if transaction.type == .asynchronous {
                print("asynchronous")
                //  The SDK opens transaction.redirectUrl in a browser
                //  See 'Asynchronous Payments' guide for more details
                /// will call self.checkPaymentStatus() from AppDelegate
            } else {
                // Executed in case of failure of the transaction for any reason
                self.showPaymentError(error: nil)
            }
        }, cancelHandler: {
            // Executed if the shopper closes the payment page prematurely
            print("cancelHandler")
        })
    }
    
    var resourcePath: String?, checkoutID: String?, paymentBrand: String?
    
    func checkoutProviderDidFinishSafariViewController(_ checkoutProvider: OPPCheckoutProvider) {
        // Save transaction aborted state here.
    }
    
    func showPaymentError(error: String?) {
        print(error ?? "error")
        self.result?(["Status": "Error"])
    }
}

struct CheckPaymentStatusResponse: Codable {
    let data: CheckPaymentStatusModel?
    let message, status: String?
}

// MARK: - DataClass
struct CheckPaymentStatusModel: Codable {
    let statusCode, code, transID: String?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case code
        case transID = "trans_id"
    }
}

// MARK: - Welcome
struct PaymentCheckoutIdResonse: Codable {
    let status: String?
    let data: PaymentCheckoutIdResult?
    let message: String?
}

// MARK: - DataClass
struct PaymentCheckoutIdResult: Codable {
    let res: Res?
}

// MARK: - Res
struct Res: Codable {
    let ndc, timestamp, buildNumber, id: String?
    let result: Result?
}

// MARK: - Result
struct Result: Codable {
    let resultDescription, code: String?
    
    enum CodingKeys: String, CodingKey {
        case resultDescription = "description"
        case code
    }
}
