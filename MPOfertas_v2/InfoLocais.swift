//
//  InfoLocais.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 08/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import Foundation


class InfoLocais {
    
    let userDefaults = UserDefaults.standard
    
    func gravarString(valor:String, chave:String) {
        userDefaults.set(valor, forKey: chave)
        userDefaults.synchronize()
    
    }

    func deletar(chave:String) {
        userDefaults.removeObject(forKey: chave)
    }
    
    func lerString(chave:String) -> String {
        
        if let retorno = userDefaults.object(forKey: chave) {
            return retorno as! String
        }
        
        return ""
        
    }
    
    func gravarArray(valor:[String], chave:String) {
        userDefaults.set(valor, forKey: chave)
        userDefaults.synchronize()
        
    }
    
    func lerArray(chave:String) -> [String] {
        
        if let retorno = userDefaults.object(forKey: chave) {
            return retorno as! [String]
        }
        
        return [""]
        
    }
    
}
