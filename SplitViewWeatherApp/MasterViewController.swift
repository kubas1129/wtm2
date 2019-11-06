//
//  MasterViewController.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    struct CityDetail{
        let name : String
        let woeid: Int
        let temp: Double
        let weather: String?
        
    }

    var detailViewController: DetailViewController? = nil
    var citiesDetail: [CityDetail] = []
    var url = "https://www.metaweather.com/api/location/"
    let form = DateFormatter()
    let dtForm = "yyyy/MM/dd"
    var now = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form.dateFormat = dtForm
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
////
//    @objc
//    func plusButton(_ sender: Any) {
//       performSegue(withIdentifier: "toSearchVC", sender: self)
//    }
    
    
    @IBAction func onDodajClick(_ sender: Any) {
        //performSegue(withIdentifier: "toSearchVC", sender: self)
    }

 
    @IBAction func unwindToMaster(_ sender: UIStoryboardSegue){
        print("UNWIND")
    }
    
    
    func addCity(woeid: Int, cityName: String){
        let strDate = form.string(from: now)
        let cityUrl = URL(string: "https://www.metaweather.com/api/location/\(woeid)/\(strDate)")
        
        if(cityUrl != nil){
            
            URLSession.shared.dataTask(with: cityUrl!){
                data, resp, err in
                let dateJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
                
                let record = dateJson!![0]
                
                let cc = CityDetail(name: cityName, woeid: woeid, temp: record["the_temp"] as! Double, weather: record["weather_state_abbr"] as? String)
                
                self.citiesDetail.append(cc)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }.resume()
        
        }
        
    }
    
    // MARK: - Segues

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = citiesWeid[indexPath.row] as! Int
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//            }
//        }
//    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesDetail.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = citiesDetail[indexPath.row]
        cell.textLabel!.text = object.name //glowny tekst
        cell.detailTextLabel!.text = "\(object.temp) C"
        //cell.imageView?.image = object.weather
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "toShowDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowDetail"{
            if let destVC = segue.destination as? DetailViewController{
                if let indexPath = tableView.indexPathForSelectedRow{
                    destVC.showWeather(name: citiesDetail[indexPath.row].name, woeid: citiesDetail[indexPath.row].woeid)
                }
            }
        }
    }

    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
    

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }


}
