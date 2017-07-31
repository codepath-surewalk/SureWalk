//
//  ScheduleViewController.swift
//  SureWalk
//
//  Created by SureWalk Team on 3/20/17.
//  Copyright © 2017 SureWalk Team. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickerData: [String] = [String]()
    var pickerPt2: [String] = [String]()
    
    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "gradient_SUREWalk.jpg")
        self.view.insertSubview(backgroundImage, at: 0)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient_SUREWalk.jpg")!)
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["9", "10", "11", "12", "1"]
        pickerPt2 = ["00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
        
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if(component == 0)
        {
            return pickerData.count
        }
        else
        {
            return pickerPt2.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0)
        {
            return pickerData[row]
        }
        else
        {
            return pickerPt2[row]
        }
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
