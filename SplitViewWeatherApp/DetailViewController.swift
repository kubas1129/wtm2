//
//  DetailViewController.swift
//  SplitViewWeatherApp
//
//  Created by Guest User on 30.10.2019.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //Var and let
    let form = DateFormatter()
    var url = "https://www.metaweather.com/api/location/"
    let dtForm = "yyyy/MM/dd"
    var actualDay = 0
    let maxDayLookup = 5
    var now = Date()
    var cityName = ""
    var woeid = 0
    
    struct WeatherInfo{
        var date : String
        var minTemp: Double
        var maxTemp: Double
        var pressure : Double?
        var weather : String?
        var humidity : Int?
        var windSpeed: Double?
        var windDirection: String?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSetup()
    }
    
    func initSetup() {
        form.dateFormat = dtForm
    }
    
    func showWeather(name: String, woeid: Int){
        form.dateFormat = dtForm
        self.cityName = name
        self.woeid = woeid
        parseJSON(date: now)
    }
    
    
    @IBAction func prevButton(_ sender: Any) {
        if(actualDay > -maxDayLookup)
        {
            nextButton.isEnabled = true
            actualDay -= 1
            let updatedDate = Calendar.current.date(byAdding: .day, value: actualDay, to: now) ?? now
            parseJSON(date: updatedDate)
        }
        else
        {
            prevButton.isEnabled = false
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if (actualDay < maxDayLookup)
        {
            prevButton.isEnabled = true
            actualDay += 1
            let updatedDate = Calendar.current.date(byAdding: .day, value: actualDay, to: now) ?? now
            parseJSON(date: updatedDate)
        }
        else
        {
            nextButton.isEnabled = false
        }
    }
    
    
    func updateImage(imgInfo: String){
        let icons = "https://www.metaweather.com/static/img/weather/png/64/"
        let tempUrl = URL(string:"\(icons)\(imgInfo).png")
        
        URLSession.shared.dataTask(with: tempUrl!){
            data,resp,err in
            DispatchQueue.main.async {
                let img = UIImage(data: data!)
                //Updating image
                self.weatherImage.image =  img
            }
            }.resume()
    }
    
    
    func parseJSON(date: Date) {
        let strDate = form.string(from: date)
        let fullUrl = URL(string: "\(url)\(woeid)/\(strDate)")
        print("ADRES: \(fullUrl)")
        
        URLSession.shared.dataTask(with: fullUrl!) {
            data, resp, err in
            let dateJson = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]]
            
            let firstRecord = dateJson!![0]
            
            let weatherInfo = WeatherInfo(date: strDate,
                                          minTemp: firstRecord["min_temp"] as! Double,
                                          maxTemp: firstRecord["max_temp"] as! Double,
                                          pressure: firstRecord["air_pressure"] as? Double,
                                          weather: firstRecord["weather_state_abbr"] as? String,
                                          humidity: firstRecord["humidity"] as? Int,
                                          windSpeed: firstRecord["wind_speed"] as? Double,
                                          windDirection: firstRecord["wind_direction_compass"] as? String)
            
            DispatchQueue.main.async{
                //method to update UI
                self.updateUI(state: weatherInfo)
            }
            
            //loading image
            self.updateImage(imgInfo: weatherInfo.weather ?? "")
            
            }.resume()
    }
    
    func updateUI(state: WeatherInfo)  {
        //exec -> updatePage
        weatherCondition.text = state.weather ?? ""
        dateLabel.text = state.date
        maxTempLabel.text = "Max: \(state.maxTemp.roundDouble()) C"
        minTempLabel.text = "Min: \(state.minTemp.roundDouble()) C"
        velocityLabel.text = "\(state.windSpeed?.roundDouble() ?? 0)"
        directionLabel.text = "\(state.windDirection ?? "")"
        cityLabel.text = "\(cityName)"
    }
    

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            
        }
    }


}

extension Double {
    /// Rounds the double to decimal places value
    func roundDouble() -> Double {
        let divisor = pow(10.0, Double(2))
        return (self * divisor).rounded() / divisor
    }
}
