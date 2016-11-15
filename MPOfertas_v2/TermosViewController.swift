//
//  TermosViewController.swift
//  MPOfertas
//
//  Created by Henrique Goncalves Leite on 11/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class TermosViewController: UIViewController {

    @IBOutlet weak var termosView: UITextView!
    @IBOutlet weak var buttonRetornar: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        buttonRetornar.layer.masksToBounds = false
        buttonRetornar.layer.cornerRadius = 3.0
        buttonRetornar.layer.shadowOffset = CGSize.zero
        buttonRetornar.layer.shadowOpacity = 0.5
        
        termosView.scrollToTop()
 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
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

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}

