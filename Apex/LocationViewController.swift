//
//  LocationViewController.swift
//  Apex
//
//  Created by Josh Kerber on 5/21/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit
import MapKit

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
        
        ///////////////////picking random number for now
        let count = Int(arc4random_uniform(locationObject.maxPer) + 1)
        
        //set status bar
        statusBar!.minimumValue = 0;
        statusBar!.maximumValue = Float(locationObject.maxPer);
        statusBar!.setValue(Float(count), animated: true)
        
        //initialize map variables
        var centerLocation = CLLocationCoordinate2DMake(locationObject.lat, locationObject.lon)
        var mapSpan = MKCoordinateSpanMake(bounds, bounds)
        
        //set up map
        var mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        //show
        self.LocationMap.setRegion(mapRegion, animated: true)
        
        //show count
        peopleCount.text = "\(count) people"
        
        //mark people

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
