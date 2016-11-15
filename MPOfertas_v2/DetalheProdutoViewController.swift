//
//  DetalheProdutoViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 29/10/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit
//import SwiftSpinner

class DetalheProdutoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var labelAguarde: UILabel!
    @IBOutlet weak var indicatorWebView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    @IBAction func voltarProdutos(_ sender: AnyObject) {
        let viewProdutos = self.storyboard?.instantiateViewController(withIdentifier: "viewProdutos")
        self.show(viewProdutos!, sender: self)

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let produtosViewController = storyBoard.instantiateViewController(withIdentifier: "viewProdutos") as!
            ProdutosViewController
        self.present(produtosViewController, animated:true, completion:nil)
        
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        labelAguarde.isHidden = false
        indicatorWebView.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        labelAguarde.isHidden = true
        indicatorWebView.stopAnimating()
    }
    
    func configureView() {
        
        print("URL Produto " + urlProduto!)
        let requestURL = URL(string: self.urlProduto!)
        if let urlTeste = requestURL {
            let request = URLRequest(url: urlTeste)
            webView?.scalesPageToFit = true
            webView?.loadRequest(request)
        } else {
            let alertController = UIAlertController.init(title: "Validação", message: "Não foi possível carregar o endereço.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    var urlProduto: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
}
