//
//  CategoriaTableViewCell.swift
//  MPOfertas_v2
//
//  Created by Henrique Goncalves Leite on 06/11/16.
//  Copyright © 2016 Mercado Pago. All rights reserved.
//

import UIKit

class CategoriaTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDescricao: UILabel!
    @IBOutlet weak var imagemIcone: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
