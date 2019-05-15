//
//  MPMainViewModel.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/4/30.
//  Copyright © 2019 Pklotcorp. All rights reserved.
//

import UIKit
import PassKit
import MochiPay
enum APShippingMethod: String {
    case electronicInvoice
    case paperInvoice
    
    var identifier: String{
        return self.rawValue
    }
    
    var label: String{
        switch self {
        case .electronicInvoice: return "Electronic Invoice"
        case .paperInvoice: return "Paper Invoice"
        }
    }
    
    var detail: String{
        switch self {
        case .electronicInvoice: return ""
        case .paperInvoice: return ""
        }
    }
    
    var amount: NSDecimalNumber{
        switch self {
        case .electronicInvoice: return NSDecimalNumber(string: "0.0")
        case .paperInvoice: return NSDecimalNumber(string: "1.0")
        }
    }
}

class MPMainViewModel: NSObject {
    let paymentHandler = MPPaymentHandler()
    
    func defaultSummaryItems(subtotalAmount: Float, discountAmount: Float) -> [PKPaymentSummaryItem] {
        var paymentSummaryItems: [PKPaymentSummaryItem] = []
        if subtotalAmount > 0 {
            let subtotalItem = PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(string: "\(subtotalAmount)"), type: .final)
            paymentSummaryItems.append(subtotalItem)
        }
        if discountAmount > 0 {
            let discountItem = PKPaymentSummaryItem(label: "Discount", amount: NSDecimalNumber(string: "\(discountAmount)"), type: .final)
            paymentSummaryItems.append(discountItem)
        }
        
        return paymentSummaryItems
    }
    
    func defaultShippingMethod() -> [PKShippingMethod] {        
        let electronicInvoice: PKShippingMethod = PKShippingMethod.init(label: APShippingMethod.electronicInvoice.label,
                                                                        amount: APShippingMethod.electronicInvoice.amount)
        electronicInvoice.identifier = APShippingMethod.electronicInvoice.identifier
        electronicInvoice.detail = APShippingMethod.electronicInvoice.detail
        
        let paperInvoice: PKShippingMethod = PKShippingMethod.init(label: APShippingMethod.paperInvoice.label,
                                                                   amount: APShippingMethod.paperInvoice.amount)
        paperInvoice.identifier = APShippingMethod.paperInvoice.identifier
        paperInvoice.detail = APShippingMethod.paperInvoice.detail
        
        return [electronicInvoice, paperInvoice]
    }
    
    func totalItems(items:[PKPaymentSummaryItem]) -> [PKPaymentSummaryItem]{
        var items = items
        var total: Float = 0
        for item in items {
            total += item.amount.floatValue
        }
        items.append(PKPaymentSummaryItem(label: "Mochi Pay", amount: NSDecimalNumber(string: "\(total)"), type: .final))
        return items
    }
    
    func paymentRequest(paymentSummaryItems: [PKPaymentSummaryItem], shippingMethods: [PKShippingMethod]) -> PKPaymentRequest {
        let request: PKPaymentRequest = PKPaymentRequest.init()
        request.countryCode = "TW"
        request.currencyCode = "TWD"
        request.supportedNetworks = [.masterCard, .visa, .JCB]
        request.merchantCapabilities = .capability3DS
        request.merchantIdentifier = MPConfiguration.MPMerchant.identififer
        request.paymentSummaryItems = self.totalItems(items: paymentSummaryItems)
        request.requiredShippingContactFields = [.postalAddress, .emailAddress, .name, .phoneNumber]
        request.shippingMethods = shippingMethods
        return request
    }
}
