//
//  SearchVC.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class SearchVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    struct CityInfo{
        let name: String
        let woeid: Int
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextField!
    
    @IBOutlet weak var foundLabel: UILabel!
    
    var searchingCityName: String = ""
    var cities : [CityInfo] = [
        CityInfo(name: "Sab", woeid: 234543)
    ]
    
    let urlToSearch = "https://www.metaweather.com/api/location/search/?query="
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    @IBAction func inputText(_ sender: Any) {
        searchingCityName = inputText.text ?? ""
        foundLabel.text = "..."
        //updateCities()
    }
    
    
    func updateCities(){
        let fullUrl = URL(string: "\(urlToSearch)\(searchingCityName)")
        
        URLSession.shared.dataTask(with: fullUrl!) {
            data, resp, err in
            
            let dataJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
            
            self.cities.removeAll()
            
            var index = 0
            var checkNext = true
            
            while checkNext {
                let record = dataJson!![index]
                
                if record["title"] == nil {
                    checkNext = false
                    break
                }
                
                let city = CityInfo(name: record["title"] as! String,
                                    woeid: record["woeid"] as! Int)
                
                self.cities.append(city)
                
                index += 1
            }
            
            self.foundLabel.text = String(self.cities.count)
        }.resume()
    }
    
    //dismiss powrot do poprzendiego widoku
    //performSeque..
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //zaznaczanie konkretnej komorki
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)

        cell.textLabel?.text = cities[indexPath.row].name
        cell.detailTextLabel?.text = "woeid: \(cities[indexPath.row].woeid)"
        return cell
    }
    
   

}
