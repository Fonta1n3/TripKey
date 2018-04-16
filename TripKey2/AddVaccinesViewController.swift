//
//  AddVaccinesViewController.swift
//  TripKey2
//
//  Created by Peter on 8/23/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit



class AddVaccinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let vaccineDatePickerView = Bundle.main.loadNibNamed("Date Picker", owner: self, options: nil)?[0] as! DatePickerView
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.regular))
    var vaccineDictionary:Dictionary<String,String>!
    var vaccineDictionaryArray = [Dictionary<String,String>!]()
    
    
    @IBOutlet var vaccineTable: UITableView!
    @IBOutlet var vaccineDate: UITextField!
    
    @IBAction func addVaccine(_ sender: AnyObject) {
        
        self.vaccineDate.resignFirstResponder()
        self.vaccineDatePickerView.save.addTarget(self, action: #selector(self.saveVaccine), for: .touchUpInside)
        self.vaccineDatePickerView.exit.addTarget(self, action: #selector(self.closeVaccineDatePicker), for: .touchUpInside)
        self.vaccineDatePickerView.center = self.view.center
        self.vaccineDatePickerView.alpha = 0
        self.vaccineDatePickerView.title.text = "Please select expiry date"
        
        self.blurEffectView.frame = view.bounds
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.view.addSubview(self.blurEffectView)
            self.view.addSubview(self.vaccineDatePickerView)
            self.blurEffectView.alpha = 1
            self.vaccineDatePickerView.alpha = 1
            
        }) { _ in
            
        }

        
    }
    
    
    
    func saveVaccine() {
        
        var vaccineExpiry:String!
        
        let vaccineDateFormatter = DateFormatter()
        vaccineDateFormatter.dateFormat = "E, MMM d, yyyy"
        vaccineExpiry = vaccineDateFormatter.string(from: self.vaccineDatePickerView.datePicker.date)
        
        vaccineDictionary = [
            
            "Vaccine Type":"\(String(describing: self.vaccineDate.text!))",
            "Vaccine Expiry Date":"\(vaccineExpiry!)",
            "Vaccine Expiry Date Unformatted":"\(self.vaccineDatePickerView.datePicker.date)"
            
        ]
        
        self.vaccineDictionaryArray.append(vaccineDictionary)
        
        UserDefaults.standard.set(self.vaccineDictionaryArray, forKey: "vaccinesList")
        
        print("vaccineDictionaryArray = \(self.vaccineDictionaryArray)")
        
        self.vaccineTable.reloadData()
        
        vaccineDate.text = ""
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.vaccineDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            self.vaccineDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
            
        }
        
    }
    
    func closeVaccineDatePicker() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.vaccineDatePickerView.alpha = 0
            self.blurEffectView.alpha = 0
            
        }) { _ in
            
            self.vaccineDatePickerView.removeFromSuperview()
            self.blurEffectView.removeFromSuperview()
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        view.endEditing(true)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        if (UserDefaults.standard.object(forKey: "vaccinesList") != nil) {
            
            vaccineDictionaryArray = UserDefaults.standard.object(forKey: "vaccinesList") as! [Dictionary<String,String>]
            
        }
        
        self.vaccineDate.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.vaccineDictionaryArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "\(String(describing: self.vaccineDictionaryArray[indexPath.row]["Vaccine Type"]!) + ": Expiring " + String(describing: self.vaccineDictionaryArray[indexPath.row]["Vaccine Expiry Date"]!))"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            vaccineDictionaryArray.remove(at: indexPath.row)
            UserDefaults.standard.set(self.vaccineDictionaryArray, forKey: "vaccinesList")
            vaccineTable.reloadData()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        vaccineTable.reloadData()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
 
        return false
    }
    
    
    

    
    }
