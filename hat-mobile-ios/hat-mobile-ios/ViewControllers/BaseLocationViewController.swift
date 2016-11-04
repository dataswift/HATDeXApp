/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit
import CoreLocation

class BaseLocationViewController: BaseViewController, CLLocationManagerDelegate {
    
    var updateCountDelegate: UpdateCountDelegate? = nil
    
    /// Load the LocationManager
    lazy var locationManager: CLLocationManager! = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = Helper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = Helper.GetUserPreferencesDistance()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.other /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        return locationManager
    }()
    
    /**
     Start tracking
     */
    func beginLocationTracking() -> Void {
        if let manager:CLLocationManager = locationManager
        {
            manager.startUpdatingLocation()
            NSLog("BaseLocation startUpdatingLocation");
            
        }
    }
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // clear down error display
        self.clearErrorDisplay()
        
        // get last location
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        // test that the horizontal accuracy does not indicate an invalid measurement
        if (latestLocation.horizontalAccuracy < 0)
        {
            return
        }
        // check we have a measurement that meets our requirements,
        if (latestLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            // add data
            let count = RealmHelper.AddData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
            
            //   while in foreground only
            if UIApplication.shared.applicationState == .active {
                
                if (self.updateCountDelegate != nil) {
                    self.updateCountDelegate?.onUpdateCount(count)
                }
            } else {
                //NSLog("App is backgrounded. New count is %i", count)
            }
        }
        
    }
    
    /*func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
     
     
     }*/
    
    /**
     Stop any location updates.e.g.logout
     */
    func stopUpdating() -> Void {
        
        // location manager is an optinal
        if let manager:CLLocationManager = self.locationManager
        {
            manager.stopUpdatingLocation()
            NSLog("BaseLocation stopUpdatingLocation");
            
        }
    }
    
    /**
     Display any error to user
     Mainly for Dev
     
     - parameter description: <#description description#>
     */
    func displayError(description: String) -> Void {
        if UIApplication.shared.applicationState == .active {
            
            if (self.updateCountDelegate != nil) {
                self.updateCountDelegate?.onUpdateError(description)
            }
        }
        
    }
    
    /**
     Clear any dispaly errors
     Mainly for dev
     
     */
    func clearErrorDisplay() -> Void {
        if UIApplication.shared.applicationState == .active {
            
            if (self.updateCountDelegate != nil) {
                self.updateCountDelegate?.onUpdateError("")
            }
        }
    }
    
    
    /**
     When app entered background
     
     - parameter notification: <#notification description#>
     */
    override func didEnterBackgroundNotification(_ notification: Notification){
        //super
        super.didEnterBackgroundNotification(notification)
        
        // stop updating
        //stopUpdating()
        
    }
    
    /**
     When app becomes active
     
     - parameter notification: default notification
     */
    override func didBecomeActiveNotification(_ notification: Notification){
        super.didBecomeActiveNotification(notification)
        
        // start normal location updates
        beginLocationTracking();
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}