//
//  PokemonDetailVC.swift
//  pokedex-ios
//
//  Created by iosdev on 8.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AVFoundation

class PokemonDetailVC: UIViewController {
    
    
    // label properties
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var defenseLbl: UILabel!
    @IBOutlet weak var attackLbl: UILabel!
    @IBOutlet weak var hpLbl: UILabel!
    @IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var currentEvoImg: UIImageView!
    @IBOutlet weak var nextEvoLbl: UILabel!
    @IBOutlet weak var pokeIdLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var abilityLbl: UILabel!
    @IBOutlet weak var mainTypeImg: UIImageView!
    @IBOutlet weak var secondaryTypeImg: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    // function properties
    var musicPlayer: AVAudioPlayer!
    var pokemon: Pokemon!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLbl.text = "\(pokemon.valueForKey("name") as! String)"
        mainImg.image = UIImage(named: "\(pokemon.valueForKey("pokedexId")!.integerValue)")
        pokeIdLbl.text = "No. \(pokemon.valueForKey("pokedexId")!.integerValue)"
        currentEvoImg.image = UIImage(named: "\(pokemon.valueForKey("pokedexId")!.integerValue)")
        
        
        pokemon.downloadPokemonDetails { () -> () in
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

    @IBAction func backBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func updateUI() {
        if let height = self.pokemon.valueForKey("height") {
            heightLbl.text = "\(height as! String)"
        }
        
        if let weight = self.pokemon.valueForKey("weight") {
            weightLbl.text = "\(weight as! String)"
        }
        
        if let attack = self.pokemon.valueForKey("attack") {
            attackLbl.text = "\(attack as! String)"
        }
        
        if let defense = self.pokemon.valueForKey("defense") {
            defenseLbl.text = "\(defense as! String)"
        }
        
        if let speed = self.pokemon.valueForKey("speed") {
            speedLbl.text = "\(speed as! String)"
        }
        
        if let hp = self.pokemon.valueForKey("hp") {
            hpLbl.text = "\(hp as! String)"
        }
        
        if let desc = self.pokemon.valueForKey("descriptionText") {
            descriptionLbl.text = "\(desc as! String)"
        }
        
        if let ability = self.pokemon.valueForKey("abilities") {
            abilityLbl.text = "\(ability as! String)"
        }
        
        if let typeFirst = self.pokemon.valueForKey("typeFirst") {
            mainTypeImg.image = UIImage(named: "type-\(typeFirst as! String)")
        }
        
        if let typeSecond = self.pokemon.valueForKey("typeSecond") as? String {
            if typeSecond == "" || typeSecond.isEmpty {
                secondaryTypeImg.alpha = 0.0
            } else {
                secondaryTypeImg.image = UIImage(named: "type-\(typeSecond)")
            }
        }
        
        if let nextEvo = self.pokemon.valueForKey("nextEvoId") as? Int {
            if nextEvo == 99999 {
                nextEvoImg.image = UIImage(named: "99999")
            } else {
                nextEvoImg.image = UIImage(named: "\(nextEvo)")
            }
        }
    }
    
    @IBAction func soundBtnPressed(sender: UIButton) {
        if musicPlayer.playing {
            musicPlayer.stop()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
}
