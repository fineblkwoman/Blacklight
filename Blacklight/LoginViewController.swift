//
//  LoginViewController.swift
//  Blacklight
//
//  Created by Alicia MacBook Pro on 6/4/16.
//  Copyright © 2016 DiversityHack. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //Mark: Properties
    var ref: FIRAuth!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRAuth.auth()
        
//        Fir
        
        
//        ref = Firebase(url: "https://blacklight-3aa59.firebaseio.com")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.signInAnonymouslyWithCompletion { (user, error) in
            if error != nil { print (error!.description); return }
            
            print(self.ref.currentUser?.displayName)
            
            self.performSegueWithIdentifier("loginToChat", sender: self)
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navigationViewController = segue.destinationViewController as! UINavigationController
        let chatViewController = navigationViewController.viewControllers.first as! ChatViewController
        chatViewController.senderId = "SomeUserId"
        chatViewController.senderDisplayName = "Some User"
    }


}
