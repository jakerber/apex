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

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    let backgroundImage_name = "bg.png"
    var locationManager = CLLocationManager()
    let updateIntervalSec: Double = 5

    @IBOutlet weak var blurMain: UIVisualEffectView!
    @IBOutlet weak var mapMain: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load reached")
        
        //set background to mountains
        assignbackground()
        
        //constants
        let bounds = 0.02
        
        //create a reference to a Firebase location
        let myRootRef = FIRDatabase.database().reference()
        //myRootRef.setValue("Apex_User_Locations")
        
        //initialize map variables
        let centerLocation = CLLocationCoordinate2DMake(43.7054599, -72.2884012)
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
            
            //show
            self.mapMain.showsUserLocation = true
            
            //FOR TESTING
            myRootRef.child("USER-LOCATIONS").child("GREEN_TEST").setValue("lat:43.703377:lon:72.288570:")
            myRootRef.child("USER-LOCATIONS").child("TDX_TEST").setValue("lat:43.702726:lon:-72.291478:")
            myRootRef.child("USER-LOCATIONS").child("MCLUAGHLIN_TEST").setValue("lat:43.707410:lon:-72.286768:")
            myRootRef.child("USER-LOCATIONS").child("DEN_TEST").setValue("lat:43.700412:lon:-72.287275:")
            myRootRef.child("USER-LOCATIONS").child("DARTMOUTH_HALL_TEST").setValue("lat:43.703881:lon:-72.287111:")
            myRootRef.child("USER-LOCATIONS").child("SIG_EP_TEST").setValue("lat:43.706847:lon:-72.292341:")
            myRootRef.child("USER-LOCATIONS").child("LIB_TEST").setValue("lat:43.70556:lon:-72.288501:")
        }
    
        //add all user locations to firebase
        addUserLocations(myRootRef)
    }
    
    //got location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //add my location to firebase
        let myRootRef = FIRDatabase.database().reference().child("USER-LOCATIONS")
        let locValue = self.locationManager.location!.coordinate
        //add update locations
        myRootRef.child("\((FIRAuth.auth()?.currentUser!.uid)!)").setValue("lat:\(locValue.latitude):lon:\(locValue.longitude):")
        print("my location updated to \(locValue.latitude), \(locValue.longitude)")
    }
    
    //plot points
    func addUserLocations(rootRef: FIRDatabaseReference) {
        print("add user locs reached")
        //read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            
            //remove all annotations
            let pinsAll = self.mapMain.annotations
            self.mapMain.removeAnnotations(pinsAll)
            
            //get database
            let coords = "\(snapshot.childSnapshotForPath("USER-LOCATIONS").value)"
            print("database => \(coords)")
            let coordsArr = coords.componentsSeparatedByString(":")
            
            //loop through plot all
            var index = 1
            while (index < coordsArr.count) {
                //get lat lon
                let lat: String = coordsArr[index]
                index += 2
                let lon: String = coordsArr[index]
                index += 2
                print("found <\(lat)>, <\(lon)>")
                
                //red pin
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                self.mapMain.addAnnotation(annotation)
            }
        })
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


}

