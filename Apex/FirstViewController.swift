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

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    let backgroundImage_name = "bg.png"
    var locationManager = CLLocationManager()

    @IBOutlet weak var blurMain: UIVisualEffectView!
    @IBOutlet weak var mapMain: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background to mountains
        assignbackground()
        
        //constants
        let bounds = 0.02
        
        //create a reference to a Firebase location
        let myRootRef = FIRDatabase.database().reference()
        
        //initialize map variables
        let centerLocation = CLLocationCoordinate2DMake(43.7054599, -72.2884012)
        let mapSpan = MKCoordinateSpanMake(bounds, bounds)
        
        //set up map
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        //show
        self.mapMain.setRegion(mapRegion, animated: true)
        
        //get user location
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            //add my location to firebase
            let locValue:CLLocationCoordinate2D = locationManager.location!.coordinate
            myRootRef.setValue(":\(locValue.latitude):\(locValue.longitude):")
        }
        
        //red pin
        //let annotation = MKPointAnnotation()
        //annotation.coordinate = CLLocationCoordinate2D(latitude: 43.7054599, longitude: -72.2884012)
        //self.mapMain.addAnnotation(annotation)
        
        //show
        self.mapMain.showsUserLocation = true
        
        //stop updating
        locationManager.stopUpdatingLocation()
    
        //add all user locations to firebase
        addUserLocations(myRootRef)
    }
 
    func addUserLocations(rootRef: FIRDatabaseReference) {
        // Read data and react to changes
        rootRef.observeEventType(.Value, withBlock: {
            snapshot in
            // get loc
            let coords = "\(snapshot.value)"
            let coordsArr = coords.componentsSeparatedByString(":")
            let lat: String = coordsArr[1]
            let lon: String = coordsArr[2]
            print("let == <\(lat)> and lon == <\(lon)>")
            
            //red pin
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
            self.mapMain.addAnnotation(annotation)
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

