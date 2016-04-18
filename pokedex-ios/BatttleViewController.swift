//
//  BatttleViewController.swift
//  pokedex-ios
//
//  Created by iosdev on 17.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import UIKit

class BatttleViewController: UIViewController {
    
    // properties
    var opponentPokemon: Pokemon!
    var activePokemon: Pokemon!
    
    // interaction properties
    @IBOutlet weak var opponentImg: UIImageView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var opponentDefValue: UILabel!
    @IBOutlet weak var opponentHPValue: UILabel!
    @IBOutlet weak var opponentAtkValue: UILabel!
    
    
    @IBOutlet weak var activeImg: UIImageView!
    @IBOutlet weak var activeName: UILabel!
    @IBOutlet weak var activeAtkValue: UILabel!
    @IBOutlet weak var activeHPValue: UILabel!
    @IBOutlet weak var activeDefValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(opponentPokemon)
        opponentImg.image = UIImage(named: "\(opponentPokemon.valueForKey("pokedexId")!.integerValue)")
        
        
        opponentPokemon.downloadPokemonDetails { () -> () in
            self.updateUI()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateUI() {
        if let name = self.opponentPokemon.valueForKey("name") {
            opponentName.text = "\(name as! String)"
        }
        
        if let attack = self.opponentPokemon.valueForKey("attack") {
            opponentAtkValue.text = "\(attack as! String)"
        }
        
        if let defense = self.opponentPokemon.valueForKey("defense") {
            opponentDefValue.text = "\(defense as! String)"
        }
        
        if let hp = self.opponentPokemon.valueForKey("hp") {
            opponentHPValue.text = "\(hp as! String)"
        }

    }
}
