//
//  MPPaymentHandler.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/4/24.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import PassKit

@objc public protocol MPPaymentDelegate : class {
    
    /// Tells the delegate that payment authorization failure.
    @objc func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,didFailure failure: NSError)
    
    /// Tells the delegate that payment authorization success.
    @objc func paymentAuthorizationControllerDidSuccess(_ controller: PKPaymentAuthorizationController)
    
    
    /// Tells the delegate that payment authorization finished.
    @objc func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController)
    
    
    /// Tells the delegate that the user has authorized the payment request and asks for a result.
//    @objc func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    
    
    /// Tells the delegate that the user is authorizing the payment request.
    @objc optional func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController)
    
    
    /// Tells the delegate that the user selected a shipping method and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void)
    
    
    /// Tells the delegate that the user selected a shipping address and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void)
    
    
    /// Tells the delegate that the payment method has changed and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void)
}



public class MPPaymentHandler: NSObject {
    private var delegate: MPPaymentDelegate?
    private var paymentSummaryItems: [PKPaymentSummaryItem] = []
    private var shippingMethods: [PKShippingMethod] = []
    
    public class func applePayStatus(supportedNetworks: [PKPaymentNetwork], capabilties: PKMerchantCapability) -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks,capabilities: capabilties));
    }
    
    public func startPayment(delegate: MPPaymentDelegate, paymentRequest: PKPaymentRequest) {
        self.delegate = delegate
        self.paymentSummaryItems = paymentRequest.paymentSummaryItems
        self.shippingMethods = paymentRequest.shippingMethods ?? []
        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController.delegate = self
        paymentController.present(completion: { (presented: Bool) in
            if presented {
                NSLog("Presented payment controller")
            } else {
                NSLog("Failed to present payment controller")
                self.delegate?.paymentAuthorizationController(paymentController, didFailure: NSError.init(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey:"Failed to present payment controller"]))
            }
        })
    }
}
extension MPPaymentHandler: PKPaymentAuthorizationControllerDelegate {
    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        print(#function)
        self.delegate?.paymentAuthorizationControllerDidFinish(controller)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print(#function)
        let string = String(decoding: payment.token.paymentData, as: UTF8.self)
        MPApis.shared.applePay(paymenyData: string) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                completion(.init(status: .success, errors: nil))
                self.delegate?.paymentAuthorizationControllerDidSuccess(controller)
            case .failure(let error):
                completion(.init(status: .failure, errors: [error]))
                self.delegate?.paymentAuthorizationController(controller, didFailure: error)
            }
        }

    }
    
    public func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        print(#function)
        self.delegate?.paymentAuthorizationControllerWillAuthorizePayment?(controller)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        print(#function)
        if nil == self.delegate?.paymentAuthorizationController?(controller, didSelectShippingMethod: shippingMethod, handler: { (update) in
            self.paymentSummaryItems = update.paymentSummaryItems
            completion(update)
        }) {
            let update: PKPaymentRequestShippingMethodUpdate = PKPaymentRequestShippingMethodUpdate.init(paymentSummaryItems: self.paymentSummaryItems)
            completion(update)
        }
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
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
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
        print(#function)
        if nil == self.delegate?.paymentAuthorizationController?(controller, didSelectPaymentMethod: paymentMethod, handler: { (update) in
            self.paymentSummaryItems = update.paymentSummaryItems
        }) {
            let update: PKPaymentRequestPaymentMethodUpdate = PKPaymentRequestPaymentMethodUpdate.init(paymentSummaryItems: self.paymentSummaryItems)
            completion(update)
        }
    }
    
}
