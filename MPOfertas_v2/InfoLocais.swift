//
//  InfoLocais.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 08/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import Foundation


class InfoLocais {    
    static let userDefaults = UserDefaults.standard
    
    static func gravarString(valor:String, chave:String) {
        userDefaults.set(valor, forKey: chave)
        userDefaults.synchronize()
    
    }

    static func deletar(chave:String) {
        userDefaults.removeObject(forKey: chave)
    }
    
    static func lerString(chave:String) -> String {
        
        if let retorno = userDefaults.object(forKey: chave) {
            return retorno as! String
        }
        
        return ""
        
    }
    
    static func gravarArray(valor:[String], chave:String) {
        userDefaults.set(valor, forKey: chave)
        userDefaults.synchronize()
        
    }
    
    static func gravarArray(valor:NSMutableArray, chave:String) {
        userDefaults.set(valor, forKey: chave)
        userDefaults.synchronize()
        
    }
    static func lerArray(chave:String) -> [String]? {
        
        if let retorno = userDefaults.object(forKey: chave) {
            return retorno as? [String]
        }
        
        return nil
        
    }
    
}
