//  ViewController.swift
//  lab3
//
//  Created by Mandip Gurung on 2024-11-05.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var tmp: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var condition: UILabel!
 
    var ifCel: Bool = true
    var cel: Float = 0.0
    var fah: Float = 0.0

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        displayImg()
        txtSearch.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func searchontap(_ sender: UIButton) {
        weatherAPI(search: txtSearch.text)
    }
    
    @IBAction func convertor(_ sender: UISwitch) {
        ifCel = sender.isOn
        updateTemp()
    }
    
    @IBAction func navigation(_ sender: UIButton) {
        getCurrentLocation()
    }
 
    private func getCurrentLocation() {
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        weatherAPI(latitude: latitude, longitude: longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("No user location: \(error.localizedDescription)")
        showAlert(message: "Unable to access location")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        weatherAPI(search: textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func weatherAPI(search: String?) {
        guard let search = search, !search.isEmpty else {
            print("No search query provided")
            return
        }
        
        // Get the URL for the API call
        guard let url = gettingURL(query: search) else {
            print("Bad URL")
            return
        }
        
        let sessionCreate = URLSession.shared
        let task = sessionCreate.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error in API call")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            if let APIresponse = self.jsonData(data: data) {
                DispatchQueue.main.async {
                    self.location.text = APIresponse.location.name
                    self.condition.text = APIresponse.current.condition.text
                    
                    self.cel = APIresponse.current.temp_c
                    self.fah = APIresponse.current.temp_f
                    self.updateTemp()
                    
                    let code = APIresponse.current.condition.code
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGreen, .systemRed])
                    self.img.preferredSymbolConfiguration = config
                    
                    if code == 1000{
                         self.img.image = UIImage(systemName:"sun.max.fill")
                     } else if code == 1003{
                         self.img.image = UIImage(systemName:"cloud.sun.circle")
                     } else if code == 1006{
                         self.img.image = UIImage(systemName:"cloud.fog.circle")
                     } else if code == 1009{
                         self.img.image = UIImage(systemName:"cloud.drizzle.fill")
                     } else if code == 1030{
                         self.img.image = UIImage(systemName:"cloud.rain.fill")
                     } else if code == 1063{
                         self.img.image = UIImage(systemName:"cloud.snow.fill")
                     } else if code == 1066{
                         self.img.image = UIImage(systemName:"sun.snow.circle.fill")
                     } else if code == 1069{
                         self.img.image = UIImage(systemName:"cloud.fog.circle.fill")
                     } else if code == 1087 {
                         self.img.image = UIImage(systemName:"cloud.bolt.rain.fill")
                     } else if code == 1183 {
                         self.img.image = UIImage(systemName:"cloud.rain")
                     } else {
                         self.img.image = UIImage(systemName:"sunrise.circle.fill")
                     }
                    
                }
            }
        }
        task.resume()
    }

    private func weatherAPI(latitude: Double, longitude: Double) {
        guard let url = gettingURL(latitude: latitude, longitude: longitude) else {
            print("Bad URL")
            return
        }

        let sessionCreate = URLSession.shared
        let task = sessionCreate.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            if let APIresponse = self.jsonData(data: data) {
                DispatchQueue.main.async {
                    self.location.text = APIresponse.location.name
                    self.condition.text = APIresponse.current.condition.text
                    
                    self.cel = APIresponse.current.temp_c
                    self.fah = APIresponse.current.temp_f
                    self.updateTemp()
                    
                    let code = APIresponse.current.condition.code
                    let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGreen, .systemRed])
                    self.img.preferredSymbolConfiguration = config
                    
                    if code == 1000{
                         self.img.image = UIImage(systemName:"sun.max.fill")
                     } else if code == 1003{
                         self.img.image = UIImage(systemName:"cloud.sun.circle")
                     } else if code == 1006{
                         self.img.image = UIImage(systemName:"cloud.fog.circle")
                     } else if code == 1009{
                         self.img.image = UIImage(systemName:"cloud.drizzle.fill")
                     } else if code == 1030{
                         self.img.image = UIImage(systemName:"cloud.rain.fill")
                     } else if code == 1063{
                         self.img.image = UIImage(systemName:"cloud.snow.fill")
                     } else if code == 1066{
                         self.img.image = UIImage(systemName:"sun.snow.circle.fill")
                     } else if code == 1069{
                         self.img.image = UIImage(systemName:"cloud.fog.circle.fill")
                     } else if code == 1087 {
                         self.img.image = UIImage(systemName:"cloud.bolt.rain.fill")
                     } else if code == 1183 {
                         self.img.image = UIImage(systemName:"cloud.rain")
                     } else {
                         self.img.image = UIImage(systemName:"sunrise.circle.fill")
                     }
                }
            }
        }
        task.resume()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateTemp() {
        if ifCel {
            tmp.text = "\(cel) °C"
        } else {
            tmp.text = "\(fah) °F"
        }
    }

    private func gettingURL(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "0569614b693d430586582613240511"
        guard let url = "\(baseURL)\(endPoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }

    private func gettingURL(latitude: Double, longitude: Double) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let endPoint = "current.json"
        let apiKey = "0569614b693d430586582613240511"
        guard let url = "\(baseURL)\(endPoint)?key=\(apiKey)&q=\(latitude),\(longitude)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }

    private func jsonData(data: Data) -> APIresponse? {
        let changeData = JSONDecoder()
        var wth: APIresponse?
        do {
            wth = try changeData.decode(APIresponse.self, from: data)
        } catch {
            print("Decoding error")
        }
        return wth
    }

    private func displayImg() {
        let initialConfig = UIImage.SymbolConfiguration(paletteColors: [.systemRed, .systemGreen, .systemYellow])
        img.preferredSymbolConfiguration = initialConfig
        img.image = UIImage(systemName: "thermometer.low")
    }
    
    struct APIresponse: Decodable {
        let location: Location
        let current: Weather
    }
    
    struct Location: Decodable {
        let name: String
    }
    
    struct Weather: Decodable {
        let temp_c: Float
        let temp_f: Float
        let condition: Condition
    }
    
    struct Condition: Decodable {
        let text: String
        let code: Int
    }
}
