//
//  MPApis.swift
//  MochiPay
//
//  Created by Wii Lin on 2019/5/15.
//

import UIKit

public class MPApis: NSObject {
    public static let shared: MPApis = MPApis()

    public func applePay(paymenyData: String, completionHandler: @escaping (Result<Void, NSError>) -> Void) {
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
        self.request(request: request) { result in
            switch result {
            case .success:
                completionHandler(.success(() as Void))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    private func request(request: URLRequest, completionHandler: @escaping (Result<[String: Any], NSError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(.failure(error! as NSError))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completionHandler(.failure(NSError.mpError(localizedDescription: "response is nil")))
                return
            }

            guard let data = data else {
                completionHandler(.failure(NSError.mpError(localizedDescription: "data is nil")))
                return
            }

            let string = String(decoding: data, as: UTF8.self)
            print("response data = \(string)")
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] else {
                completionHandler(.failure(NSError.mpError(localizedDescription: "json parse failed\n\(string)")))
                return
            }

            if 200 ... 399 ~= response.statusCode {
                completionHandler(.success(responseJSON))
            } else {
                completionHandler(.failure(NSError.mpError(localizedDescription: string)))
            }
        }

        task.resume()
    }
}

extension NSError {
    class func mpError(code: Int = 0, localizedDescription: String) -> NSError {
        print("[MPError]: \(localizedDescription)")
        return NSError(domain: "com.pklotcorp.mochipay", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
    }
}
