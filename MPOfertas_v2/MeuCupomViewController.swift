//
//  MeuCupomViewController.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 07/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class MeuCupomViewController: UIViewController {

    let urlAPICampanha = "https://api.mercadopago.com/v0/mgm/promotion/user/"
    
    @IBOutlet weak var labelQtdDownloads: UILabel!
    @IBOutlet weak var labelCupom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        labelCupom.layer.cornerRadius = 10.0
        labelCupom.clipsToBounds = true

        labelQtdDownloads.layer.cornerRadius = 10.0
        labelQtdDownloads.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        InfoLocais.deletar(chave: "origem")
        
       // let tabArray = self.tabBarController?.tabBar.items as NSArray!
        //let tabItem = tabArray?.object(at: 2) as! UITabBarItem
        //tabItem.badgeValue = nil
        self.tabBarItem.badgeValue = nil;
        
        let codigoAtivacaoUsuario = InfoLocais.lerString(chave: "codigoAtivacaoUsuario")

        setarQuantidadeDownloads(codigoAtivacaoUsuario: codigoAtivacaoUsuario)

        labelCupom.text = InfoLocais.lerString(chave: "meuCupom")
    
    }
    func setarQuantidadeDownloads(codigoAtivacaoUsuario: String) {
        if codigoAtivacaoUsuario.characters.count > 0 {
            recuperarQuantidadeDownloadsAPI(codigoAtivacaoUsuario)
        } else {
            labelQtdDownloads.text = "0"
        }
    }
        
    @IBAction func pesquisarIndicacoes(_ sender: AnyObject) {
        setarQuantidadeDownloads(codigoAtivacaoUsuario: InfoLocais.lerString(chave: "codigoAtivacaoUsuario"))
    }
   
    // POST
    func recuperarQuantidadeDownloadsAPI(_ codigoAtivacaoUsuario:String) {

        guard let getURL = URL(string: urlAPICampanha + codigoAtivacaoUsuario) else {
            print("Erro na requisição GET")
            return
        }
        
        let request = URLRequest(url: getURL)

        let urlSession = URLSession.shared

        // A chamada é assíncrona, e a closure é executada quando o sistema retorna o resultado
        let task = urlSession.dataTask(with: request, completionHandler: {data, response, error in
            
            if let error = error {
                print("Erro na requisição GET: \(error)")
            }

            
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                
                if let postString = String(data: data!, encoding: String.Encoding.utf8) {
                                
                    let retornoAPI = Util.convertStringToDictionary(text: postString)
                    if retornoAPI != nil {
                        print(retornoAPI!["message"]!)
                    }
                }
                
                print("Erro na resposta do HTTP")
                return
            }

            // Ler o JSON de resposta
            if let retornoAPI = String(data: data!, encoding: String.Encoding.utf8) {
                
                // Atualizar a interface
                self.performSelector(onMainThread: #selector(self.updateLabel(_:)), with: retornoAPI, waitUntilDone: false)
                
            }
            
        })
        
        // 4 - Executar a operação
        task.resume()
        
    }

    // Atender o GET
    func updateLabel(_ text: String) {
        if let retornoAPI = Util.convertStringToDictionary(text: text){
            self.labelQtdDownloads.text = String(describing: retornoAPI["qtd_download"]!)
        }
    }    
}
