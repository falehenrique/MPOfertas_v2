//
//  Util.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 09/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import Foundation

class Util {
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
