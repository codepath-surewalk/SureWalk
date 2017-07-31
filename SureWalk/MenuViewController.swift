//
//  MenuViewController.swift
//  REFrostedViewControllerSwiftExample
//
//  Created by SureWalk Team on 5/20/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MenuViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor(colorLiteralRed: 150/255.0, green: 161/255.0, blue: 177/255.0, alpha: 1.0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isOpaque = false
        self.tableView.backgroundColor = .clear
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 184.0))
        
        let imageView = PFImageView(frame: CGRect(x: 0, y: 40, width: 100, height: 100))
        imageView.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        imageView.image = #imageLiteral(resourceName: "surewalkGirl")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 50.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3.0
        imageView.layer.rasterizationScale = UIScreen.main.scale
        imageView.layer.shouldRasterize = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill;
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture(sender:))))
        
        let label = UILabel(frame: CGRect(x: 0.0, y: 150.0, width: 0.0, height: 24.0))
        let user = PFUser.current()!
        label.text = "\(user["lastName"] as! String), \(user["firstName"] as! String)"
        label.font = UIFont(name: "HelveticaNeue", size: 21.0)
        label.backgroundColor = .clear
        label.textColor = UIColor(colorLiteralRed: 62/255.0, green: 68/255.0, blue: 75/255.0, alpha: 1.0)
        label.sizeToFit()
        label.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        self.tableView.tableHeaderView = view
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = UIColor(colorLiteralRed: 62/255.0, green: 68/255.0, blue: 75/255.0, alpha: 1.0)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 17.0)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 24))
        view.backgroundColor = UIColor(colorLiteralRed: 167/255.0, green: 167/255.0, blue: 167/255.0, alpha: 0.6)
        
        /*let label = UILabel(frame: CGRect(x: 10, y: 8, width: 0, height: 0))
         label.text = "Friends Online"
         label.font = UIFont.systemFont(ofSize: 15.0)
         label.textColor = .white
         label.sizeToFit()
         
         view.addSubview(label)*/
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }
        
        return 34
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "contentController") as! NavigationController
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeController")
            navigationController.viewControllers = [homeViewController!]
        } else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileController")
            navigationController.viewControllers = [secondViewController!]
        }
        
        self.frostedViewController.contentViewController = navigationController
        self.frostedViewController.hideMenuViewController()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.section == 0 {
            let titles = ["Home", "Profile"]
            cell?.textLabel?.text = titles[indexPath.row]
        } /*else {
         let titles = ["John Appleseed", "John Doe", "Test User"]
         cell?.textLabel?.text = titles[indexPath.row]
         }*/
        
        return cell!
    }
    
    func didTapProfilePicture(sender: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
        
        /*let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
         vc.sourceType = UIImagePickerControllerSourceType.camera
         }))
         alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (action) in
         vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
         }))
         /*alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
         alert.dismiss(animated: true, completion: nil)
         }))*/
         
         self.present(alert, animated: true, completion: {
         
         })*/
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        
        for subview in (self.tableView.tableHeaderView?.subviews)! {
            if subview is UIImageView {
                (subview as! UIImageView).image = originalImage
            }
        }
        
        let user = PFUser.current()!
        // Add relevant fields to the object
        user["profilePicture"] = getPFFileFromImage(image: originalImage) // PFFile column type
        user.saveInBackground()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Method to convert UIImage to PFFile
     
     - parameter image: Image that the user wants to upload to parse
     
     - returns: PFFile for the the data in the image
     */
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "profile.png", data: imageData)
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
