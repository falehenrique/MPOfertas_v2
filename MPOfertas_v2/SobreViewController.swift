//
//  SobreViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 18/10/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit
//import SwiftSpinner

class SobreViewController: UIViewController, UIWebViewDelegate {
    
    var URLPath = "https://www.mercadopago.com.br/ajuda"
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAdressURL()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonExit(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //SwiftSpinner.show(delay: 0.5, title: "Aguarde...", animated: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //SwiftSpinner.hide()
    }
    
    func loadAdressURL() {
        
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
