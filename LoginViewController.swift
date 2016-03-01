//
//  LoginViewController.swift
//  OnTheMapV2
//
//  Created by Mehdi Salemi on 2/28/16.
//  Copyright © 2016 MxMd. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func login(sender: UIButton) {
        activityIndicator.startAnimating()
        
        func handler(data:NSData?,response:NSURLResponse?, error:NSError?) {
            dispatch_async(dispatch_get_main_queue()) {
                let range = NSMakeRange(5, data!.length)
                
                let dataWithOutFirst5 = data!.subdataWithRange(range)
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(dataWithOutFirst5, options: .AllowFragments)
                    self.activityIndicator.stopAnimating()
                } catch {
                    self.alert("An Error occured when parsing the Data!")
                }
                
                guard let session = parsedResult["session"] as? [String:AnyObject] else{
                    self.alert("Please enter valid username/password!")
                    return
                }
                
                UdacityClient.sharedClient().currentSessionID = session["id"] as! String
                
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBar")
                self.presentViewController(controller, animated: true, completion: nil)
                UdacityClient.sharedClient().loggedIn = true
            }
        }
        
        UdacityClient.sharedClient().loginToUdacity(usernameTextField.text!, password: passwordTextField.text!, handler: handler)
    }
    
    
    func alert (reason : String){
        let controller = UIAlertController()
        controller.title = "Login Error!"
        controller.message = reason
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) {
            action in self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}