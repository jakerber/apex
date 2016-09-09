//
//  SecondViewController.swift
//  Apex
//
//  Created by Josh Kerber on 5/19/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let backgroundImage_name = "bg.png"
    
    //array holding locations
    var locationsArray = [LocationItem]()
    var filteredLocations = [LocationItem]()
    var shouldShowSearchResults = false
    
    var pathCur: NSIndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background to mountains
        //assignbackground()
        
        //to hold data
        var nameStr: String!
        var latStr: Double!
        var lonStr: Double!
        var max: UInt32!
        var bound: Double!
        
        //parse file into location array
        let path = NSBundle.mainBundle().pathForResource("apexDartmouthLocationData", ofType: "txt")
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(path!) {
            do {
                let fullText = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                let locData = fullText.componentsSeparatedByString("\n") as [String]
                //get data from line
                for i in 1..<locData.count {
                    let locLine = locData[i].componentsSeparatedByString(",")
                    nameStr = "\(locLine[0])"
                    latStr = Double("\(locLine[1])")
                    lonStr = Double("\(locLine[2])")
                    max = UInt32(locLine[3])
                    bound = Double("\(locLine[4])")
                    self.locationsArray += [LocationItem(name: nameStr, lat: latStr, lon: lonStr, bounds: bound, maxPer: max)]
                }
            } catch let error as NSError {
                print("Error: \(error)")
            }
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //setting background
    func assignbackground(){
        let background = UIImage(named: backgroundImage_name)
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            return self.filteredLocations.count
        }
        else {
            return self.locationsArray.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        //watch for ! unwrap
        var location : LocationItem
        
        if (tableView == self.searchDisplayController?.searchResultsTableView) {
            location = self.filteredLocations[indexPath.row]
        }
        else {
            location = self.locationsArray[indexPath.row]
        }
        cell.textLabel?.text = location.name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //search display
        pathCur = indexPath
        self.performSegueWithIdentifier("showView", sender: self)
    }
    
    //send info
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showView") {
            if(self.searchDisplayController?.active == false) {
                //no search bar
                let indexPath = self.tableView.indexPathForSelectedRow!
                let upcoming: LocationViewController = segue.destinationViewController as! LocationViewController
                upcoming.locationObject = self.locationsArray[indexPath.row]
                self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
            } else {
                //search bar active
                let upcoming: LocationViewController = segue.destinationViewController as! LocationViewController
                upcoming.locationObject = self.filteredLocations[pathCur.row]
                self.tableView.deselectRowAtIndexPath(pathCur, animated: true)
            }
        }
    }
    
    //filter search results
    func filterContentForSearchText(searchText: String, scope: String = "Title") {
        self.filteredLocations = self.locationsArray.filter({( location : LocationItem) -> Bool in
            let stringMatch = location.name.rangeOfString(searchText)
            return stringMatch != nil
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text!, scope: "Title")
        return true // watch ! unwrap
    }
    //////////////////////////////////////
}

