//
//  LocationViewController.swift
//  Apex
//
//  Created by Josh Kerber on 5/21/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class LocationViewController: UIViewController {
    
    @IBOutlet weak var statusBar: UISlider!
    @IBOutlet weak var busyLabel: UILabel!
    @IBOutlet weak var unoccupiedLabel: UILabel!
    @IBOutlet weak var apexOn: UILabel!
    @IBOutlet weak var titleBar: UIVisualEffectView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var peopleCount: UILabel!
    @IBOutlet weak var LocationMap: MKMapView!
    @IBOutlet weak var LocationName: UILabel!
    
    var locationString: String!
    var locationObject: LocationItem!
    //user count
    var userCountOnLoc = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set labels
        self.LocationName.text = self.locationObject.name
        let now = NSDate()
        let format = NSDateFormatter()
        format.timeStyle = NSDateFormatterStyle.FullStyle
        self.time.text = format.stringFromDate(now)
        format.dateFormat = "yyyy/MM/dd\nEEEE\nhh:mm:ss a\nzzzz"
        self.date.text = format.stringFromDate(now)
        
        //constants
        let bounds = 0.001
        
        //firebase data
        let myRootRef = FIRDatabase.database().reference()
        
        //mark people with red pin
        markUsersOnLoc(myRootRef)
        
        ///////////////////picking random number for now
        //let count = Int(arc4random_uniform(locationObject.maxPer) + 1)
        
        //set status bar
        statusBar!.minimumValue = 0;
        statusBar!.maximumValue = Float(locationObject.maxPer);
        
        //initialize map variables
        var centerLocation = CLLocationCoordinate2DMake(locationObject.lat, locationObject.lon)
        var mapSpan = MKCoordinateSpanMake(bounds, bounds)
        
        //set up map
        var mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        //show
        self.LocationMap.setRegion(mapRegion, animated: true)
        
        //show count
        self.peopleCount.text = "\(self.userCountOnLoc) people"
        
        //show my loc
        self.LocationMap.showsUserLocation = true
        
        //show buildings
        self.LocationMap.showsBuildings = true
        
        //show scale
        self.LocationMap.showsScale = true
        
        //standard map
        self.LocationMap.mapType = MKMapType.Standard
    }
    
    func markUsersOnLoc(rootRef: FIRDatabaseReference) {
        //Read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            
            //get database
            let coords = "\(snapshot.childSnapshotForPath("USER-LOCATIONS").value)"
            print("database => \(coords)")
            let coordsArr = coords.componentsSeparatedByString(":")
            
            //loop through plot all
            var index = 1
            while (index < coordsArr.count) {
                //check name for myself
                //                let childName = coordsArr[index].componentsSeparatedByString("\"")[1]
                //                if (childName == "+19784605401") {
                //                    continue
                //                }
                //                index += 1
                
                //get lat lon
                let lat: String = coordsArr[index]
                index += 2
                let lon: String = coordsArr[index]
                index += 2
                print("found <\(lat)>, <\(lon)>")
                
                //check if in coordinates
                if(MKMapRectContainsPoint(self.LocationMap.visibleMapRect, MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)))) {
                    //add red pin
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                    self.LocationMap.addAnnotation(annotation)
                    
                    //up user count
                    self.userCountOnLoc++
                }
            }
            //show count
            if (self.userCountOnLoc == 1) {
                self.peopleCount.text = "\(self.userCountOnLoc) person"
            } else {
                self.peopleCount.text = "\(self.userCountOnLoc) people"
            }
            self.statusBar!.setValue(Float(self.userCountOnLoc), animated: true)
        })
        self.peopleCount.reloadInputViews()
        self.statusBar!.reloadInputViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
