//
//  ViewController.swift
//  Lab03
//
//  Created by Prijay Khadilkar on 2022-07-28.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    private let locationManager = CLLocationManager()
//    private let locationManagerDelegate = MyLocationManagerDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextfield.delegate = self
//        displayIcon()
        locationManager.delegate = self
    }

    func displayIcon(iconCode: Int) {
        let iconName = iconSwitch(code: iconCode)
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .systemBlue])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: iconName)
    }
    
    func iconSwitch(code: Int) -> String {
        switch code {
        case 1000:
            return "sun.min.fill"
        case 1001:
            return "cloud.sun.fill"
        case 1003:
            return "cloud.sun.fill"
        case 1006, 1009:
            return "cloud.fill"
        case 1030:
            return "sun.haze"
        case 1063:
            return "cloud.drizzle.fill"
        case 1066:
            return "cloud.snow"
        case 1072:
            return "cloud.snow.fill"
        case 1087:
            return "tornado"
        case 1114:
            return "cloud.sleet.fill"
        case 1117:
            return "wind.snow"
        case 1135, 1147:
            return "smoke.fill"
        case 1150, 1153, 1168, 1171:
            return "cloud.drizzle"
        case 1180, 1183, 1186, 1189, 1192, 1195 :
            return "cloud.rain.fill"
        case 1198, 1201, 1204:
            return "cloud.sleet.fill"
        case 1207:
            return "cloud.sleet"
        case 1210, 1213, 1216, 1219, 1222, 1225, 1237:
            return "snowflake.circke"
        case 1240, 1243, 1246, 1249, 1252:
            return "cloud.rain.fill"
        case 1255, 1258, 1261, 1264:
            return "cloud.snow.fill"
        case 1273, 1276, 1279, 1282:
            return "cloud.bolt.rain.fill"
        default:
            return "exclamationmark.triangle"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadWeather(search: searchTextfield.text ?? "")
        textField.endEditing(true)
        return true
    }
    @IBAction func searchTap(_ sender: UIButton) {
        loadWeather(search: searchTextfield.text ?? "")
    }
    
    @IBAction func locationTap(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("lat: \(latitude), lon: \(longitude)")
            let locationQuery = "\(latitude),\(longitude)"
            loadWeather(search: locationQuery)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private func loadWeather(search: String?){
        guard let search = search else {
            return
        }
        
        guard let url = getURL(query: search) else {
            print("could not get the url.")
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("load weather called")
            
            guard error ==  nil else {
                print("Received error")
                return
            }
            
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.condition.code)
                
                DispatchQueue.main.async {
                    self.temperatureLabel.text = "\(weatherResponse.current.temp_c) °C"
                    self.locationLabel.text = weatherResponse.location.name
                    self.conditionLabel.text = weatherResponse.current.condition.text
                    self.displayIcon(iconCode: weatherResponse.current.condition.code)
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL?{
        let apiKey = "039a81c3897d4c8ab1f150751222807"
        guard let url = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(query)&aqi=no".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error decoding.")
        }
        return weather
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current:  Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}
