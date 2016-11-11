//
//  IndiqueViewController.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 07/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseInstanceID


class IndiqueViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate  {

    let urlAPICampanha = "https://api.mercadopago.com/v0/mgm/tracking/user"
    
    @IBOutlet weak var labelInformativo: UILabel!
    // Variável para controle da subida/descida da view
    var isViewUp: Bool = false
    
    var buttonFacebook: FBSDKLoginButton = FBSDKLoginButton()
    
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var txtCodigoAtivacao: UITextField!
    @IBOutlet weak var btnAtivar: UIButton!
    @IBOutlet weak var btnCompartilhar: UIButton!
    @IBOutlet weak var labelCodigoCompartilhamento: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        buttonFacebook.delegate = self
        buttonFacebook.readPermissions = ["public_profile","email","user_friends"]
        
        btnAtivar.layer.cornerRadius = 10.0
        labelCodigoCompartilhamento.layer.cornerRadius = 10.0
        txtCodigoAtivacao.layer.cornerRadius = 10.0
        btnCompartilhar.layer.cornerRadius = 10.0

        // Cria notificações para subida/descida da tela
        NotificationCenter.default.addObserver(self, selector: #selector(IndiqueViewController.tecladoUp(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IndiqueViewController.tecladoDown(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
    }

    // MARK: - Delegates - Eventos, mensagens e notificações enviados pelos elementos da tela
    // MARK: - Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }

    // Força saída do teclado ao tocar em qualquer lugar da tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications Selectors
    func tecladoUp(_ sender: Notification) {
        if !isViewUp {
            // Calcula o número de pontos para descer a tela
            let alturaTela = self.view.frame.size.height
            let pontos = calculaPontos(alturaTela)
            self.view.frame.origin.y -= CGFloat(pontos)
            isViewUp = true
        }
    }
    
    func tecladoDown(_ sender: Notification) {
        //navigationController?.navigationBarHidden = false
        if isViewUp {
            let alturaTela = self.view.frame.size.height
            let pontos = calculaPontos(alturaTela)
            self.view.frame.origin.y += CGFloat(pontos)
            isViewUp = false
        }
    }

    @IBAction func shareSocial(_ sender: AnyObject) {
        
        if (labelCodigoCompartilhamento.text?.isEmpty)! {
            let alertController = UIAlertController.init(title: "Atenção", message: "Você ainda não possui um código válido.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        let mensagemCompartilhamento = "Olá! Estou participando da campanha de Black Friday do Mercado Pago.\n Baixe o app, use meu código promocional e me ajude a economizar durante Black Friday :) Meu código é:"+labelCodigoCompartilhamento.text!+"Você também receberá um código promocional e poderá ganhar até R$120 de desconto. \n Para baixar o aplicativo e receber descontos, acesse: \n https://play.google.com/store/apps/details?id=com.mercadopago.mpofertas \n Obrigado!"
        

        let objectsToShare = [mensagemCompartilhamento]
            
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
        //let excludedActivities = [UIActivityType.postToFlickr, UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.mail, UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToTencentWeibo]
            
        //activityController.excludedActivityTypes = excludedActivities

        present(activityController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        //limpa campos
        txtCodigoAtivacao.text = ""
        labelCodigoCompartilhamento.text = ""

        verificaLogin()
        definirBotaoAtivado()
    }
    
    func getTokenPush() -> String {
        if let tokenPush = FIRInstanceID.instanceID().token() {
            print("MEU TOKEN \(tokenPush)")
            return tokenPush
        }
        
        return ""
        
    }
    
    func isLogin() -> Bool{
        
        let userFacebook = InfoLocais.lerString(chave: "UserFacebook")
        
        if FBSDKAccessToken.current() != nil && userFacebook.characters.count > 0 {
            return true
        }
        
        return false
    }
    
    // Atender o POST
    func atualizarLabelCodigo(_ text: String) {

        let retornoAPI = Util.convertStringToDictionary(text: text)

        if retornoAPI != nil, let codigoUsuario = retornoAPI?["code"] {
            self.labelCodigoCompartilhamento.text = codigoUsuario as? String
            
            InfoLocais.deletar(chave: "codigoAtivacaoUsuario")
            InfoLocais.gravarString(valor: codigoUsuario as! String, chave: "codigoAtivacaoUsuario")
            
        } else {
            mensagemAlerta("erro", "")
        }
    }
    
    func verificaLogin (){
    
        if isLogin() {
            btnFacebook.isHidden = true
            labelInformativo.isHidden = true

            
            btnAtivar.isEnabled = true
            btnCompartilhar.isEnabled = true
            txtCodigoAtivacao.isEnabled = true
            
            
            recuperarCodigoCampanha()
            
        } else {
            btnFacebook.isHidden = false
            labelInformativo.isHidden = false
            
            btnAtivar.isEnabled = false
            btnCompartilhar.isEnabled = false
            txtCodigoAtivacao.isEnabled = false
        }
        
    }
    
    @IBAction func loginFacebook(_ sender: AnyObject) {
        
        buttonFacebook.sendActions(for: UIControlEvents.touchUpInside)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error == nil {
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,email"], tokenString: result.token.tokenString, version: nil, httpMethod: "GET")
            
            req!.start(completionHandler: { (connection, result, error) in
                
                if error == nil {
                    
                    let result = result as? NSDictionary
                    
                    if  let email = result?["email"] {
                        UserDefaults.standard.set(email, forKey: "UserFacebook")
                    }
                    
                    if  let userID = result?["id"] {
                        UserDefaults.standard.set(userID, forKey: "UserID")
                    }
                    
                    self.verificaLogin ()
                    
                }  else {
                    print("Error \(error)")
                }
            })
            
        }   else {
            self.mensagemAlerta("erro_facebook", "")
        }
        
    }
    
    let myRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, id"])
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logout")
    }
    
    
    func recuperarCodigoCampanha() {
        //teste

        let codigoCampanha = InfoLocais.lerString(chave: "codigoAtivacaoUsuario")
        
        if codigoCampanha.isEmpty {
            recuperarCodigoCampanhaAPI()
        } else {
            labelCodigoCompartilhamento.text = codigoCampanha
        }
        
    }
    
    
    @IBAction func ativarCodigo(_ sender: AnyObject) {
        
        if (txtCodigoAtivacao.text?.isEmpty)! {
            let alertController = UIAlertController.init(title: "Atenção", message: "Por favor informe um código válido.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if InfoLocais.lerString(chave: "codigoAtivado") != nil && InfoLocais.lerString(chave: "codigoAtivado") .characters.count > 0 {
            let alertController = UIAlertController.init(title: "Atenção", message: "Código promocional já informado.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            ativarCodigoCampanhaAPI(friendCode: txtCodigoAtivacao.text!.uppercased())
        }
    
        // "Esconde" o teclado caso ele esteja visível
        view.endEditing(true)
    }

    // POST
    func ativarCodigoCampanhaAPI(friendCode:String) {
        
        // Validar a URL
        guard let postURL = URL(string: urlAPICampanha) else {
            print("Erro na URL POST")
            return
        }
        
        // Seguindo os passos
        var request = URLRequest(url: postURL)
        let urlSession = URLSession.shared
        
        print("TOKEN PUSH == = " + getTokenPush())
        
        //InfoLocais.lerString(chave: "UserFacebook") as AnyObject,
        
        // No caso do POST, iremos definir alguns parâmetros
        let postParams: [String: AnyObject] = ["email": "teste@gmail.com" as AnyObject,
                                               "firebaseID": getTokenPush() as AnyObject,
                                               "friendCode": friendCode as AnyObject,
                                               "promotion" : 26 as AnyObject,]
        
        
        // Mais alguns parâmetros de configuração
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
        } catch {
            mensagemAlerta("erro_ativar", "")
        }
        
        // Data
        let task = urlSession.dataTask(with: request) {
            data, response, error in
            
            // Tratar o retorno
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                if let postString = String(data: data!, encoding: String.Encoding.utf8) {
                    
                    print(postString)
                    
                    let retornoAPI = Util.convertStringToDictionary(text: postString)
                    if retornoAPI != nil {
                        print(retornoAPI!["message"]!)
                        self.mensagemAlerta("erro_ativar", (retornoAPI!["message"]!) as! String)
                    } else {
                        self.mensagemAlerta("erro_ativar", "")
                    }
                    
                } else {
                    self.mensagemAlerta("erro_ativar", "")
                }
                return
            }
            
            // Ler o JSON de resposta
            //if let postString = String(data: data!, encoding: String.Encoding.utf8) {
                //let retornoAPI = Util.convertStringToDictionary(text: postString)
                //(retornoAPI!["message"]!) 
                
            // Atualizar a interface
            let alertController = UIAlertController.init(title: "Parabéns!", message: "Seu código foi ativado com sucesso.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
                
            InfoLocais.gravarString(valor: friendCode, chave: "codigoAtivado")
            
            self.definirBotaoAtivado()
                
            //}
            
        }
        // Executar o comando
        task.resume()
        
    }
    
    private func definirBotaoAtivado() {
        if InfoLocais.lerString(chave: "codigoAtivado") != nil && InfoLocais.lerString(chave: "codigoAtivado") .characters.count > 0 {
            btnAtivar.setTitle("Ativado", for: .normal)
            btnAtivar.isEnabled = false
            txtCodigoAtivacao.isEnabled = false
            txtCodigoAtivacao.text = InfoLocais.lerString(chave: "codigoAtivado")
        //    btnAtivar.tintColor = UIColor.green
        } else {
            btnAtivar.setTitle("Ativar", for: .normal)
            btnAtivar.isEnabled = true
            txtCodigoAtivacao.isEnabled = true
            txtCodigoAtivacao.text = ""
        }
    }
    
    // POST
    func recuperarCodigoCampanhaAPI() {
        
        // Validar a URL
        guard let postURL = URL(string: urlAPICampanha) else {
            print("Erro na URL POST")
            return
        }
        
        // Seguindo os passos
        var request = URLRequest(url: postURL)
        let urlSession = URLSession.shared
        
        // No caso do POST, iremos definir alguns parâmetros
        let postParams: [String: AnyObject] = ["email": "teste@gmail.com" as AnyObject,
                                               "firebaseID": getTokenPush() as AnyObject,
                                               "friendCode": "" as AnyObject,
                                               "promotion" : 26 as AnyObject,]
        
        
        // Mais alguns parâmetros de configuração
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postParams, options: JSONSerialization.WritingOptions())
            
            print(request.httpBody?.description)
            print(request.httpBody!)
            
        } catch {
            mensagemAlerta("erro", "")
        }
        
        // Data
        let task = urlSession.dataTask(with: request) {
            data, response, error in
            
            // Tratar o retorno
            
            // Primeiro o código HTTP
            //  Verificar se retorno do protocolo foi OK
            //  Response = 200
            
            guard let realResponse = response as? HTTPURLResponse, realResponse.statusCode == 200 else {
                if let postString = String(data: data!, encoding: String.Encoding.utf8) {
                    let retornoAPI = Util.convertStringToDictionary(text: postString)
                    if retornoAPI != nil {
                        print(retornoAPI!["message"]!)
                        self.mensagemAlerta("alerta", (retornoAPI!["message"]!) as! String)
                    } else {
                        self.mensagemAlerta("erro", "")
                    }
                    
                } else {
                    self.mensagemAlerta("erro", "")
                }
                return
            }
            
            // Ler o JSON de resposta
            if let postString = String(data: data!, encoding: String.Encoding.utf8) {
                
                // Atualizar a interface
                self.performSelector(onMainThread: #selector(self.atualizarLabelCodigo(_:)), with: postString, waitUntilDone: false)
                
            }
            
        }
        // Executar o comando
        task.resume()
        
    }


    func mensagemAlerta(_ tipo:String, _ mensagem:String){
        
        switch tipo {
        case "erro":
            let alertController = UIAlertController.init(title: "Atenção", message: "Não foi possível localizar seu código", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        case "erro_facebook":
            let alertController = UIAlertController.init(title: "Atenção", message: "Ocorreu um erro ao realizar o login com o Facebook.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        case "alerta":
            let alertController = UIAlertController.init(title: "Atenção", message: mensagem, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)

        case "erro_ativar":
            let alertController = UIAlertController.init(title: "Atenção", message: mensagem, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        default:
            let alertController = UIAlertController.init(title: "Atenção", message: "Não foi possível localizar seu código", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    // MARK: - Funções de Apoio
    
    /* Calcula o número de pontos que a tela deve subir quando aparecer o teclado
     O número calculado dependerá do tamanho do dispositivo
     iPhone 4/4s -       480.0 pontos de altura
     iPhone 5C   -       548.0 pontos de altura
     iPhone 5/5S -       568.0 pontos de altura
     iPhone 6/6S -       667.0 pontos de altura
     iPhone 6/6s Plus -  736.0 pontos de altura
     iPad (todos) -      1024.0 pontos de altura
     */
    func calculaPontos(_ tamanhoTela: CGFloat) -> Int {
        switch tamanhoTela {
        case 480.0:
            return 210
        case 548.0...568.0:
            return 150
        case 667.0:
            return 100
        case 736.0...1024.0:
            return 0
        default:
            return 0
        }
    }
    
    
}
