//
//  SearchVC.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    
    struct CityInfo{
        let name: String
        let woeid: Int
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var foundLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var localizationButton: UIButton!
    @IBOutlet weak var localizationLabel: UILabel!
    
    
    var searchingCityName: String = ""
    var cities : [CityInfo] = []
    var selectCity : CityInfo = CityInfo(name: "", woeid: 0)
    var localizationCity : CityInfo = CityInfo(name: "", woeid: 0)
    
    let urlToSearch = "https://www.metaweather.com/api/location/search/?query="
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    @IBAction func inputText(_ sender: Any) {
        searchingCityName = inputText.text ?? ""
        foundLabel.text = "..."
        updateCities()
    }
    
    @IBAction func vaklu(_ sender: Any) {
        ///nothing here
    }
    
    @IBAction func onLocalizationPick(_ sender: Any) {
        selectCity = localizationCity
    }
    
    
    //WEATHER API HANDLER
    
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
    
    
    func updateLocalizationCity(){
        let locURL : URL? = URL(string: "https://www.metaweather.com/api/location/search/?lattlong=\(previousLocation?.coordinate.latitude ?? 0.0),\(previousLocation?.coordinate.longitude ?? 0.0)")
        
        if(locURL != nil)
        {
            URLSession.shared.dataTask(with: locURL!) {
                data, resp, err in
             
                let dataJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
                
                var record = dataJson!![0]
                
                self.localizationCity = CityInfo(name: record["title"] as! String,
                                    woeid: record["woeid"] as! Int)
            }.resume()
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

extension SearchVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension SearchVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                print("ERROR")
                return }
            
            guard let placemark = placemarks?.first else {
                print("NO PLACEMAARK")
                return }
            
            //let streetNumber = placemark.subThoroughfare ?? ""
            //let streetName = placemark.thoroughfare ?? ""
            let city = placemark.subAdministrativeArea ?? ""
            let country = placemark.country ?? ""
            
            DispatchQueue.main.async {
                self.updateLocalizationCity()
                self.localizationLabel.text = "\(country), \(city)"
            }
        }
        
    }
}
