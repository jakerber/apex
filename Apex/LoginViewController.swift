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
    
    
    @IBOutlet weak var whiteLine: UIImageView!
    @IBOutlet weak var iconMail: UIImageView!
    @IBOutlet weak var dpc_logo: UIImageView!
    @IBOutlet weak var emailVerMsg: UITextField!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var DartmouthEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //displays
        //self.dpc_logo
        self.iconMail.alpha = 0.4
        self.whiteLine.alpha = 0.3
        self.EnterButton.layer.cornerRadius = 10
        self.DartmouthEmail.textColor = UIColor.lightGrayColor()
        //sign out reset
        try! FIRAuth.auth()?.signOut()
        
        //check if user has stored email
        if let email = NSUserDefaults.standardUserDefaults().stringForKey("userEmail"){
            //user has email stored
            print("The user has email stored: <\(email)>")
            if ("\(email)" == "") {
                //no valid email with NSUser
                print("no email stored")
                //displays
                self.loadingWheel.hidden = true
                self.DartmouthEmail.text = "Dartmouth Email"
                self.DartmouthEmail.userInteractionEnabled = true
                self.EnterButton.hidden = false
                self.EnterButton.userInteractionEnabled = true
            } else {
                //displays
                self.loadingWheel.hidden = true
                self.DartmouthEmail.userInteractionEnabled = true
//                self.DartmouthEmail.text = email
                self.DartmouthEmail.text = "Dartmouth Email"
                self.EnterButton.hidden = false
                self.EnterButton.userInteractionEnabled = true
            }
        } else {
            //no email with NSUser
            print("no email stored")
            //displays
            self.loadingWheel.hidden = true
            self.DartmouthEmail.text = "Dartmouth Email"
            self.DartmouthEmail.userInteractionEnabled = true
            self.EnterButton.hidden = false
            self.EnterButton.userInteractionEnabled = true
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
        self.emailVerMsg.hidden = true
        self.EnterButton.hidden = true
        self.loadingWheel.hidden = false
        //no data entered
        if (DartmouthEmail.text == "") {
            
            //no data has been entered
            
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
                
                //not a valid email address
                
                let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                //displays
                self.EnterButton.hidden = false
                self.loadingWheel.hidden = true
            } else {
                //check for valid dartmouth email
                let domain = "@\(emailArr[1])"
                if(domain.caseInsensitiveCompare("@dartmouth.edu") != NSComparisonResult.OrderedSame){
                    
                    //not a valid dartmouth email
                    
                    print("\(domain) invalid domain")
                    //alert user to enter data
                    let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                    //displays
                    self.EnterButton.hidden = false
                    self.loadingWheel.hidden = true
                    
                } else {
                    
                    //valid dartmouth email
                    
                    //attempt to view data with email stored
                    FIRAuth.auth()?.signInWithEmail(DartmouthEmail.text!, password: "Apex-pw"){
                        _ in
                        if (FIRAuth.auth()?.currentUser?.emailVerified != true) {
                
                            //user not verified

                            //send email alert
                            let alert = UIAlertController(title: "Email Not Yet Verified", message: "Press OK to send an email verification to \(self.DartmouthEmail.text!)", preferredStyle: .Alert)
                            let action1 = UIAlertAction(title: "OK", style: .Default) { _ in
                                self.verifyUser(self.DartmouthEmail.text!.lowercaseString)
                            }
                            let action2 = UIAlertAction(title: "DON'T SEND EMAIL", style: .Default, handler: nil)
                            alert.addAction(action1)
                            alert.addAction(action2)
                            self.presentViewController(alert, animated: true, completion: nil)
                            //displays
                            self.loadingWheel.hidden = true
                            self.EnterButton.hidden = false
                        } else {
                            
                            //user verified!
                            
                            // store email if verified
                            let data = NSUserDefaults.standardUserDefaults()
                            data.setValue(self.DartmouthEmail.text!.lowercaseString, forKey: "userEmail")
                            self.performSegueWithIdentifier("userAuth", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    func verifyUser(email: String) {
        //save email to NSUser Defaults
        let data = NSUserDefaults.standardUserDefaults()
        data.setValue(email, forKey: "userEmail")
        print("\(email) saved")
        
        //create user -- https://github.com/firebase/quickstart-ios/blob/master/authentication/AuthenticationExampleSwift/EmailViewController.swift
        
        FIRAuth.auth()?.createUserWithEmail(email, password: "Apex-pw") { (user, error) in
            //verify email address
            print("user created \(email)")
            FIRAuth.auth()?.signInWithEmail(email, password: "Apex-pw", completion: nil)
            FIRAuth.auth()?.currentUser?.sendEmailVerificationWithCompletion(nil)
            //clear text and show verification
            self.emailVerMsg.hidden = false
        }
    }
}
