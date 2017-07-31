//
//  ProfileViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 5/20/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import HTYTextField
import Parse
import ParseUI
import UITextField_Shake

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profilePicture: PFImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet var editButton: UIBarButtonItem!
    var edit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        
        let user = PFUser.current()!
        
        profilePicture.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        if let pictureFile = user["profilePicture"] as? PFFile {
            profilePicture.file = pictureFile
            profilePicture.loadInBackground()
        } else {
            profilePicture.image = #imageLiteral(resourceName: "surewalkGirl")
        }
        
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = 50.0
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 3.0
        profilePicture.layer.rasterizationScale = UIScreen.main.scale
        profilePicture.layer.shouldRasterize = true
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        
        firstName.text = user["firstName"] as? String
        lastName.text = user["lastName"] as? String
        username.text = user["username"] as? String
        phoneNumber.text = String(user["phone"] as! Int)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        if edit {
            editButton.title = "Done"
            edit = false
        } else {
            //Check completion of text fields
            if let toShake = Sanitation.checkCompletion(firstName: firstName, lastName: lastName, username: username, phoneNumber: phoneNumber) {
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
            
            API.submitInformation(firstName: firstName.text!, lastName: lastName.text!, username: username.text!, phoneNumber: Sanitation.sanitizedPhone(phoneNumber: phoneNumber.text!), newUser: false)
            
            editButton.title = "Edit"
            edit = true
        }
    }
    
    func shakeTextField(textField: UITextField!) {
        textField.shake(10, // 10 times
            withDelta: 5.0,  // 5 points wide
            speed: 0.03,     // 30ms per shake
            shakeDirection: ShakeDirection.horizontal)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        // Dismiss keyboard (optional)
        self.view.endEditing(true)
        self.frostedViewController.view.endEditing(true)
        
        // Present the view controller
        self.frostedViewController.presentMenuViewController()
    }
    
}
