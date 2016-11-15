//
//  DestaqueTableViewCell.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 04/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class DestaqueTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelCupom: UILabel!
    
    @IBOutlet weak var viewProduto: UIView!
    @IBOutlet weak var imagemLogoLoja: UIImageView!
    @IBOutlet weak var labelNomeProduto: UILabel!
    @IBOutlet weak var labelPercentualDesconto: UILabel!
    @IBOutlet weak var labelPrecoInicial: UILabel!
    @IBOutlet weak var labelPrecoFinal: UILabel!
    @IBOutlet weak var imagemProduto: UIImageView!
    @IBOutlet weak var imagemDestaque: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
