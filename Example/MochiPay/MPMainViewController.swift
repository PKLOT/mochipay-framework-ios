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
            NSLayoutConstraint.activate([button!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                                         button!.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)])
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
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didFailure failure: Error) {
        print("error")
    }
    
    func paymentAuthorizationControllerDidSuccess(_ controller: PKPaymentAuthorizationController) {
        print("下班")
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

