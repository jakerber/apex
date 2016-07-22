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

    @IBOutlet weak var showInfoButton: UIButton!
    @IBOutlet weak var blurMain: UIVisualEffectView!
    @IBOutlet weak var mapMain: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapMain.delegate = self
        
        //constants
        let bounds = 0.02
        
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
        if #available(iOS 9.0, *) {
            self.mapMain.showsScale = true
        } else {
            // Fallback on earlier versions
        }
        
        //ask for permission
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            //get user location
            self.locationManager.startUpdatingLocation()
        }
        
        //simulate theta delt scene
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE1").setValue("lat:43.702755:lon:-72.291507:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE2").setValue("lat:43.702693:lon:-72.291491:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE3").setValue("lat:43.702661:lon:-72.291480:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE4").setValue("lat:43.702672:lon:-72.291494:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE5").setValue("lat:43.702689:lon:-72.291499:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE6").setValue("lat:43.702630:lon:-72.291502:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE7").setValue("lat:43.702645:lon:-72.291460:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE8").setValue("lat:43.702611:lon:-72.291471:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE9").setValue("lat:43.702628:lon:-72.291518:")
        myRootRef.child("USER-LOCATIONS").child("TDX_SCENE10").setValue("lat:43.702630:lon:-72.291524:")
        
//        //simulate campus scenes randomly
//        //LAT = 43.713166 to 43.699928
//        //LON = -72.294553 to -72.282644
//        let latConst = randomBetweenNumbers(43.713166, secondNum: 43.699928)
//        let lonConst = randomBetweenNumbers(-72.294553, secondNum: -72.282644)
//        var latRand : CGFloat
//        var lonRand : CGFloat
//        //print("got \(latRand),\(lonRand)")
//        var i = 0
//        while (i < 1000) {
//            if (i < 900) {
//                latRand = randomBetweenNumbers(43.713166, secondNum: 43.699928)
//                lonRand = randomBetweenNumbers(-72.294553, secondNum: -72.282644)
//                print("got \(latRand),\(lonRand)")
//                myRootRef.child("USER-LOCATIONS").child("TDX_SCENE\(i)").setValue("lat:\(latRand):lon:\(lonRand):")
//            } else {
//                latRand = randomBetweenNumbers(43.705200, secondNum: 43.705000)
//                lonRand = randomBetweenNumbers(-72.290200, secondNum: -72.290000)
//                print("got \(latRand),\(lonRand)")
//                myRootRef.child("USER-LOCATIONS").child("TDX_SCENE\(i)").setValue("lat:\(latRand):lon:\(lonRand):")
//            }
//            
//            i += 1
//        }
        
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
        print("my location updated to \(locValue.latitude), \(locValue.longitude)")
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
        //remove from database
        FIRDatabase.database().reference().child("\((FIRAuth.auth()?.currentUser!.uid)!)").removeValue()
        //add back to replot
        FIRDatabase.database().reference().child("\((FIRAuth.auth()?.currentUser!.uid)!)").setValue("lat:\(self.locationManager.location!.coordinate.latitude):lon:\(self.locationManager.location!.coordinate.longitude):")
    }
    
    //info button displayed on map
    @IBAction func displayInfo(sender: AnyObject) {
        //display info about app
        let alert = UIAlertController(title: "Welcome to Scene!", message: "Info text....", preferredStyle: .Alert)
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
    
    //http://stackoverflow.com/questions/25631410/swift-different-images-for-annotation
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

