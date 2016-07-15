//
//  LoginViewController.swift
//  Apex
//
//  Created by Josh Kerber on 7/14/16.
//  Copyright © 2016 Dartmouth Programming Collaborative. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var ResetButton: UIButton!
    @IBOutlet weak var EnterApexButton: UIButton!
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var DartmouthEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sign out reset
        try! FIRAuth.auth()?.signOut()
        
        //check if user has stored email
        if let email = NSUserDefaults.standardUserDefaults().stringForKey("userEmail"){
            //user has email stored
            print("The user has email stored: <\(email)>")
            
            //attempt to view data with email stored
            FIRAuth.auth()?.signInWithEmail("\(email)", password: "Apex-pw", completion: { error, authData in
                //we are now logged in
                print("AUTH ===> \(FIRAuth.auth()?.currentUser?.emailVerified)")
                if (FIRAuth.auth()?.currentUser?.emailVerified == true) {
                    //user verified!
                        
                    // store email if verified
                    let data = NSUserDefaults.standardUserDefaults()
                    data.setValue(email.lowercaseString, forKey: "userEmail")
                    print("email \(email.lowercaseString) verified")
                        
                    //enter apex
                    self.performSegueWithIdentifier("userAuth", sender: self)
                } else {
                    //displays
                    self.loadingWheel.hidden = true
                    self.DartmouthEmail.placeholder = "Dartmouth Email"
                    self.DartmouthEmail.userInteractionEnabled = true
                    self.EnterButton.hidden = false
                    self.EnterButton.userInteractionEnabled = true
                    print("email \(email) NOT verified [no verification]")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "userAuth") {
            //nothing
        }
    }
    
    //manual override
    @IBAction func EnterTestingAction(sender: UIButton) {
        self.performSegueWithIdentifier("userAuth", sender: self)
    }
    
    @IBAction func EnterClicked(sender: AnyObject!) {
        print("enter clicked")
        //displays
        self.EnterButton.hidden = true
        self.loadingWheel.hidden = false
        //no data entered
        if (DartmouthEmail.text == "") {
            //alert user to enter data
            let alert = UIAlertController(title: "Missing Email", message: "Please enter your Dartmouth email address", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            //displays
            self.EnterButton.hidden = false
            self.loadingWheel.hidden = true
        } else {
            //data has been entered
            
            //check for @dartmouth.edu
            let emailArr = DartmouthEmail.text!.componentsSeparatedByString("@")
            if (emailArr.count < 2 || emailArr.count > 2) {
                print("\(DartmouthEmail.text) invalid domain")
                
                //alert user to enter data
                let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                //displays
                self.EnterButton.hidden = false
                self.loadingWheel.hidden = true
            }
            else {
                let domain = "@\(emailArr[1])"
                if(domain.caseInsensitiveCompare("@dartmouth.edu") != NSComparisonResult.OrderedSame){
                    
                    print("\(domain) invalid domain")
                    //alert user to enter data
                    let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                    //displays
                    self.EnterButton.hidden = false
                    self.loadingWheel.hidden = true
                    
                }
                else {
                    print("\(DartmouthEmail.text) is valid")
                    //save email to NSUser Defaults
                    let data = NSUserDefaults.standardUserDefaults()
                    data.setValue(DartmouthEmail.text?.lowercaseString, forKey: "userEmail")
                    print("\(DartmouthEmail.text?.lowercaseString) saved")
                    
                    //create user -- https://github.com/firebase/quickstart-ios/blob/master/authentication/AuthenticationExampleSwift/EmailViewController.swift
                    
                    FIRAuth.auth()?.createUserWithEmail(DartmouthEmail.text!, password: "Apex-pw") { (user, error) in
                        //verify email address
                        print("user created \(self.DartmouthEmail.text)")
                        FIRAuth.auth()?.signInWithEmail(self.DartmouthEmail.text!, password: "Apex-pw", completion: nil)
                        FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion(nil)
                        //clear text and show verification
                        self.DartmouthEmail.text = ""
                        self.DartmouthEmail.placeholder = "Email verification sent"
                        self.DartmouthEmail.userInteractionEnabled = false
                        self.EnterButton.hidden = true
                        self.EnterApexButton.hidden = false
                        self.loadingWheel.hidden = true
                        
                        //alert user to enter data
                        let alert = UIAlertController(title: "Email Verification Sent", message: "It may take a few minutes to arrive", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                        //displays
                        self.ResetButton.hidden = false
                        self.ResetButton.userInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func ResetAction(sender: UIButton) {
        self.ResetButton.hidden = true
        self.EnterButton.hidden = false
        self.EnterApexButton.hidden = true
        self.DartmouthEmail.placeholder = "Dartmouth Email"
        self.DartmouthEmail.userInteractionEnabled = true
    }
    
    @IBAction func EnterApexAction(sender: UIButton) {
        self.EnterApexButton.hidden = true
        self.loadingWheel.hidden = false
        //get stored email
        let emailAttempt = NSUserDefaults.standardUserDefaults().stringForKey("userEmail")
        //user has email stored
        print("The user has email stored: <\(emailAttempt)>")
            
        //attempt to view data with email stored
        FIRAuth.auth()?.signInWithEmail(emailAttempt!, password: "Apex-pw", completion: nil)
        FIRDatabase.database().reference().observeEventType(.Value, withBlock: { snapshot in
        
            //user verified!
        
            // store email if verified
            let data = NSUserDefaults.standardUserDefaults()
            data.setValue(emailAttempt?.lowercaseString, forKey: "userEmail")
            self.loadingWheel.hidden = true
            self.performSegueWithIdentifier("userAuth", sender: self)
            
            }, withCancelBlock: { error in
        
                //user not verified
        
                //alert user to enter data
                let alert = UIAlertController(title: "\(emailAttempt!) Not Yet Verified", message: "Check your email for a message from us, or try again in a few moments.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
                //displays
                self.loadingWheel.hidden = true
                self.EnterApexButton.hidden = false
                        
            })
    }

}
