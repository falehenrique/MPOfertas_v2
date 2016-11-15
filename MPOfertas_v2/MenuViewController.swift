//
//  MenuViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 30/10/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var btnSobre: UIButton!
    @IBOutlet weak var btnCadastro: UIButton!

    @IBOutlet weak var imageRodape: UIImageView!
    @IBOutlet weak var buttonCompartilhar: FBSDKShareButton!
    @IBAction func testeCompartilhar(_ sender: FBSDKShareButton) {
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        InfoLocais.deletar(chave: "origem")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let content = FBSDKShareLinkContent()
        content.contentTitle = "Use meu cupom: 123456"
        
        content.contentURL = URL(string: "https://itunes.apple.com/us/app/mercado-pago-black-friday/id1174697243?l=pt&ls=1&mt=8")
        
        let mensagemCompartilhamento = "Olá! Estou participando da campanha de Black Friday do Mercado Pago.\n Baixe o app, use meu código promocional e me ajude a economizar durante Black Friday :) \n Você também receberá um código promocional e poderá ganhar até R$120 de desconto.Obrigado! \n https://play.google.com/store/apps/details?id=com.mercadopago.mpofertas"
        
        content.contentDescription = mensagemCompartilhamento
        
        //content.imageURL = URL(string: "https://mercadopago.mlstatic.com/images/desktop-logo-mercadopago.png")
        
        
        buttonCompartilhar.shareContent = content;
    
        
        // Altera contorno das imagens
        btnSobre.layer.cornerRadius = 10.0
        btnCadastro.layer.cornerRadius = 10.0
        imageRodape.layer.cornerRadius = 10.0
        
        btnCadastro.layer.masksToBounds = false
        btnCadastro.layer.cornerRadius = 3.0
        btnCadastro.layer.shadowOffset = CGSize.zero
        btnCadastro.layer.shadowOpacity = 0.5

        
        btnSobre.layer.masksToBounds = false
        btnSobre.layer.cornerRadius = 3.0
        btnSobre.layer.shadowOffset = CGSize.zero
        btnSobre.layer.shadowOpacity = 0.5
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
