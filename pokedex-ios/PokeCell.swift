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
        
        if let name = self.pokemon.valueForKey("name") as? String {
            nameLbl.text = name
        }
        
        if let pokedexId = self.pokemon.valueForKey("pokedexId") as? Int {
            thumbImg.image = UIImage(named: "\(pokedexId)")
            self.tag = pokedexId
            
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(PokeCell.longPressCell(_:)))
        thumbImg.addGestureRecognizer(longPressRecognizer)
        thumbImg.userInteractionEnabled = true
    }
    
    func longPressCell(sender: UIImageView) {
        let parentView = self.superview?.superview
        if let subviews = parentView?.subviews {
            for subview in subviews {
                if subview.tag == 999999 {
                    let imgViews = subview.subviews
                    for imgView in imgViews {
                        if let imgView = imgView as? UIImageView {
                            imgView.image = thumbImg.image
                            imgView.tag = self.tag
                        }
                    }
                }
            }
        }
        
        rectifyActive(self.tag)
    }
    
    func rectifyActive(newActive: Int) {
        let cdInstance = CoreDataInit.instance
        let user = cdInstance.entityUser()
        
        let currentActiveId = cdInstance.searchForActive()
        print("current active: \(currentActiveId)")
        
        // reset and set new active
        cdInstance.searchForPoke(currentActiveId).setValue(nil, forKey: "chosen")
        cdInstance.searchForPoke(newActive).setValue(user, forKey: "chosen")
        
        print("new active: \(newActive)")
        
    }
    
}