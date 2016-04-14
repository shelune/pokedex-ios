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
    var pokemon: NSManagedObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLbl.text = "\(pokemon.valueForKey("name") as! String)"
        mainImg.image = UIImage(named: "\(pokemon.valueForKey("pokedexId")!.integerValue)")
        pokeIdLbl.text = "No. \(pokemon.valueForKey("pokedexId")!.integerValue)"
        currentEvoImg.image = UIImage(named: "\(pokemon.valueForKey("pokedexId")!.integerValue)")
        
        downloadPokemonDetails { () -> () in
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
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        let url = NSURL(string: "\(URL_BASE)\(URL_POKEMON)\(pokemon.valueForKey("pokedexId")!.integerValue)")!
        let speciesUrl = NSURL(string: "\(URL_BASE)\(URL_SPECIES)\(pokemon.valueForKey("pokedexId")!.integerValue)")!
        let evolutionUrl = NSURL(string: "\(URL_BASE_ALT)\(URL_POKEMON)\(pokemon.valueForKey("pokedexId")!.integerValue)")!
        
        // fetch technical data
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
                if let abilities = result["abilities"] as? [AnyObject] {
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
                
                // fetch types
                
                if let types = result["types"] as? [AnyObject] {
                    var firstType = ""
                    var secondType = ""
                    firstType = (types[0]["type"]!!["name"] as! String)
                    if (types.count > 1) {
                        secondType = (types[1]["type"]!!["name"] as! String)
                    }
                    self.pokemon.setValue(firstType, forKey: "typeFirst")
                    self.pokemon.setValue(secondType, forKey: "typeSecond")
                    
                }
                completed()
            }
        }
        
        // fetch evolution data
        Alamofire.request(.GET, evolutionUrl).responseJSON {
            response in
            if let result = response.result.value {
                // check for mega evolution
                if let evolutions = result["evolutions"] as? Array<AnyObject> {
                    if evolutions.count > 0 {
                        if let mega = evolutions[0]["detail"] as? String {
                            self.pokemon.setValue(99999, forKey: "nextEvoId")
                        } else {
                            if let nextEvo = evolutions[0]["resource_uri"] as? String {
                                if let range = nextEvo.rangeOfString("n/") {
                                    let evoIdString = nextEvo.substringFromIndex(range.endIndex)
                                    let evoId = Int(String(evoIdString.characters.dropLast()))
                                    self.pokemon.setValue(evoId, forKey: "nextEvoId")
                                }
                            }
                        }
                    } else {
                        self.pokemon.setValue(99999, forKey: "nextEvoId")
                    }
                } else {
                    self.pokemon.setValue(99999, forKey: "nextEvoId")
                }
            }
            completed()
            print("next evo id: \(self.pokemon.valueForKey("nextEvoId")!.integerValue)")
        }
        
        // fetch description data
        Alamofire.request(.GET, speciesUrl).responseJSON {
            response in
            if let result = response.result.value as? Dictionary<String, AnyObject> {
                if let flavorEntries = result["flavor_text_entries"] as? [AnyObject] {
                    flavorEntries.forEach {
                        if("\($0["language"]!!["name"] as! String)" == "en" && "\($0["version"]!!["name"] as! String)" == "alpha-sapphire") {
                            if let description = $0["flavor_text"] as? String {
                                self.pokemon.setValue(description, forKey: "descriptionText")
                            }
                        }
                    }
                }
            }
            completed()
        }
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
