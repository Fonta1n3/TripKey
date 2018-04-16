//
//  FrequentFlyerInfoViewController.swift
//  TripKey2
//
//  Created by Peter on 8/25/16.
//  Copyright © 2016 Fontaine. All rights reserved.
//

import UIKit

var frequentFlyerList = [String]()

class FrequentFlyerInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet var frequentFlyerTableView: UITableView!
    @IBOutlet var frequentFlyerNumber: UITextField!
    @IBAction func addAccount(_ sender: AnyObject) {
        frequentFlyerList.append(frequentFlyerNumber.text!)
        frequentFlyerNumber.text = ""
        UserDefaults.standard.set(frequentFlyerList, forKey: "frequentFlyerList")
        self.frequentFlyerTableView.reloadData()
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "finish", sender: self)
        //let viewController = self.storyboard! .instantiateViewController(withIdentifier: "TripConsole") as UIViewController; self.present(viewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserDefaults.standard.object(forKey: "frequentFlyerList") != nil) {
            frequentFlyerList = UserDefaults.standard.object(forKey: "frequentFlyerList") as! [String]
        }
        
        self.frequentFlyerNumber.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frequentFlyerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "frequentFlyer", for: indexPath)
        cell.textLabel?.text = frequentFlyerList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            frequentFlyerList.remove(at: indexPath.row)
            UserDefaults.standard.set(frequentFlyerList, forKey: "frequentFlyerList")
            frequentFlyerTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        frequentFlyerTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)

        return false
    }
}
