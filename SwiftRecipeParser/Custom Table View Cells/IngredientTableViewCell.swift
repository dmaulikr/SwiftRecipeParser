//
//  IngredientTableViewCell.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 4/28/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
