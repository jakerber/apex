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
    
    @IBOutlet weak var iconMail: UIImageView!
    @IBOutlet weak var dpc_logo: UIImageView!
    @IBOutlet weak var emailVerMsg: UITextField!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var EnterButton: UIButton!
    @IBOutlet weak var DartmouthEmail: UITextField!
    @IBOutlet weak var LoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        //displays
        let customColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        self.iconMail.alpha = 0.8
        self.EnterButton.layer.cornerRadius = (0.5 * self.EnterButton.bounds.width)
        self.LoginView.layer.cornerRadius = 5
        //input text
        self.DartmouthEmail.textColor = customColor
        //sign out reset
        try! FIRAuth.auth()?.signOut()
        
        //check if user has stored email
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            //user has email stored
            if ("\(email)" == "") {
                //no valid email with NSUser

                //displays
                self.loadingWheel.isHidden = true
                self.DartmouthEmail.isUserInteractionEnabled = true
                self.EnterButton.isHidden = false
                self.EnterButton.isUserInteractionEnabled = true
            } else {
                //displays
                self.loadingWheel.isHidden = true
                self.DartmouthEmail.isUserInteractionEnabled = true
                self.DartmouthEmail.text = email
                self.EnterButton.isHidden = false
                self.EnterButton.isUserInteractionEnabled = true
            }
        } else {
            //no email with NSUser
            //displays
            self.loadingWheel.isHidden = true
            self.DartmouthEmail.isUserInteractionEnabled = true
            self.EnterButton.isHidden = false
            self.EnterButton.isUserInteractionEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "userAuth") {
            //nothing
        }
    }
    
    //manual override
    @IBAction func EnterTestingAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "userAuth", sender: self)
    }
    
    @IBAction func EnterClicked(_ sender: AnyObject!) {

        //displays
        self.emailVerMsg.isHidden = true
        self.EnterButton.isHidden = true
        self.loadingWheel.isHidden = false
        //no data entered
        if (DartmouthEmail.text == "") {
            
            /////////////no data has been entered
            
            let alert = UIAlertController(title: "Missing Email", message: "Please enter your Dartmouth email address", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            //displays
            self.EnterButton.isHidden = false
            self.loadingWheel.isHidden = true
        } else {
            
            //data has been entered
            
            //check for @dartmouth.edu
            let emailArr = DartmouthEmail.text!.components(separatedBy: "@")
            if (emailArr.count < 2 || emailArr.count > 2) {
                
                ////////////////not a valid email address (more than 1 @ sign)
                
                let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                //displays
                self.EnterButton.isHidden = false
                self.loadingWheel.isHidden = true
            } else {
                //check for valid dartmouth email
                let domain = "@\(emailArr[1])"
                if(domain.caseInsensitiveCompare("@dartmouth.edu") != ComparisonResult.orderedSame){
                    
                    ///////////////not a valid dartmouth email (no @dartmouth.edu)
                    
                    //alert user to enter data
                    let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid Dartmouth email address", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    //displays
                    self.EnterButton.isHidden = false
                    self.loadingWheel.isHidden = true
                    
                } else {
                    
                    ////////////valid dartmouth email
                    
                    //attempt to view data with email stored
                    FIRAuth.auth()?.signIn(withEmail: DartmouthEmail.text!, password: "Apex-pw"){
                        _ in
                        if (FIRAuth.auth()?.currentUser?.isEmailVerified != true) {
                
                            //user not verified

                            //send email alert
                            let alert = UIAlertController(title: "Email Not Yet Verified", message: "Press OK to send an email verification to \(self.DartmouthEmail.text!)", preferredStyle: .alert)
                            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                                self.verifyUser(self.DartmouthEmail.text!.lowercased())
                            }
                            let action2 = UIAlertAction(title: "DON'T SEND EMAIL", style: .default, handler: nil)
                            alert.addAction(action1)
                            alert.addAction(action2)
                            self.present(alert, animated: true, completion: nil)
                            //displays
                            self.loadingWheel.isHidden = true
                            self.EnterButton.isHidden = false
                        } else {
                            
                            //user verified!
                            
                            // store email if verified
                            let data = UserDefaults.standard
                            data.setValue(self.DartmouthEmail.text!.lowercased(), forKey: "userEmail")
                            self.performSegue(withIdentifier: "userAuth", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    func verifyUser(_ email: String) {
        //save email to NSUser Defaults
        let data = UserDefaults.standard
        data.setValue(email, forKey: "userEmail")
        
        FIRAuth.auth()?.createUser(withEmail: email, password: "Apex-pw") { (user, error) in
            //verify email address
            FIRAuth.auth()?.signIn(withEmail: email, password: "Apex-pw", completion: nil)
            FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: nil)
            //clear text and show verification
            self.emailVerMsg.isHidden = false
        }
    }
}
