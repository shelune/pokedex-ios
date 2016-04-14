//
//  iBeamon.swift
//  pokedex-ios
//
//  Created by iosdev on 6.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

class Pokemon : NSManagedObject {
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        let url = NSURL(string: "\(URL_BASE)\(URL_POKEMON)\(pokedexId!.integerValue)")!
        let speciesUrl = NSURL(string: "\(URL_BASE)\(URL_SPECIES)\(pokedexId!.integerValue)")!
        let evolutionUrl = NSURL(string: "\(URL_BASE_ALT)\(URL_POKEMON)\(pokedexId!.integerValue)")!
        
        print(url)
        
        // fetch technical data
        Alamofire.request(.GET, url).responseJSON {
            response in
            if let result = response.result.value as? Dictionary<String, AnyObject> {
                
                // fetch weight
                if let weight = result["weight"]?.integerValue {
                    self.weight = "\(weight)"
                }
                
                // fetch height
                if let height = result["height"]?.integerValue {
                    self.height = "\(height)"
                }
                
                // fetch stats
                if let stats = result["stats"] {
                    if let speed = stats[0]["base_stat"] as? Int {
                        self.speed = "\(speed)"
                    }
                    
                    if let attack = stats[4]["base_stat"] as? Int {
                        self.attack = "\(attack)"
                    }
                    
                    if let defense = stats[3]["base_stat"] as? Int {
                        self.defense = "\(defense)"
                    }
                    
                    if let hp = stats[5]["base_stat"] as? Int {
                        self.hp = "\(hp)"
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
                    self.abilities = abilityResult
                }
                
                // fetch types
                
                if let types = result["types"] as? [AnyObject] {
                    var firstType = ""
                    var secondType = ""
                    firstType = (types[0]["type"]!!["name"] as! String)
                    if (types.count > 1) {
                        secondType = (types[1]["type"]!!["name"] as! String)
                    }
                    self.typeFirst = firstType
                    self.typeSecond = secondType
                    
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
                            self.nextEvoId = 99999
                        } else {
                            if let nextEvo = evolutions[0]["resource_uri"] as? String {
                                if let range = nextEvo.rangeOfString("n/") {
                                    let evoIdString = nextEvo.substringFromIndex(range.endIndex)
                                    let evoId = Int(String(evoIdString.characters.dropLast()))
                                    self.nextEvoId = evoId
                                }
                            }
                        }
                    } else {
                        self.nextEvoId = 99999
                    }
                } else {
                    self.nextEvoId = 99999
                }
            }
            completed()
        }
        
        // fetch description data
        Alamofire.request(.GET, speciesUrl).responseJSON {
            response in
            if let result = response.result.value as? Dictionary<String, AnyObject> {
                if let flavorEntries = result["flavor_text_entries"] as? [AnyObject] {
                    flavorEntries.forEach {
                        if("\($0["language"]!!["name"] as! String)" == "en" && "\($0["version"]!!["name"] as! String)" == "alpha-sapphire") {
                            if let description = $0["flavor_text"] as? String {
                                self.descriptionText = description
                            }
                        }
                    }
                }
            }
            completed()
        }
    }    
}
