//
//  DetailViewController.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var maximumTemperatureLabel: UILabel!
    @IBOutlet weak var minimalTemperatureLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    @IBOutlet weak var weatherDateLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    
    //Var and let
    let formatter = DateFormatter()
    let iconsPath = "https://www.metaweather.com/static/img/weather/png/64/"
    let dateFormat = "yyyy/MM/dd"
    var path = "https://www.metaweather.com/api/location/"
    
    var current = 0
    var delta = 5
    let now = Date()
    
    var cityName = ""
    var woeid = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetup()
    }
    
    struct DailyConditionWeather {
        var date : String
        var minTemp: Double
        var maxTemp: Double
        var pressure : Double?
        var weather : String?
        var humidity : Int?
        var windSpeed: Double?
    }
    
    func initSetup() {
        formatter.dateFormat = dateFormat
    }
    
    func showWeather(name: String, woeid: Int){
        formatter.dateFormat = dateFormat
        self.cityName = name
        self.woeid = woeid
        getJson(date: now)
    }
    
    
    @IBAction func onNextItemButton(_ sender: Any) {
        if (current < delta) {
            previousButton.isEnabled = true
            current+=1
            let date = addDay(count: current)
            getJson(date: date)
        } else {
            nextButton.isEnabled = false
        }
    }
    
    @IBAction func onPreviousItemButton(_ sender: Any) {
        if (current > -delta) {
            nextButton.isEnabled = true
            current-=1
            let date = addDay(count: current)
            getJson(date: date)
        } else{
            previousButton.isEnabled = false
        }
    }
    private func setPage() {
        pageLabel.text = "\(current + delta)/\(2*delta)"
    }
    private func addDay(count: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: count, to: now) ?? now
    }
    
    
    func getJson(date: Date) {
        let dateAsString = formatter.string(from: date)
        let joinedUrl = URL(string: "\(path)\(woeid)/\(dateAsString)")
        URLSession.shared.dataTask(with: joinedUrl!) {
            data, response, error in
            let jsonResponseArray = try? JSONSerialization.jsonObject(with:data!,options: []) as? [[String: Any]]
            
            let jsonResponse = jsonResponseArray!![0]
            let weather = DailyConditionWeather(date: dateAsString,
                                                minTemp: jsonResponse["min_temp"] as! Double,
                                                maxTemp: jsonResponse["max_temp"] as! Double,
                                                pressure: jsonResponse["air_pressure"] as? Double,
                                                weather: jsonResponse["weather_state_abbr"] as? String,
                                                humidity: jsonResponse["humidity"] as? Int,
                                                windSpeed: jsonResponse["wind_speed"] as? Double)
            DispatchQueue.main.async {
                self.setView(dailyConditionWeather: weather)
            }
            self.loadCurrentWeatherIcon(weather: weather.weather ?? "")
            
            }.resume()
    }

    
    func loadCurrentWeatherIcon(weather: String) {
        let url = URL(string: "\(iconsPath)\(weather).png")
        URLSession.shared.dataTask(with: url!) {
            data, response, error in
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.currentWeatherIcon.image = image
                
            }
            }.resume()
        
    }
    
    func setView(dailyConditionWeather: DailyConditionWeather)  {
        setPage()
        typeLabel.text = dailyConditionWeather.weather ?? ""
        dateLabel.text = dailyConditionWeather.date
        rainLabel.text = "Wilgotność powietrza: \(dailyConditionWeather.humidity ?? 0) %"
        windLabel.text = "Wiatr: \(dailyConditionWeather.windSpeed?.roundToPlaces() ?? 0) )"
        pressureLabel.text = "Ciśnienie atmosferyczne: \(dailyConditionWeather.pressure ?? 0) Bar"
        maximumTemperatureLabel.text = "Temperatura maksymalna: \(dailyConditionWeather.maxTemp.roundToPlaces()) C"
        minimalTemperatureLabel.text = "Temperatura minimalna: \(dailyConditionWeather.minTemp.roundToPlaces()) C"
    }
    
    var detailItem: NSDate? {
        didSet{
            //update view
        }
    }


}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces() -> Double {
        let divisor = pow(10.0, Double(2))
        return (self * divisor).rounded() / divisor
    }
}
