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

class PokemonDetailVC: UIViewController {
    
    
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
    @IBOutlet weak var typeSecond: UIImageView!
    @IBOutlet weak var typeFirst: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    var pokemon: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLbl.text = "\(pokemon.valueForKey("name") as! String)"
        mainImg.image = UIImage(named: "\(pokemon.valueForKey("pokedexId")!.integerValue)")
        pokeIdLbl.text = "No. \(pokemon.valueForKey("pokedexId")!.integerValue)"

        
        downloadPokemonDetails { () -> () in
            
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
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        let url = NSURL(string: "\(URL_BASE)\(URL_POKEMON)\(pokemon.valueForKey("pokedexId")!.integerValue)")!
        Alamofire.request(.GET, url).responseJSON {
            response in
            if let result = response.result.value as? Dictionary<String, AnyObject> {
                
                // fetch weight
                if let weight = result["weight"]?.integerValue {
                    self.pokemon.setValue("\(Float(weight) / 10.0) kg", forKey: "weight")
                }
                
                // fetch height
                if let height = result["height"]?.integerValue {
                    self.pokemon.setValue("\(Float(height) / 10.0) m", forKey: "height")
                }
                
                // fetch stats
                if let stats = result["stats"] {
                    if let speed = stats[0]["base_stat"] as? Int {
                        self.pokemon.setValue(String(speed), forKey: "speed")
                    }
                    
                    if let attack = stats[4]["base_stat"] as? Int {
                        self.pokemon.setValue(String(attack), forKey: "attack")
                    }
                    
                    if let defense = stats[3]["base_stat"] as? Int {
                        self.pokemon.setValue(String(defense), forKey: "defense")
                    }
                    
                    if let hp = stats[5]["base_stat"] as? Int {
                        self.pokemon.setValue(String(hp), forKey: "hp")
                    }
                }
                
                // fetch abilities
                if let abilities = result["abilities"] as? [AnyObject]{
                    var abilityResult = ""
                    var abilityList = Array<AnyObject>()
                    for (_, value) in abilities.enumerate() {
                        abilityList.append(value)
                    }
                    for (_, value) in abilityList.enumerate() {
                        if let abilityName = value["ability"]!!["name"] {
                            abilityResult += "\((abilityName as! String).capitalizedString) / "
                        }
                    }
                    self.pokemon.setValue(abilityResult, forKey: "abilities")
                }
                
                print("weight: \(self.pokemon.valueForKey("weight") as! String)")
                print("height: \(self.pokemon.valueForKey("height") as! String)")
                print("speed: \(self.pokemon.valueForKey("speed") as! String)")
                print("attack: \(self.pokemon.valueForKey("attack") as! String)")
                print("defense: \(self.pokemon.valueForKey("defense") as! String)")
                print("hp: \(self.pokemon.valueForKey("hp") as! String)")
                print("abilities: \(self.pokemon.valueForKey("abilities") as! String)")
            } 
        }
    }
}
