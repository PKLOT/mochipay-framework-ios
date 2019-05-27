//
//  MPMainViewController.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/4/24.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import UIKit
import PassKit
import MochiPay
class MPMainViewController: UIViewController {
    
    let model:MPMainViewModel =  MPMainViewModel()
    @IBOutlet weak var paymentButtonContentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let result = MPPaymentHandler.applePayStatus(supportedNetworks: [.masterCard, .visa], capabilties: .capability3DS)
        var button: PKPaymentButton?
        if result.canMakePayments {
            button = PKPaymentButton.init(paymentButtonType: .buy, paymentButtonStyle: .black)
            button?.addTarget(self, action: #selector(MPMainViewController.payPressed), for: .touchUpInside)
        } else if result.canSetupCards {
            button = PKPaymentButton.init(paymentButtonType: .setUp, paymentButtonStyle: .black)
            button?.addTarget(self, action: #selector(MPMainViewController.setupPressed), for: .touchUpInside)
        }
        if button != nil {
            self.view.addSubview(button!)
            button!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([button!.topAnchor.constraint(equalTo: paymentButtonContentView.topAnchor),
                                         button!.bottomAnchor.constraint(equalTo: paymentButtonContentView.bottomAnchor),
                                        button!.trailingAnchor.constraint(equalTo: paymentButtonContentView.trailingAnchor),
                                        button!.leadingAnchor.constraint(equalTo: paymentButtonContentView.leadingAnchor)])
        }
    }
    @objc func payPressed(sender: AnyObject) {
        model.paymentHandler.startPayment(delegate: self, paymentRequest: self.model.paymentRequest(paymentSummaryItems: self.model.defaultSummaryItems(subtotalAmount: 1, discountAmount: 2), shippingMethods: self.model.defaultShippingMethod()))
    }
    
    @objc func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
}

extension MPMainViewController: MPPaymentDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didFailure failure: NSError) {
        self.presentAlert(error: failure, action: nil, completion: nil)
    }
    
    func paymentAuthorizationControllerDidSuccess(_ controller: PKPaymentAuthorizationController) {
    }
    

    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        var items: [PKPaymentSummaryItem] = self.model.defaultSummaryItems(subtotalAmount: 1, discountAmount: 2)
        if APShippingMethod.paperInvoice.identifier ==  shippingMethod.identifier {
            let paperItem = PKPaymentSummaryItem(label: "Paper Invoice", amount: NSDecimalNumber(string: "1"), type: .final)
            items.append(paperItem)
        }
        completion(PKPaymentRequestShippingMethodUpdate.init(paymentSummaryItems: self.model.totalItems(items: items)))
    }

}


extension UIViewController {
    func presentAlert(error: NSError?, action: ((UIAlertAction) -> Swift.Void)?, completion: (() -> Swift.Void)?) {
        guard let error = error else {
            return
        }
        self.presentAlert(title: "error",
                          message: error.localizedDescription,
                          action: ("ok", action),
                          completion: completion)
    }
    
    func presentAlert(title: String?, message: String?, action : (title: String?, actionClosure: ((UIAlertAction) -> Swift.Void)?), completion: (() -> Swift.Void)?) {
        
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction.init(title: action.title, style: .default, handler: action.actionClosure)
        alert.addAction(action)
        self.present(alert, animated: true, completion: completion)
    }
}

