//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    
    @IBAction func signIn(sender: AnyObject) {
        
        // try logging in the user
        
        PFUser.logInWithUsernameInBackground(username.text, password:"mypass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                
                // Successful login
                println("logged in")
                self.performSegueWithIdentifier("showUsers", sender: self)
                
            } else {
                
                // User not signed up
                var user = PFUser()
                user.username = self.username.text
                user.password = "mypass"
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    
                    if let error = error {
                        
                        let errorString = error.userInfo?["error"] as? NSString
                        println(errorString)
                        
                    } else {
                        
                        println("sign up succeeded")
                        self.performSegueWithIdentifier("showUsers", sender: self)
                    }
                }
                
                
            }
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        println("PFUser.currentUser().username = \(PFUser.currentUser().username)")
        
        if(PFUser.currentUser().username != nil) {
                        
            self.performSegueWithIdentifier("showUsers", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

