//
//  CadastroViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 18/10/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit
//import SwiftSpinner

class CadastroViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var aguarde: UILabel!
    @IBOutlet var webView: UIWebView!
    @IBOutlet weak var carregando: UIActivityIndicatorView!
    
    var URLPath = "https://registration.mercadopago.com.br/registration-mp?mode=mp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAdressURL()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func exitController(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        carregando.startAnimating()
        
        aguarde.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        carregando.stopAnimating()
        
             aguarde.isHidden = true
    }
    
    func loadAdressURL() {
        
        print("entrou aqui")
        
        let requestURL = URL(string: URLPath)
        if let urlTeste = requestURL {
            let request = URLRequest(url: urlTeste)
            webView.loadRequest(request)
        } else {
            let alertController = UIAlertController.init(title: "Validação", message: "Não foi possível carregar o endereço.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
