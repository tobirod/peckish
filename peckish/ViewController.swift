//
//  ViewController.swift
//  peckish
//
//  Created by Tobias on 2017-09-13.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRecipeTapped))
        
        // tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addNewRecipeSegue", sender: Any?.self)
    }

}

