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
    
    func takeDamage(dmg: Int) -> Int {
        if self.hp != nil {
            if (Int(self.hp!)! - dmg > 0) {
                self.hp = "\(Int(self.hp!)! - dmg)"
                return Int(self.hp!)!
            } else {
                return 0
            }
        }
        return 0
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        let url = NSURL(string: "\(URL_BASE)\(URL_POKEMON)\(pokedexId!.integerValue)")!
        let speciesUrl = NSURL(string: "\(URL_BASE)\(URL_SPECIES)\(pokedexId!.integerValue)")!
        let alternativeUrl = NSURL(string: "\(URL_BASE_ALT)\(URL_POKEMON)\(pokedexId!.integerValue)")!
        var typeUrl = ""
        
        print(url)
        
        // fetch technical data
        Alamofire.request(.GET, url).responseJSON {
            response in
            if let result = response.result.value as? Dictionary<String, AnyObject> {
                // fetch weight
                if let weight = result["weight"] as? Float32 {
                    self.weight = weight / 10.0
                }
                
                // fetch height
                if let height = result["height"] as? Float32 {
                    self.height = height / 10.0
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
                    firstType = types[0]["type"]!!["name"] as! String
                    typeUrl = types[0]["type"]!!["url"] as! String
                    if (types.count > 1) {
                        secondType = (types[1]["type"]!!["name"] as! String)
                    }
                    self.typeFirst = firstType
                    self.typeSecond = secondType
                    
                    Alamofire.request(.GET, typeUrl).responseJSON {
                        response in
                        if let result = response.result.value {
                            if let dmgRelations = result["damage_relations"] {
                                var effectives = ""
                                var ineffectives = ""
                                if let effective = dmgRelations!["double_damage_to"] as? [AnyObject] {
                                    for (key, value) in effective.enumerate() {
                                        if let type = value["name"] as? String {
                                            effectives += type
                                        }
                                    }
                                }
                                self.effectiveVersus = effectives
                                
                                if let ineffective = dmgRelations!["half_damage_to"] as? [AnyObject] {
                                    for (key, value) in ineffective.enumerate() {
                                        if let type = value["name"] as? String {
                                            ineffectives += type
                                        }
                                    }
                                }
                                self.ineffectiveVersus = ineffectives
                                
                                print("super effective \(self.effectiveVersus)")
                                print("nve \(self.ineffectiveVersus)")
                            }
                        }
                    }
                }
            }
            completed()
        }
        
        // fetch evolution data
        Alamofire.request(.GET, alternativeUrl).responseJSON {
            response in
            if let result = response.result.value {
                // fetch name
                
                if let name = result["name"] as? String {
                    self.name = name.capitalizedString
                }
                
                // fetch stats
                if let speed = result["speed"] as? Int {
                    self.speed = "\(speed)"
                }
                
                if let attack = result["attack"] as? Int, spAtk = result["sp_atk"] as? Int {
                    self.attack = "\(max(attack, spAtk))"
                }
                
                if let defense = result["defense"] as? Int, spDef = result["sp_def"] as? Int {
                    self.defense = "\(max(defense, spDef))"
                }
                
                if let hp = result["hp"] as? Int {
                    self.hp = "\(hp)"
                }

                // check for mega evolution
                if let evolutions = result["evolutions"] as? Array<AnyObject> {
                    if evolutions.count > 0 {
                        if let _ = evolutions[0]["detail"] as? String {
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
