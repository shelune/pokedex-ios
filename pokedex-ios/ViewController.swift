//
//  ViewController.swift
//  pokedex-ios
//
//  Created by iosdev on 6.4.2016.
//  Copyright © 2016 iosdev. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var collectionDex: UICollectionView!
    @IBOutlet weak var collectionTeam: UICollectionView!
    
    var pokemons = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up delegation & data source for 2 collections
        collectionDex.delegate = self
        collectionTeam.delegate = self
        
        collectionDex.dataSource = self
        collectionTeam.dataSource = self
        
        // reset transparent background for collection view
        collectionDex.backgroundColor = UIColor.clearColor()
        collectionTeam.backgroundColor = UIColor.clearColor()
        
        // parsing data from csv
        parsePokemonCSV()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            
            let pokemon = pokemons[indexPath.row]
            cell.configureCell(pokemon)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 1) {
            return pokemons.count
        } else {
            return 3
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    // Parsing
    
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
                let entity = NSEntityDescription.entityForName("Pokemon", inManagedObjectContext: managedContext)
                let poke = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                poke.setValue(name, forKey: "name")
                poke.setValue(pokeId, forKey: "pokedexId")
                
                pokemons.append(poke)
            }
        } catch {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        /*
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        
        //3
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
                pokemons = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
         */
    }
}

