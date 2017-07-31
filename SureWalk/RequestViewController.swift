//
//  RequestViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 3/20/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit
import Parse

public var pickerData: [String] = [String]()
public var pickerDataReturn: [String: CLLocation] = [String: CLLocation]()

class RequestViewController: UIViewController {
    
    @IBOutlet weak var picker2: UIPickerView!
    
    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient_SUREWalk.jpg")!)
        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
        
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        
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
