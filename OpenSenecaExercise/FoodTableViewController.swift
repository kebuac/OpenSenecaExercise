//
//  FoodTableViewController.swift
//  OpenSenecaExercise
//
//  Created by Kevin Bustillos Acurio on 9/1/17.
//  Copyright © 2017 Kebuac. All rights reserved.
//

import UIKit
import SDWebImage

// Flickr API Key must be changed every 24h because i'm using a temporary key. Just visit https://www.flickr.com/services/api/explore/flickr.photos.getRecent make a call and on the bottom will appear a URL where you can take the api key
private let flickrApiKey: String = "7512756ec3e4421c47b92a59361f1a96"
private let flickrRoute: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(flickrApiKey)&per_page=4&format=json&nojsoncallback=1"

class FoodTableViewController: UITableViewController {

    // MARK: - Properties
    
    var photosURL: [URL] = []
    
    let flickrURL: URL = URL(string: flickrRoute)!
    
    @IBOutlet var qualityImageView: UIImageView!
    @IBOutlet var serviceImageView: UIImageView!
    @IBOutlet var restaurantIndustryImageView: UIImageView!
    @IBOutlet var meatShopImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.request(to: self.flickrURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func request(to url: URL) {
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json: [String: Any] = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            
            guard let root: [String: Any] = json["photos"] as? [String: Any] else {
                return
            }
            
            guard let photos: [[String: Any]] = root["photo"] as? [[String: Any]] else {
                return
            }
            
            for p in photos {
                let id: String = p["id"] as! String
                
                self.request(byID: id)
            }
            
        }.resume()
    }
    
    func request(byID id: String) {
        URLSession.shared.dataTask(with: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=\(flickrApiKey)&photo_id=\(id)&format=json&nojsoncallback=1")!) {data, response, error in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json: [String: Any] = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            
            guard let root: [String: Any] = json["photo"] as? [String: Any] else { return }
            
            guard let farm: UInt8 = root["farm"] as? UInt8 else { return }
            
            guard let server: String = root["server"] as? String else { return }
            
            guard let secret: String = root["secret"] as? String else { return }
           
            let photoURL: URL = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!
            
            self.photosURL.append(photoURL)
            
            if self.photosURL.count == 4 {
                DispatchQueue.main.async(execute: {
                    self.qualityImageView.sd_setImage(with: self.photosURL[0])
                    self.serviceImageView.sd_setImage(with: self.photosURL[1])
                    self.restaurantIndustryImageView.sd_setImage(with: self.photosURL[2])
                    self.meatShopImageView.sd_setImage(with: self.photosURL[3])
                })
            }
        }.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
