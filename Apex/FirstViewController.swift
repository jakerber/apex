//
//  FirstViewController.swift
//  Apex
//
//  Created by Josh Kerber on 5/19/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation
import FirebaseAuth

class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let backgroundImage_name = "bg.png"
    var locationManager = CLLocationManager()
    let updateIntervalSec: Double = 5
    let newPinString = "mappin.png"
    var updateWithPins = 0
    var infoMsg = "With Scene, you can anonymously check the occupancy of locations around campus. Currently we only feature the campus of Dartmouth. Need help? Email dpc@dartmouth.edu."

    @IBOutlet weak var showInfoButton: UIButton!
    @IBOutlet weak var blurMain: UIVisualEffectView!
    @IBOutlet weak var mapMain: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapMain.delegate = self
        
        //constants
        let bounds = 0.015
        
        //create a reference to a Firebase location
        let myRootRef = FIRDatabase.database().reference()
        //myRootRef.setValue("Apex_User_Locations")
        
        //initialize map variables
        let centerLocation = CLLocationCoordinate2DMake(43.707286, -72.288683)
        let mapSpan = MKCoordinateSpanMake(bounds, bounds)
        
        //set up map
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        //show
        self.mapMain.setRegion(mapRegion, animated: true)
        
        //show scale
        self.mapMain.showsScale = true
        
        //ask for permission
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            //get user location
            self.locationManager.startUpdatingLocation()
        }
        
        //add all user locations to firebase
        addUserLocations(myRootRef)
    }
    
    //random double
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    //got location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //show
        self.mapMain.showsUserLocation = true
        //add my location to firebase
        let myRootRef = FIRDatabase.database().reference().child("USER-LOCATIONS")
        let locValue = self.locationManager.location!.coordinate
        //add update locations
        myRootRef.child("\((FIRAuth.auth()?.currentUser!.uid)!)").setValue("lat:\(locValue.latitude):lon:\(locValue.longitude):")
        self.locationManager.stopUpdatingLocation()
        _ = NSTimer.scheduledTimerWithTimeInterval(120.0, target: self, selector: #selector(FirstViewController.callUpdateLoc), userInfo: nil, repeats: false)
    }
    
    func callUpdateLoc() {
        self.locationManager.startUpdatingLocation()
    }
    
    //plot points
    func addUserLocations(rootRef: FIRDatabaseReference) {
        //read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            
            //remove all annotations
            let pinsAll = self.mapMain.annotations
            self.mapMain.removeAnnotations(pinsAll)
            
            //get database
            let coords = "\(snapshot.childSnapshotForPath("USER-LOCATIONS").value)"
            
            //get all coords
            let coordsArr = coords.componentsSeparatedByString(":")
            
            //loop through plot all
            var index = 1
            while (index < coordsArr.count) {
                //get lat lon
                let lat: String = coordsArr[index]
                index += 2
                let lon: String = coordsArr[index]
                index += 2
                
                //red pin
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                self.mapMain.addAnnotation(annotation)
            }
        })
    }
    
    //switch to pin view
    @IBAction func mapSwitch(sender: AnyObject) {
        self.updateWithPins = sender.selectedSegmentIndex;
        //remove prev
        FIRDatabase.database().reference().child("NULL-REFRESH").child("\((FIRAuth.auth()?.currentUser!.uid)!)").removeValue()
        //get data time
        let now = NSDate()
        let format = NSDateFormatter()
        format.timeStyle = NSDateFormatterStyle.FullStyle
        format.dateFormat = "yyyy/MM/dd_EEEE_hh:mm:ss_a_zzzz"
        //add null refresh to database
        FIRDatabase.database().reference().child("NULL-REFRESH").child("\((FIRAuth.auth()?.currentUser!.uid)!)").setValue("\(format.stringFromDate(now))")
    }
    //info button displayed on map
    @IBAction func displayInfo(sender: AnyObject) {
        //display info about app
        let alert = UIAlertController(title: "Welcome to Scene!", message: self.infoMsg, preferredStyle: .Alert)
        let action1 = UIAlertAction(title: "OK", style: .Default, handler: nil)
        //reset map
        let action2 = UIAlertAction(title: "RESET MAP", style: .Default) { _ in
            //constants
            let bounds = 0.016
            
            //initialize map variables
            let centerLocation = CLLocationCoordinate2DMake(43.707286, -72.288683)
            let mapSpan = MKCoordinateSpanMake(bounds, bounds)
            
            //set up map
            let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
            
            //show
            self.mapMain.setRegion(mapRegion, animated: true)
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //custom view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isMemberOfClass(MKUserLocation.self) || self.updateWithPins == 1) {
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
        //set custom image
        if (FIRAuth.auth()?.currentUser!.email == "anish.chadalavada.18@dartmouth.edu") {
            mainMapView!.image = UIImage(named:"ChadaSeggy.png")
        } else {
            mainMapView!.image = UIImage(named:newPinString)
            mainMapView!.alpha = 0.03
        }
        return mainMapView!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

