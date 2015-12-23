//
//  ViewController.swift
//  DropDown2
//
//  Created by Quinn Sheridan on 12/1/15.
//  Copyright © 2015 Quinn Sheridan. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

let path = NSBundle.mainBundle().pathForResource("MajorAirports", ofType: "plist")
let dict = NSDictionary(contentsOfFile: path!)
let airportDict = dict! as! [String : String]
var airportList = airportDict.values.sort()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var GPSButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var FlightNumber: UISearchBar! {
        didSet {
            FlightNumber.keyboardType = UIKeyboardType.NumberPad
        }
    }
    @IBOutlet weak var SearchButton: UIButton!
    
    var tableView: UITableView = UITableView()
    var tempAirportList  = airportList
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //view.backgroundColor = UIColor.blueColor()
        setupSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: helper function
    
    func returnAirports(search: String) -> [String]! {
        var searchList = [String]()
        if search == "" {
            return airportList
        }
        for airport in airportList {
            if airport.rangeOfString(search) != nil {
                searchList.append(airport)
            }
        }
        return searchList
    }
    
    //MARK: setup methods
    
    func setupSearchBar() {
        searchBar.layer.borderColor = UIColor.blackColor().CGColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true
        searchBar.delegate = self
    }
    
    func setupTableView() {
        searchBar.translucent = true
        //searchBar.layer.borderColor = UIColor.clearColor().CGColor
        searchBar.backgroundColor = UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        
        let textWidth = searchBar.frame.size.width
        let textHeight = searchBar.frame.size.height
        let textPositionX = searchBar.frame.origin.x
        let textPositionY = searchBar.frame.origin.y
        let dropDownPositionY = textHeight + textPositionY
        let dropDownPositionX = textPositionX
        let tableHeight = 6 * 27
        tableView.frame = CGRectMake(dropDownPositionX, dropDownPositionY, textWidth, CGFloat(tableHeight))
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        tableView.layer.cornerRadius = 5
        tableView.rowHeight = 27
        setupTableViewHeight()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
    }
    
    func setupTableViewHeight() {
        let textWidth = searchBar.frame.size.width
        let textHeight = searchBar.frame.size.height
        let textPositionX = searchBar.frame.origin.x
        let textPositionY = searchBar.frame.origin.y
        let dropDownPositionY = textHeight + textPositionY
        let dropDownPositionX = textPositionX
        var tableHeight = 6 * 27
        if tempAirportList.count < 6 {
          tableHeight = tempAirportList.count * 27
        }
        tableView.frame = CGRectMake(dropDownPositionX, dropDownPositionY, textWidth, CGFloat(tableHeight))
    }
    
    func setupGestureRecognizer() {
        let aSelector : Selector = "removeTableView"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    //MARK: tableview datasource methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempAirportList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel!.text = tempAirportList[indexPath.row]
        cell.textLabel!.font.fontWithSize(12)
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let airportText = tempAirportList[indexPath.row]
        searchBar.text = airportText
    }
    
    //MARK: Searchbar Delegate Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tempAirportList = returnAirports(searchText)
        tableView.reloadData()
        setupTableViewHeight()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        setupTableView()
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        tempAirportList = airportList
        print("did end editing")
        tableView.removeFromSuperview()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("searchBarSearchButton called")
        tableView.removeFromSuperview()
    }
    
    //MARK: Geo-Locate Airport Methods
    
    @IBAction func GPSButtonPressed(sender: UIButton) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    //MARK: CLLocationManger Delegates
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] //as! CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            locationManager.stopUpdatingLocation()
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""

            /*
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            print(String(locality!))
            print(String(postalCode!))
            print(String(administrativeArea!))
            print(String(country!))
            print(containsPlacemark.region) */
            
            for key in airportDict.keys {
                if postalCode == key {
                    print(airportDict[key]!)
                    let message = "Your are located at \(airportDict[key]!)"
                    let title = airportDict[key]!
                    let alert = UIAlertController(title: title , message: message, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "true", style: .Default, handler: nil)
                    alert.addAction(action)
                    presentViewController(alert, animated: true, completion: nil)
                    return
                }
            }
            
            let message2 = "We could not match your location to an airport"
            let title2 = "Sorry"
            let alert2 = UIAlertController(title: title2, message: message2, preferredStyle: .Alert)
            let action2 = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert2.addAction(action2)
            presentViewController(alert2, animated: true, completion: nil)
            
        }
    }
    
    //MARK: Search Button Method
    
    @IBAction func SearchButtonPressed(sender: UIButton) {
        let FlightNumberSelected = FlightNumber.text
        let AirportSelected = searchBar.text
        if AirportSelected == "" {
            let message = "You need to select your Airport"
            let title = "Unable to Search"
            let alert = UIAlertController(title: title , message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        } else if AirportSelected?.characters.count != 0 && FlightNumberSelected?.characters.count != 0 {
            let message = "You have selected Flight Number \(FlightNumberSelected) at \(AirportSelected) "
            let title = "\(AirportSelected)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        } else if AirportSelected?.characters.count != 0 {
            let message = "You have selected \(AirportSelected)"
            let title = "\(AirportSelected)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }

    }
    


}

