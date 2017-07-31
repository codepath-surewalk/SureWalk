//
//  SignupViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 3/27/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import UITextField_Shake
import HTYTextField

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstName: HTYTextField!
    @IBOutlet weak var lastName: HTYTextField!
    @IBOutlet weak var username: HTYTextField!
    @IBOutlet weak var phoneNumber: HTYTextField!
    @IBOutlet weak var password: HTYTextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var alertView: AlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        
        signUpButton.layer.cornerRadius = 5.0
        
        firstName.rightPlaceholder = "First Name"
        lastName.rightPlaceholder = "Last Name"
        username.rightPlaceholder = "UT EID"
        phoneNumber.rightPlaceholder = "xxxxxxxxxx"
        password.rightPlaceholder = "Password"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignup(_ sender: UIButton) {
        
        if !AlertView.isInternetAvailable() {
            alertView.isHidden = false
            return
        }
        
        //Check completion of text fields
        if let toShake = Sanitation.checkCompletion(firstName: firstName, lastName: lastName, username: username, phoneNumber: phoneNumber, password: password){
            shakeTextField(textField: toShake)
            return
        }
        
        //Check correctness of username
        if let toShake = Sanitation.checkCorrectness(username: username) {
            shakeTextField(textField: toShake)
            return
        }
        
        //Check correctness of phoneNumber
        if let toShake = Sanitation.checkCorrectness(phoneNumber: phoneNumber) {
            shakeTextField(textField: toShake)
            return
        }
        
        let newUser = PFUser()
        newUser.username = username.text
        newUser.password = password.text
        newUser["phone"] = Sanitation.sanitizedPhone(phoneNumber: phoneNumber.text!)
        newUser["firstName"] = firstName.text!
        newUser["lastName"] = lastName.text!
        newUser["driver"] = false
        
        let loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingHUD.label.text = "One sec..."
        
        loadingHUD.detailsLabel.text = "Our monkeys are \ntyping away furiously"
        
        newUser.signUpInBackground { (success: Bool, error: Error?) -> Void in
            if success {
                sleep(2)
                loadingHUD.hide(animated: true)
                
                loadingHUD.customView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))
                loadingHUD.mode = .customView
                loadingHUD.label.text = "Done"
                loadingHUD.detailsLabel.text = "Shakespeare completed!"
                loadingHUD.minSize = CGSize(width: 100, height: 100)
                
                loadingHUD.show(animated: true)
                
                DispatchQueue.global().async(execute: {
                    DispatchQueue.main.sync{
                        sleep(2)
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        self.performSegue(withIdentifier: "signupSegue", sender: nil)
                    }
                })
                
            } else {
                //print(error?.localizedDescription)
                /*
                 if error. == 202 {
                 print("Username is taken")
                 }
                 */
                //   }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func shakeTextField(textField: UITextField!) {
        textField.shake(10, // 10 times
            withDelta: 5.0,  // 5 points wide
            speed: 0.03,     // 30ms per shake
            shakeDirection: ShakeDirection.horizontal)
    }
    
    @IBAction func didTap(_ sender: Any) {
        view.endEditing(true)
    }
}
