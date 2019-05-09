//
//  MPPaymentHandler.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/4/24.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import PassKit
public class MPPaymentHandler: NSObject {
    private var delegate: MPPaymentDelegate?
    private var proxy: MPPaymentDelegateProxyClass?
    private var paymentSummaryItems: [PKPaymentSummaryItem] = []
    private var shippingMethods: [PKShippingMethod] = []
    
    public class func applePayStatus(supportedNetworks: [PKPaymentNetwork], capabilties: PKMerchantCapability) -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks,capabilities: capabilties));
    }
    
    public func startPayment(delegate: MPPaymentDelegate, paymentRequest: PKPaymentRequest) {
        self.delegate = delegate
        self.proxy = MPPaymentDelegateProxyClass.init(proxy: self)
        self.paymentSummaryItems = paymentRequest.paymentSummaryItems
        self.shippingMethods = paymentRequest.shippingMethods ?? []
        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController.delegate = proxy
        paymentController.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                self.delegate?.paymentAuthorizationController(paymentController, didFailure: .failedPresentPaymentController)
            }
        })
    }
}
extension MPPaymentHandler: MPPaymentDelegateProxy {
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        print(#function)
        controller.dismiss {
            DispatchQueue.main.async {
                self.delegate?.paymentAuthorizationControllerDidFinish(controller)
            }
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print(#function)
        if nil != self.delegate?.paymentAuthorizationController?(controller, didAuthorizePayment: payment, handler: { (result) in
            completion(result)
        }) {
            completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
        }
    }
    
    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        print(#function)
        self.delegate?.paymentAuthorizationControllerWillAuthorizePayment?(controller)
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        print(#function)
        if nil == self.delegate?.paymentAuthorizationController?(controller, didSelectShippingMethod: shippingMethod, handler: { (update) in
            self.paymentSummaryItems = update.paymentSummaryItems
            completion(update)
        }) {
            let update: PKPaymentRequestShippingMethodUpdate = PKPaymentRequestShippingMethodUpdate.init(paymentSummaryItems: self.paymentSummaryItems)
            completion(update)
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        print(#function)
        
        if nil == self.delegate?.paymentAuthorizationController?(controller, didSelectShippingContact: contact, handler: { (update) in
            self.paymentSummaryItems = update.paymentSummaryItems
            self.shippingMethods = update.shippingMethods
            completion(update)
        }) {
            let update: PKPaymentRequestShippingContactUpdate = PKPaymentRequestShippingContactUpdate.init(errors: nil, paymentSummaryItems: self.paymentSummaryItems, shippingMethods: self.shippingMethods)
            completion(update)
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
        print(#function)
        if nil == self.delegate?.paymentAuthorizationController?(controller, didSelectPaymentMethod: paymentMethod, handler: { (update) in
            self.paymentSummaryItems = update.paymentSummaryItems
        }) {
            let update: PKPaymentRequestPaymentMethodUpdate = PKPaymentRequestPaymentMethodUpdate.init(paymentSummaryItems: self.paymentSummaryItems)
            completion(update)
        }
    }
    
}
