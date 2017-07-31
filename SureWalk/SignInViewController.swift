//
//  SignInViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 3/23/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import UITextField_Shake

class SignInViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var alertView: AlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
            return
        }
        
        if textFieldEmpty(textField: usernameField) || textFieldEmpty(textField: passwordField) {
            if textFieldEmpty(textField: usernameField) {
                shakeTextField(textField: usernameField)
            } else {
                shakeTextField(textField: passwordField)
            }
            
            return
        }
        
        let loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingHUD.mode = .indeterminate
        loadingHUD.label.text = "Logging in..."
        
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { (user:PFUser?, error: Error?) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else if (error != nil) {
                
                let alertController = UIAlertController(title: "Invalid username/password", message: nil, preferredStyle: .alert)
                
                // create an OK action
                let OKAction = UIAlertAction(title: "Try again", style: .default) { (action) in
                }
                // add the OK action to the alert controller
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true) {
                    self.passwordField.text = ""
                }
            }
        }
        
    }
    
    func textFieldEmpty(textField: UITextField) -> Bool {
        return textField.text == nil || textField.text?.characters.count == 0
    }
    
    func shakeTextField(textField: UITextField!) {
        textField.shake(10, // 10 times
            withDelta: 5.0, // 5 points wide
            speed: 0.03,    // 30ms per shake
            shakeDirection: ShakeDirection.horizontal)
    }
    
    @IBAction func didTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil && segue.identifier == "signupSegue" {
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        }
    }
}
