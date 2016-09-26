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
import FirebaseAuth

class LocationViewController: UIViewController {
    
    @IBOutlet weak var statusBar: UISlider!
    @IBOutlet weak var busyLabel: UILabel!
    @IBOutlet weak var unoccupiedLabel: UILabel!
    @IBOutlet weak var apexOn: UILabel!
    @IBOutlet weak var titleBar: UIVisualEffectView!
    @IBOutlet weak var time: UILabel!
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
        let now = Date()
        let format = DateFormatter()
        format.timeStyle = DateFormatter.Style.medium
        self.time.text = format.string(from: now)
        format.dateFormat = "yyyy/MM/dd\nEEEE\nhh:mm:ss a\nzzzz"
        self.apexOn.text = "\(format.string(from: now))"
        
        //firebase data
        let myRootRef = FIRDatabase.database().reference()
        
        //set status bar
        statusBar!.minimumValue = 0;
        statusBar!.maximumValue = Float(locationObject.maxPer);
        
        //initialize map variables
        let centerLocation = CLLocationCoordinate2DMake(locationObject.lat, locationObject.lon)
        let mapSpan = MKCoordinateSpanMake(locationObject.bounds, locationObject.bounds)
        
        //set up map
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        //show
        self.LocationMap.setRegion(mapRegion, animated: true)
        
        //show my loc
        self.LocationMap.showsUserLocation = true
        
        //show buildings
        self.LocationMap.showsBuildings = true
        
        //show scale
        self.LocationMap.showsScale = true
        
        //standard map
        self.LocationMap.mapType = MKMapType.hybrid
        
        //mark people with red pin
        markUsersOnLoc(myRootRef)
    }
    
    func markUsersOnLoc(_ rootRef: FIRDatabaseReference) {
        //read data and react to changes
        rootRef.observe(.value, with: {
            snapshot in
            
            //remove all previous annotations
            let annotationsCur = self.LocationMap.annotations
            self.LocationMap.removeAnnotations(annotationsCur)
            self.userCountOnLoc = 0
            
            //get database
            let coords = "\(snapshot.childSnapshot(forPath: "USER-LOCATIONS").value)"
            
            //get all coords
            let coordsArr = coords.components(separatedBy: ":")
            
            //loop through plot all
            var index = 1
            while (index < coordsArr.count) {
                
                //get lat lon
                let lat: String = coordsArr[index]
                index += 2
                let lon: String = coordsArr[index]
                index += 2
                
                //check if in coordinates of mini map
                if(MKMapRectContainsPoint(self.LocationMap.visibleMapRect, MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)))) {
                    //up user count
                    self.userCountOnLoc += 1
                }
            }
            //set val of bar
            self.statusBar!.setValue(Float(self.userCountOnLoc), animated: true)
        })
        self.statusBar!.reloadInputViews()
    }
    
    //custom view
    func mapView(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isMember(of: MKUserLocation.self) {
            return nil
        }
        //get map view
        let idNull = "null"
        var mainMapView = mapView.dequeueReusableAnnotationView(withIdentifier: idNull)
        if mainMapView == nil {
            mainMapView = MKAnnotationView(annotation: annotation, reuseIdentifier: idNull)
            mainMapView!.canShowCallout = true
        } else {
            mainMapView!.annotation = annotation
        }
        //set pin drop
        return mainMapView!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
