//
//  PokeCell.swift
//  pokedex-ios
//
//  Created by iosdev on 7.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import UIKit
import CoreData

class PokeCell: UICollectionViewCell {
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var pokemon: NSManagedObject!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 6.0
    }
    
    func configureCell(pokemon: NSManagedObject) {
        self.pokemon = pokemon
        
        nameLbl.text = self.pokemon.valueForKey("name") as? String
        thumbImg.image = UIImage(named: "\(self.pokemon.valueForKey("pokedexId")!)")
    }
}