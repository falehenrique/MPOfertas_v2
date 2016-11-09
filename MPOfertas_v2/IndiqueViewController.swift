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

class IndiqueViewController: UIViewController, FBSDKLoginButtonDelegate {

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
        btnCompartilhar.layer.cornerRadius = 10.0
        
        labelCodigoCompartilhamento.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //limpa campos
        txtCodigoAtivacao.text = ""
        labelCodigoCompartilhamento.text = ""

        verificaLogin()
    }
    
    func isLogin() -> Bool{
        
        let infoLocais = InfoLocais()
        let userFacebook = infoLocais.lerString(chave: "UserFacebook")
        print("===userFacebook====" + userFacebook)
        
        if FBSDKAccessToken.current() != nil && userFacebook.characters.count > 0 {
            return true
        }
        
        return false
    }
    
    
    func verificaLogin (){
    
        if isLogin() {
            btnFacebook.isHidden = true
            
            btnAtivar.isEnabled = true
            btnCompartilhar.isEnabled = true
            txtCodigoAtivacao.isEnabled = true
            
        } else {
            btnFacebook.isHidden = false
            
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
                    
                }  else {
                    print("Error \(error)")
                }

                let alertController = UIAlertController.init(title: "Login", message: "Login realizado com sucesso", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
               
            })
            
        }   else {
            let alertController = UIAlertController.init(title: "Atenção", message: "Ocorreu um erro ao realizar o login com o Facebook.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Fechar", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    let myRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, email, id"])
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("user logout")
    }
    
}
