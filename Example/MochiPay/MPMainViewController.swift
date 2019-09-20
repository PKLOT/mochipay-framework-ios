//
//  MPMainViewController.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/4/24.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import MochiPay
import PassKit
import UIKit
class MPMainViewController: UIViewController {
    let model: MPMainViewModel = MPMainViewModel()
    @IBOutlet var paymentButtonContentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let result = MPPaymentHandler.applePayStatus(supportedNetworks: [.masterCard, .visa], capabilties: .capability3DS)
        var button: PKPaymentButton?
        if result.canMakePayments {
            button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
            button?.addTarget(self, action: #selector(MPMainViewController.payPressed), for: .touchUpInside)
        } else if result.canSetupCards {
            button = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
            button?.addTarget(self, action: #selector(MPMainViewController.setupPressed), for: .touchUpInside)
        }
        if button != nil {
            view.addSubview(button!)
            button!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([button!.topAnchor.constraint(equalTo: paymentButtonContentView.topAnchor),
                                         button!.bottomAnchor.constraint(equalTo: paymentButtonContentView.bottomAnchor),
                                         button!.trailingAnchor.constraint(equalTo: paymentButtonContentView.trailingAnchor),
                                         button!.leadingAnchor.constraint(equalTo: paymentButtonContentView.leadingAnchor)])
        }
    }

    @objc func payPressed(sender: AnyObject) {
        model.paymentHandler.startPayment(delegate: self, paymentRequest: model.paymentRequest(paymentSummaryItems: model.defaultSummaryItems(subtotalAmount: 1, discountAmount: 2), shippingMethods: model.defaultShippingMethod()))
    }

    @objc func setupPressed(sender: AnyObject) {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
}

extension MPMainViewController: MPPaymentDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didFailure failure: NSError) {
        presentAlert(error: failure, action: nil, completion: nil)
    }

    func paymentAuthorizationControllerDidSuccess(_ controller: PKPaymentAuthorizationController) {}

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
    }

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectShippingMethod shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        var items: [PKPaymentSummaryItem] = model.defaultSummaryItems(subtotalAmount: 1, discountAmount: 2)
        if APShippingMethod.paperInvoice.identifier == shippingMethod.identifier {
            let paperItem = PKPaymentSummaryItem(label: "Paper Invoice", amount: NSDecimalNumber(string: "1"), type: .final)
            items.append(paperItem)
        }
        completion(PKPaymentRequestShippingMethodUpdate(paymentSummaryItems: model.totalItems(items: items)))
    }
}

extension UIViewController {
    func presentAlert(error: NSError?, action: ((UIAlertAction) -> Swift.Void)?, completion: (() -> Swift.Void)?) {
        guard let error = error else {
            return
        }
        presentAlert(title: "error",
                     message: error.localizedDescription,
                     action: ("ok", action),
                     completion: completion)
    }

    func presentAlert(title: String?, message: String?, action: (title: String?, actionClosure: ((UIAlertAction) -> Swift.Void)?), completion: (() -> Swift.Void)?) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: action.title, style: .default, handler: action.actionClosure)
        alert.addAction(action)
        present(alert, animated: true, completion: completion)
    }
}
