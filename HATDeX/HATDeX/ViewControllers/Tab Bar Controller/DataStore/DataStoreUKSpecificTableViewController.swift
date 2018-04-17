/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import HatForIOS
import SwiftyJSON

// MARK: Class

/// A class responsible for the profile name, in dataStore ViewController
internal class DataStoreUKSpecificTableViewController: UITableViewController, UserCredentialsProtocol, TextFieldDelegate {
    
    func textChangedOn(textField: UITextField, indexPath: IndexPath, date: Date?) {
        
        if indexPath.section == 0 {
            
            self.ukSpecificInfo?.nationalInsuranceNumber = textField.text ?? ""
        } else if indexPath.section == 1 {
            
            self.ukSpecificInfo?.uniqueTaxReference = textField.text ?? ""
        } else if indexPath.section == 2 {
            
            self.ukSpecificInfo?.nhsNumber = textField.text ?? ""
        } else if indexPath.section == 3 {
            
            self.ukSpecificInfo?.drivingLicenseNumber = textField.text ?? ""
        } else if indexPath.section == 4 {
            
            self.ukSpecificInfo?.passportNumber = textField.text ?? ""
        } else if indexPath.section == 5 {
            
            if date != nil {
                
                self.ukSpecificInfo?.passportExpiryDate = date!
            }
        } else if indexPath.section == 6 {
            
            self.ukSpecificInfo?.placeOfBirth = textField.text ?? ""
        } else if indexPath.section == 7 {
            
            self.ukSpecificInfo?.secondPassportNumber = textField.text ?? ""
        } else if indexPath.section == 8 {
            
            if date != nil {
                
                self.ukSpecificInfo?.secondPassportExpiryDate = date!
            }
        }
    }
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["National Insurance Number"], ["Unique Tax Reference"], ["NHS Number"], ["Driving License Number"], ["Passport Number"], ["Expiry date"], ["Place of birth"], ["Second passport Number"], ["Second passport Expiry date"]]
    /// The headers of the table view
    private let headers: [String] = ["National Insurance Number", "Unique Tax Reference", "NHS Number", "Driving License Number", "Passport Number", "Expiry date", "Place of birth", "Second passport Number", "Second passport Expiry date"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    private var ukSpecificInfo: UKSpecificInfo?
    
    // MARK: - IBAction
    
    /**
     Saves the profile to hat
     
     - parameter sender: The object that called this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.createPopUp()
        //self.updateModelFromUI()
        let numberOfSections = self.tableView.numberOfSections - 1
        
        for index in 0...numberOfSections {
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? PhataTableViewCell {
                
                cell.endTextFieldEditing()
            }
        }
        self.uploadInfoToHat()
    }
    
    // MARK: - Create error Alert
    
    /**
     Creates an error alert based on when the error occured
     
     - parameter title: The title of the alert
     - parameter message: The message of the alert
     - parameter error: The error to log on crashlytics
     */
    private func createErrorAlertWith(title: String, message: String, error: HATTableError) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingView.removeFromSuperview()
            self?.darkView.removeFromSuperview()
            
            self?.createClassicOKAlertWith(
                alertMessage: message,
                alertTitle: title,
                okTitle: "OK",
                proceedCompletion: {})
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }
    
    // MARK: - Upload info
    
    /**
     Uploads the model to hat
     */
    private func uploadInfoToHat() {
        
        func recordCreated() {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.loadingView.removeFromSuperview()
                self?.darkView.removeFromSuperview()
                
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
        
        guard self.ukSpecificInfo != nil else {
            
            return
        }
        
        UKSpecificInfoCachingWrapperHelper.postUKSpecificInfo(
            ukSpecificInfo: self.ukSpecificInfo!,
            userToken: userToken,
            userDomain: userDomain,
            successCallback: recordCreated,
            errorCallback: failedGettingInfo)
    }
    
    // MARK: - Create PopUp
    
    /**
     Creates Updating profile... pop up while the uploading is taking place
     */
    private func createPopUp() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            weakSelf.darkView = UIView(frame: weakSelf.view.frame)
            weakSelf.darkView.backgroundColor = .black
            weakSelf.darkView.alpha = 0.4
            
            weakSelf.view.addSubview(weakSelf.darkView)
            
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: (weakSelf.view?.frame.midX)! - 70, y: (weakSelf.view?.frame.midY)! - 15, width: 140, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Updating profile...",
                textColor: .white,
                font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        }
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.getUKInfoFromHAT()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreUKSpecificInfoCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreNameCell, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.accessoryType = .none
        cell.delegate = self
        cell.indexPath = indexPath
        guard self.ukSpecificInfo != nil else {
            
            cell.setTagInTextField(tag: 1)
            return cell
        }
        
        if indexPath.section == 0 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.nationalInsuranceNumber)
            cell.setTagInTextField(tag: 1)
        } else if indexPath.section == 1 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.uniqueTaxReference)
            cell.setTagInTextField(tag: 1)
        } else if indexPath.section == 2 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.nhsNumber)
            cell.setTagInTextField(tag: 1)
        } else if indexPath.section == 3 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.drivingLicenseNumber)
            cell.setTagInTextField(tag: 1)
        } else if indexPath.section == 4 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.passportNumber)
            cell.setTagInTextField(tag: 1)
        } else if indexPath.section == 5 {
            
            cell.setTextToTextField(
                text: FormatterHelper.formatDateStringToUsersDefinedDate(
                date: self.ukSpecificInfo!.passportExpiryDate,
                dateStyle: .short,
                timeStyle: .none)
            )
            cell.selectedDate = self.ukSpecificInfo!.passportExpiryDate
            cell.setKeyboardType(.default)
            cell.setTagInTextField(tag: 12)
        } else if indexPath.section == 6 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.placeOfBirth)
            cell.setTagInTextField(tag: 5)
        } else if indexPath.section == 7 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo!.secondPassportNumber)
        } else if indexPath.section == 8 {
            
            cell.setTextToTextField(
                text: FormatterHelper.formatDateStringToUsersDefinedDate(
                    date: self.ukSpecificInfo!.secondPassportExpiryDate,
                    dateStyle: .short,
                    timeStyle: .none)
            )
            cell.selectedDate = self.ukSpecificInfo!.passportExpiryDate
            cell.setKeyboardType(.default)
            cell.setTagInTextField(tag: 12)
        }
        
        return cell
    }
    
    func failedGettingInfo(error: HATTableError) {
        
        DispatchQueue.main.async { [weak self] in

            self?.tableView.isUserInteractionEnabled = true
            self?.loadingView.removeFromSuperview()
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }
    
    func getUKInfoFromHAT() {
        
        func gotInfo(array: [UKSpecificInfo], newToken: String?) {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.tableView.isUserInteractionEnabled = true
                self?.loadingView.removeFromSuperview()
                
                if !array.isEmpty {
                    
                    self?.ukSpecificInfo = array[0]
                } else {
                    
                    self?.ukSpecificInfo = UKSpecificInfo()
                }
                
                self?.tableView.reloadData()
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.isUserInteractionEnabled = false
            guard let midX = self?.tableView?.frame.midX,
                let midY = self?.tableView?.frame.midY,
                let font = UIFont(name: Constants.FontNames.openSans, size: 12),
                let weakSelf = self else {
                    
                    return
            }
            
            weakSelf.loadingView.removeFromSuperview()
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: midX - 70, y: midY - 15, width: 160, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Loading HAT data...",
                textColor: .white,
                font: font)
            
            UKSpecificInfoCachingWrapperHelper.getUKSpecificInfo(
                userToken: weakSelf.userToken,
                userDomain: weakSelf.userDomain,
                cacheTypeID: "ukSpecificInfo",
                successRespond: gotInfo,
                failRespond: weakSelf.failedGettingInfo)
        }
    }
    
}
