//
//  MenuViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 30/10/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var btnSobre: UIButton!
    @IBOutlet weak var btnCadastro: UIButton!
    
    @IBOutlet weak var btnConhecaSites: UIButton!
    @IBOutlet weak var imageRodape: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Altera contorno das imagens
        btnSobre.layer.cornerRadius = 10.0
        btnCadastro.layer.cornerRadius = 10.0
        btnConhecaSites.layer.cornerRadius = 10.0
        imageRodape.layer.cornerRadius = 10.0
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
