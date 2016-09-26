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
        let path = Bundle.main.path(forResource: "apexDartmouthLocationData", ofType: "txt")
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: path!) {
            do {
                let fullText = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                let locData = fullText.components(separatedBy: "\n") as [String]
                //get data from line
                for i in 1..<locData.count {
                    let locLine = locData[i].components(separatedBy: ",")
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.filteredLocations.count
        } else {
            return self.locationsArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell?
        cell!.textLabel!.font = UIFont(name:"HelveticaNeue-UltraLight", size:18)
        
        if (self.resultSearchController.isActive) {
            cell!.textLabel?.text = self.filteredLocations[(indexPath as NSIndexPath).row].name
            return cell!
        } else {
            cell!.textLabel?.text = self.locationsArray[(indexPath as NSIndexPath).row].name
            return cell!
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredLocations.removeAll(keepingCapacity: false)
        self.filteredLocations = self.locationsArray.filter({( location : LocationItem) -> Bool in
            let stringMatch = location.name.range(of: searchController.searchBar.text!)
            return stringMatch != nil
        })
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showView", sender: self)
    }
    
    //send info
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showView") {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let upcoming: LocationViewController = segue.destination as! LocationViewController
            if(self.resultSearchController.isActive == false) {
                //no search bar
                upcoming.locationObject = self.locationsArray[(indexPath as NSIndexPath).row]
            } else {
                //search bar active
                upcoming.locationObject = self.filteredLocations[(indexPath as NSIndexPath).row]
            }
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            self.resultSearchController.isActive = false
        }
    }
}
