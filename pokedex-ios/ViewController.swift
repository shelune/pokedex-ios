//
//  ViewController.swift
//  pokedex-ios
//
//  Created by iosdev on 6.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Alamofire

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var collectionDex: UICollectionView!
    
    @IBOutlet weak var activePokemonImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemons = [NSManagedObject]()
    var filteredPokemons = [NSManagedObject]()
    var musicPlayer: AVAudioPlayer!
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up delegation & data source
        collectionDex.delegate = self
        
        collectionDex.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        
        // reset transparent background for collection view
        collectionDex.backgroundColor = UIColor.clearColor()
        
        // parsing data from csv
        parsePokemonCSV()
        
        // music
        initAudio()
    }
    
    func initAudio() {
        let path = NSBundle.mainBundle().pathForResource("main-theme", ofType: "mp3")
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path!)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        } catch _ as NSError {
            print("Error with Audio?")
        }
    }
    
    func initUser() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityUser = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
        
        // declare user
        let user = NSManagedObject(entity: entityUser!, insertIntoManagedObjectContext: managedContext)
        
        // declare starter
        let bulbasaur = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        bulbasaur.setValue(1, forKey: "pokedexId")
        bulbasaur.setValue("Bulbasaur", forKey: "name")
        user.setValue(bulbasaur, forKey: "active")
        activePokemonImg.image = UIImage(named: "\(bulbasaur.valueForKey("pokedexId")!.integerValue)")
        
        // declare caught?
        let charmander = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        charmander.setValue(4, forKey: "pokedexId")
        charmander.setValue("Charmander", forKey: "name")
        
        let squirtle = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
        squirtle.setValue(7, forKey: "pokedexId")
        squirtle.setValue("Squirtle", forKey: "name")
        
        bulbasaur.setValue(user, forKey: "owned")
        squirtle.setValue(user, forKey: "owned")
        charmander.setValue(user, forKey: "owned")
        
        // create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        
        // add sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "pokedexId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // do fetch request
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            var ownedIds = [Int]()
            
            for managedObject in result {
                if managedObject.valueForKey("owned") != nil {
                    if let ownedId = managedObject.valueForKey("pokedexId") as? Int {
                        ownedIds.append(ownedId)
                    }
                }
            }
            
            pokemons = pokemons.filter({
                ownedIds.contains(($0.valueForKey("pokedexId") as! Int))
            })
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var pokemon: NSManagedObject!
        if inSearchMode {
            pokemon = filteredPokemons[indexPath.row]
        } else {
            pokemon = pokemons[indexPath.row]
        }
        
        performSegueWithIdentifier("PokemonDetailVC", sender: pokemon)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
                
            let pokemon: NSManagedObject!
            pokemon = pokemons[indexPath.row]
            cell.configureCell(pokemon)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemons.count
        }
        return pokemons.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    // Parsing data
    func parsePokemonCSV() {
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        do {
            let csv = try CSVParser(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]?.capitalizedString
                let entityPokemon = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
                let poke = NSManagedObject(entity: entityPokemon!, insertIntoManagedObjectContext: managedContext)
                
                poke.setValue(name, forKey: "name")
                poke.setValue(pokeId, forKey: "pokedexId")
                
                pokemons.append(poke)
            }
        } catch {
            print("Error with parsing CSV?")
        }
    }
    
    // filter search phrase
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || (searchBar.text?.isEmpty)! {
            inSearchMode = false
            view.endEditing(true)
            collectionDex.reloadData()
        } else {
            inSearchMode = true
            let searchPhrase = searchBar.text!.lowercaseString
            filteredPokemons = pokemons.filter({
                ($0.valueForKey("name") as! String).lowercaseString.rangeOfString(searchPhrase) != nil
            })
            collectionDex.reloadData()
        }
    }
    
    // remove the keyboard when clicked search
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // turn on / off music
    @IBAction func musicBtnPressed(sender: UIButton) {
        if musicPlayer.playing {
            musicPlayer.stop()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    // go back to scanning view
    @IBAction func backBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // prepare for detail view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let pokemon = sender as? Pokemon {
                    detailsVC.pokemon = pokemon
                    detailsVC.musicPlayer = musicPlayer
                }
            }
        }
    }
}

