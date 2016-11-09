//
//  MeuCupomViewController.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 07/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class MeuCupomViewController: UIViewController {

    @IBOutlet weak var labelCupom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        labelCupom.layer.cornerRadius = 10.0
        labelCupom.clipsToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
