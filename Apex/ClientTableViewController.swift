//
//  ClientTableViewController.swift
//  Apex
//
//  Created by Josh Kerber on 5/20/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit

class ClientTableViewController: UITableViewController {
    
    var dictClient = [String:String]()
    var arrayClient = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("clients", ofType: "txt")
        
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(path!) {
            
            do {
                let fullText = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                
                let readings = fullText.componentsSeparatedByString("\n") as [String]
                
                for i in 1..<readings.count {
                    
                    let clientData = readings[i].componentsSeparatedByString("\t")
                    
                    dictClient["FirstName"] = "\(clientData[0])"
                    dictClient["LastName"] = "\(clientData[1])"
                    arrayClient.addObject(dictClient)
                    
                    
                }
                
            } catch let error as NSError {
                print("Error: \(error)")
            }
            
        }
        
        self.title = "Number of Clients: \(arrayClient.count)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayClient.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let client = arrayClient[indexPath.row]
        
        cell.textLabel?.text = "\(client.objectForKey("FirstName")!)"
        
        return cell
    }

}
