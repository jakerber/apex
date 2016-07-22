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
    @IBOutlet weak var peopleCount: UILabel!
    @IBOutlet weak var LocationMap: MKMapView!
    @IBOutlet weak var LocationName: UILabel!
    
    var locationString: String!
    var locationObject: LocationItem!
    //user count
    var userCountOnLoc = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peopleCount.hidden = true
        
        //set labels
        self.LocationName.text = self.locationObject.name
        let now = NSDate()
        let format = NSDateFormatter()
        format.timeStyle = NSDateFormatterStyle.FullStyle
        self.time.text = format.stringFromDate(now)
        format.dateFormat = "yyyy/MM/dd\nEEEE\nhh:mm:ss a\nzzzz"
        self.apexOn.text = "Scene data for \(format.stringFromDate(now))"
        
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
        if #available(iOS 9.0, *) {
            self.LocationMap.showsScale = true
        } else {
            // Fallback on earlier versions
        }
        
        //standard map
        self.LocationMap.mapType = MKMapType.Hybrid
        
        //mark people with red pin
        markUsersOnLoc(myRootRef)
        
        //show count
        self.peopleCount.hidden = false
        self.peopleCount.text = "\(self.userCountOnLoc) people"
    }
    
    func markUsersOnLoc(rootRef: FIRDatabaseReference) {
        //read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            
            //remove all previous annotations
            let annotationsCur = self.LocationMap.annotations
            self.LocationMap.removeAnnotations(annotationsCur)
            self.userCountOnLoc = 0
            
            //get database
            let coords = "\(snapshot.childSnapshotForPath("USER-LOCATIONS").value)"
            
            //print database
            //print("database => \(coords)")
            let coordsArr = coords.componentsSeparatedByString(":")
            
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
                    //add red pin
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
//                    self.LocationMap.addAnnotation(annotation)
                    
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
    
    //custom view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isMemberOfClass(MKUserLocation.self) {
            return nil
        }
        //get map view
        let idNull = "null"
        var mainMapView = mapView.dequeueReusableAnnotationViewWithIdentifier(idNull)
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
