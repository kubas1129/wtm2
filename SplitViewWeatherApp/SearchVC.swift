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
    var cities : [CityInfo] = []
    var selectCity : CityInfo = CityInfo(name: "", woeid: 0)
    
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
        updateCities()
    }
    
    @IBAction func vaklu(_ sender: Any) {
        ///nothing here
    }
    
    
    
    func updateCities(){
        let fullUrl : URL? = URL(string: "\(urlToSearch)\(searchingCityName)")
    
        if (fullUrl != nil){
            
            URLSession.shared.dataTask(with: fullUrl!) {
                data, resp, err in
                
                let dataJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
                
                self.cities.removeAll()
                
                var index = 0
                
                while (dataJson??.indices.contains(index))! {
                    
                    var record = dataJson!![index]
                    
                    let city = CityInfo(name: record["title"] as! String,
                                        woeid: record["woeid"] as! Int)
                    
                    self.cities.append(city)
                    index += 1
                }
                
                DispatchQueue.main.async {
                    self.updateTableView()
                }
                
                }.resume()
        }
        else
        {
            DispatchQueue.main.async {
                self.updateTableView()
            }
        }
        
    }
    
    func updateTableView(){
        self.foundLabel.text = String(self.cities.count)
        self.tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCity = cities[indexPath.row]
        //dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SEGUE DZIALA")
        let dest = segue.destination as! MasterViewController
        dest.addCity(woeid: selectCity.woeid, cityName: selectCity.name)
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
