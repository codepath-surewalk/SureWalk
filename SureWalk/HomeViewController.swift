//
//  HomeViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 3/23/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import REFrostedViewController

class HomeViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var alertView: AlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        // Do any additional setup after loading the view.
        
        let user = PFUser.current()!
        navigationBar.title = "\(user["lastName"] as! String), \(user["firstName"] as! String)"
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
            return
        }
        
        let loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingHUD.mode = .indeterminate
        loadingHUD.label.text = "Logging out..."
        
        PFUser.logOutInBackground { (error: Error?) in
            loadingHUD.hide(animated: true)
            /*if error != nil {
             let alertController = UIAlertController(title: "Unable to log out", message: nil, preferredStyle: .alert)
             
             // create an OK action
             let OKAction = UIAlertAction(title: "Try again", style: .default) { (action) in
             }
             // add the OK action to the alert controller
             alertController.addAction(OKAction)
             return
             }*/
            loadingHUD.customView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))
            loadingHUD.mode = .customView
            loadingHUD.label.text = "Logged out."
            
            loadingHUD.show(animated: true)
            
            DispatchQueue.global().async(execute: {
                DispatchQueue.main.sync{
                    sleep(1)
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
                    
                }
            })
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        // Dismiss keyboard (optional)
        self.view.endEditing(true)
        self.frostedViewController.view.endEditing(true)
        
        // Present the view controller
        self.frostedViewController.presentMenuViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
}
