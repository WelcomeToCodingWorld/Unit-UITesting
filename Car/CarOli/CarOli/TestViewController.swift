//
//  TestViewController.swift
//  CarOli
//
//  Created by zz on 05/12/2017.
//  Copyright © 2017 Lesta. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    let cellID = "TableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        // Do any additional setup after loading the view.
    }

    @IBOutlet var tableView: UITableView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTable() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
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

extension TestViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TableViewCell else { fatalError("Fuck") }
//        cell.label.text = "sgwegwe"   
        return cell
    }
}
