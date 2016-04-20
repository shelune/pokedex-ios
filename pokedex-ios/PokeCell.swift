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
    
    var activePokemonImg: UIImageView!
    
    var pokemon: NSManagedObject!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 6.0
    }
    
    func configureCell(pokemon: NSManagedObject) {
        self.pokemon = pokemon
        
        nameLbl.text = self.pokemon.valueForKey("name") as? String
        thumbImg.image = UIImage(named: "\(self.pokemon.valueForKey("pokedexId")!)")
        
        var longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: "longPressCell:")
        thumbImg.addGestureRecognizer(longPressRecognizer)
        thumbImg.userInteractionEnabled = true
    }
    
    func longPressCell(sender: UIImageView) {
        var parentView = self.superview?.superview
        if let subviews = parentView?.subviews {
            for subview in subviews {
                if subview.tag == 999999 {
                    var imgViews = subview.subviews
                    for imgView in imgViews {
                        if let imgView = imgView as? UIImageView {
                            imgView.image = thumbImg.image
                        }
                    }
                }
            }
        }
    }
    
}