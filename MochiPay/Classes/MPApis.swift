//
//  MPApis.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/5/15.
//

import UIKit

public class MPApis: NSObject {
    public static let shared: MPApis = MPApis()
    
    public func applePay(paymenyData: String, completionHandler: @escaping (Result<Void, NSError>) -> Void){
        let json: [String: Any] = ["token_json": paymenyData,
                                   "order_type": "parking_order",
                                   "order_number": "order_number_test",
                                   "merchant_uid": "0e455bfa-c7a3-4ba9-8067-5c28a5ebd6ff"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://api-alpha.mochipay.xyz/v1/apple_pay/pay")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // insert json data to the request
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completionHandler(.failure(error! as NSError))
                return
            }
        
            let string = String(decoding: data, as: UTF8.self)
            print("response data = \(string)")
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("responseJSON = \(responseJSON)")
                completionHandler(.success(() as Void))
            } else {
                completionHandler(.failure(NSError.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: string])))
            }
            
            
        }
        
        task.resume()
    }
}
