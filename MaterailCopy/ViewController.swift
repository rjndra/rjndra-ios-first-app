//
//  ViewController.swift
//  MaterailCopy
//
//  Created by User on 4/7/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            performSegueWithIdentifier(LOGIN_SEGUE, sender: nil)
        }
    }
    
    
    // MARK: FacebookButton Action
    @IBAction func fbBtnPressd(sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"]){ (facebookResult : FBSDKLoginManagerLoginResult!, facebookError: NSError! ) -> Void in
            
            
            if facebookError != nil {
                print("Cannot login to Facebook!")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Suceessfully LogedIn!")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { (error, authData) in
                    
                    
                    if error != nil {
                        print("Failed Login")
                    } else {
                        
                        let user = ["provider" : authData.provider!, "username": "newFBUser"]
                        DataService.ds.createFirebaseUsers(authData.uid, user: user)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier(LOGIN_SEGUE, sender: nil)
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    //MARK: Email Login Actions
    
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func emailLoginAttempt(sender: AnyObject) {
        
        if let email = emailTextField.text where email != "", let password = passwordTextField.text where password != "" {
            DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { (error, authresult) in
                
                if error != nil {
                    
                    print(error.code)
                    
                    if error.code == NO_USER_EXIST {
                        
                        
                        DataService.ds.REF_BASE.createUser(email, password: password) { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("User Not Created", msg: "Problem With user creater. Try Again later")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue([KEY_UID], forKey: KEY_UID)
                                DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { error, authData in
                                    let user = ["provider" : authData.provider!, "username": "newEmailUser"]
                                    DataService.ds.createFirebaseUsers(authData.uid, user: user)
                                    
                                })
                                
                                self.performSegueWithIdentifier(LOGIN_SEGUE, sender: nil)
                            }
                        }
                    } else {
                        let msg = "Username or Password didn't Match. Please try Again"
                        self.showErrorAlert("Login Failed", msg: msg)
                    }
                    
                    
                } else {
                    self.performSegueWithIdentifier(LOGIN_SEGUE, sender: nil)
                }
                
            })
            
        } else {
            let msg = "You msut enter both Email Address and Password!"
            showErrorAlert("Empty Fields", msg: msg)
        }
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alertAction = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let alert = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertAction.addAction(alert)
        presentViewController(alertAction, animated: true, completion: nil)
        
    }
    
    
}

