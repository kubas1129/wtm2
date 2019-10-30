//
//  SearchVC.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class SearchVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var searchingCityName: String = ""
    var objects = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //dismiss powrot do poprzendiego widoku
    //perform.sequew 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //zaznaczanie konkretnej komorki
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
        
        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description //glowny tekst
        //cell.detail?.text
        //cell.imageView?.image =
        return cell
    }
    
   

}
