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
    
    
    @IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var currentEvoImg: UIImageView!
    @IBOutlet weak var nextEvoLbl: UILabel!
    @IBOutlet weak var pokeIdLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var defenseLbl: UIStackView!
    @IBOutlet weak var attackLbl: UILabel!
    @IBOutlet weak var hpLbl: UILabel!
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

        
        downloadPokemonDetails { () -> () in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                if let weight = result["weight"]?.integerValue {
                    self.pokemon.setValue(String(weight), forKey: "weight")
                }
                
                if let height = result["height"]?.integerValue {
                    self.pokemon.setValue(String(height), forKey: "height")
                }
                
                if let stats = result["stats"] as? [AnyObject] {
                    if let speed = stats[0]["base_stat"] {
                        self.pokemon.setValue(String(speed), forKey: "speed")
                    }
                    //self.pokemon.setValue(result[.integerValue, forKey: "hp")
                }
                
                print("weight: \(self.pokemon.valueForKey("weight"))")
                print("height: \(self.pokemon.valueForKey("height"))")
                print("speed: \(self.pokemon.valueForKey("speed"))")
            } 
        }
    }
}
