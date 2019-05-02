//
//  MPPaymentAuthorizationControllerDelegate.swift
//  mochipay-framework-ios
//
//  Created by Wii Lin on 2019/4/28.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import PassKit

@objc public protocol MPPaymentDelegate : class {
    
    
    /// Tells the delegate that payment authorization failure.
    @objc func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,didFailure failure: MPPaymentErrorType)
    
    
    /// Tells the delegate that payment authorization finished.
    @objc func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController)
    
    
    /// Tells the delegate that the user has authorized the payment request and asks for a result.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    
    
    /// Tells the delegate that the user is authorizing the payment request.
    @objc optional func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController)
    
    
    /// Tells the delegate that the user selected a shipping method and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void)
    
    
    /// Tells the delegate that the user selected a shipping address and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void)
    
    
    /// Tells the delegate that the payment method has changed and asks for an updated payment request.
    @objc optional func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void)
}

protocol MPPaymentDelegateProxy : class {
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController)
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    
    func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController)
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void)
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void)
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void)
}

class MPPaymentDelegateProxyClass: NSObject, PKPaymentAuthorizationControllerDelegate {
    
    weak var proxy: MPPaymentDelegateProxy!
    init(proxy: MPPaymentDelegateProxy) {
        self.proxy = proxy
    }
    
    
    public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        self.proxy?.paymentAuthorizationControllerDidFinish(controller)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.proxy?.paymentAuthorizationController(controller, didAuthorizePayment: payment, handler: completion)
    }
    
    public func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController){
        self.proxy?.paymentAuthorizationControllerWillAuthorizePayment(controller)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void){
        self.proxy?.paymentAuthorizationController(controller, didSelectShippingMethod: shippingMethod, handler: completion)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void){
        self.proxy?.paymentAuthorizationController(controller, didSelectShippingContact: contact, handler: completion)
    }
    
    public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void){
        self.proxy?.paymentAuthorizationController(controller, didSelectPaymentMethod: paymentMethod, handler: completion)
    }
}
