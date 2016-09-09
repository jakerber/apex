//
//  TableViewController.swift
//  Apex
//
//  Created by Josh Kerber on 9/9/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchResultsUpdating {
    
    //search controller
    var resultSearchController = UISearchController()
    
    //array holding locations
    var locationsArray = [LocationItem]()
    var filteredLocations = [LocationItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init search controller
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.searchBar.placeholder = "Search Locations"
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
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
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return self.filteredLocations.count
        } else {
            return self.locationsArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if (self.resultSearchController.active) {
            cell!.textLabel?.text = self.filteredLocations[indexPath.row].name
            return cell!
        } else {
            cell!.textLabel?.text = self.locationsArray[indexPath.row].name
            return cell!
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredLocations.removeAll(keepCapacity: false)
        self.filteredLocations = self.locationsArray.filter({( location : LocationItem) -> Bool in
            let stringMatch = location.name.rangeOfString(searchController.searchBar.text!)
            return stringMatch != nil
        })
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showView", sender: self)
    }
    
    //send info
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showView") {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let upcoming: LocationViewController = segue.destinationViewController as! LocationViewController
            if(self.resultSearchController.active == false) {
                //no search bar
                upcoming.locationObject = self.locationsArray[indexPath.row]
            } else {
                //search bar active
                upcoming.locationObject = self.filteredLocations[indexPath.row]
            }
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }
    }
}
