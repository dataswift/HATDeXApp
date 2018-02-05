/**
 * Copyright (C) 2018 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import Haneke
import HatForIOS
import RealmSwift
import SwiftyJSON

// MARK: Struct

internal struct NotesCachingWrapperHelper {
    
    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesV2Object], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, parameters: Dictionary<String, String>, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATNotesObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATNotablesService.getNotes(
                userDomain: userDomain,
                userToken: userToken,
                parameters: parameters,
                success: successRespond,
                failed: failRespond)
        }
    }
    
    // MARK: - Get system status
    
    /**
     Gets the system status from the hat
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter successRespond: A completion function of type ([HATNotesV2Object], String?) -> Void
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     */
    static func getNotes(userToken: String, userDomain: String, cacheTypeID: String, parameters: Dictionary<String, String>, successRespond: @escaping ([HATNotesObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.hour,
            value: 1,
            networkRequest: NotesCachingWrapperHelper.request(
                userToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                failRespond: failRespond),
            completion: successRespond)
    }
    
    // MARK: - Delete Note
    
    /**
     Deletes note
     
     - parameter noteID: The note's to be deleted ID
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     */
    static func deleteNote(noteID: String, userToken: String, userDomain: String, cacheTypeID: String, completion: (() -> Void)? = nil) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: noteID)
        
        let dictionary = ["id": noteID]
        
        // adding note to be deleted in cache
        let jsonObject = JSONCacheObject(dictionary: [dictionary], type: cacheTypeID, expiresIn: nil, value: nil)
        
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }
            
            try realm.write {
                
                realm.add(jsonObject)
                completion?()
            }
        } catch {
            
            print("adding note to delete failed")
        }
        
        // check in cache for unsynced deletes
        NotesCachingWrapperHelper.checkForUnsyncedDeletes(userDomain: userDomain, userToken: userToken)
    }
    
    // MARK: - Post Note
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func postNote(note: HATNotesObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: note.recordId)
        
        var note = note
        note.data.authorv1.phata = userDomain
        
        let date = Date()
        let dateString = HATFormatterHelper.formatDateToISO(date: date)
        
        note.data.updated_time = dateString
        if note.data.created_time == "" {
            
            note.data.created_time = dateString
        }
        
        // creating note to be posted in cache
        var dictionary = note.toJSON()
        if let photo = note.data.photov1 {
            
            if photo.link != "" && photo.link != nil {
                
                guard let url = URL(string: photo.link!) else {
                    
                    return
                }
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                imageView.hnk_setImage(
                    from: url,
                    placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                    headers: ["x-auth-token": userToken],
                    success: { image in
                        
                        guard image != nil else {
                            
                            return
                        }
                        
                        if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
                            
                            dictionary.updateValue(imageData, forKey: "imageData")
                        }
                },
                    failure: { _ in return },
                    update: { _ in return })
            }
        }
        
        // adding note to be posted in cache
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "notes", expiresIn: .hour, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "notes-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
                
                successCallback()
            }
        } catch {
            
            print("adding to notes to Post failed")
        }
    }
    
    // MARK: - Update Note
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func updateNote(note: HATNotesObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: note.recordId)
        
        var tempNote = note
        tempNote.data.authorv1.phata = userDomain
        
        let date = Date()
        let dateString = HATFormatterHelper.formatDateToISO(date: date)
        
        tempNote.data.updated_time = dateString
        if tempNote.data.created_time == "" {
            
            tempNote.data.created_time = dateString
        }
        
        if tempNote.data.locationv1?.latitude == nil {
            
            tempNote.data.locationv1 = nil
        }
        
        // creating note to be posted in cache
        var dictionary = tempNote.toJSON()
        if let photo = tempNote.data.photov1 {
            
            if photo.link != "" && photo.link != nil {
                
                guard let url = URL(string: photo.link!) else {
                    
                    return
                }
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                imageView.hnk_setImage(
                    from: url,
                    placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                    headers: ["x-auth-token": userToken],
                    success: { image in
                        
                        guard image != nil else {
                            
                            return
                        }
                        
                        if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
                            
                            dictionary.updateValue(imageData, forKey: "imageData")
                        }
                },
                    failure: { _ in return },
                    update: { _ in return })
            }
        }
        
        // adding note to be posted in cache
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "notes", expiresIn: .hour, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "notes-Update", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
                
                successCallback()
            }
        } catch {
            
            print("adding to notes to Post failed")
        }
    }
    
    // MARK: - Check cache for unsynced stuff
    
    /**
     Check for notes to be deleted in cache
     
     - parameter cacheTypeID: The cache type to request
     - parameter noteID: The note's to be deleted ID
     */
    static func checkForNotesInCacheToBeDeleted(cacheTypeID: String, noteID: String) {
        
        // get notes from cache
        guard let notesFromCache = CachingHelper.getFromRealm(type: cacheTypeID),
            let realm = RealmHelper.getRealm() else {
                
                return
        }
        
        // iterate through the results and parse it to HATNotesV2Object. If noteID = ID to be deleted, delete it.
        for element in notesFromCache where element.jsonData != nil && !realm.isInWriteTransaction {
            
            if var dictionary = NSKeyedUnarchiver.unarchiveObject(with: element.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(dictionary)
                for (index, item) in json.arrayValue.enumerated() {
                    
                    let tempNote = HATNotesObject(dict: item.dictionaryValue)
                    if tempNote.recordId == noteID {
                        
                        dictionary.remove(at: index)
                        
                        do {
                            
                            guard let realm = RealmHelper.getRealm() else {
                                
                                return
                            }
                            
                            try realm.write {
                                
                                realm.delete(element)
                                
                                let jsonObject = JSONCacheObject(dictionary: dictionary, type: "notes", expiresIn: .hour, value: 1)
                                realm.add(jsonObject)
                            }
                        } catch {
                            
                            print("error deleting from cache")
                        }
                    }
                }
            }
        }
    }
    
    /**
     Checks for unsynced deletes
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedDeletes(userDomain: String, userToken: String) {
        
        // Try deleting the notes
        func tryDeleting(notes: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempNote in notes where tempNote.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let dictionary = JSON(tempDict)
                    var note = HATNotesObject()
                    note.recordId = dictionary[0]["id"].stringValue
                    
                    HATNotablesService.deleteNotes(
                        noteIDs: [note.recordId],
                        userToken: userToken,
                        userDomain: userDomain,
                        success: { _ in
                            
                            do {
                                
                                guard let realm = RealmHelper.getRealm() else {
                                    
                                    return
                                }
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                }
                            } catch {
                                
                                print("error deleting from cache")
                            }
                    },
                        failed: { error in
                            
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                    })
                }
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Delete", sync: tryDeleting)
    }
    
    /**
     Checks for unsynced notes to post
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedNotesToPost(userDomain: String, userToken: String, completion: (() -> Void)? = nil) {
        
        // Try deleting the notes
        func tryPosting(notes: [JSONCacheObject]) {
            
            completion?()
            
            // for each note parse it and try to delete it
            for tempNote in notes where tempNote.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                func postNote(_ note: HATNotesObject) {
                    
                    func innerPostNote(_ note: HATNotesObject) {
                        
                        var temp = note
                        
                        // remove location and public_until since it can mess up Notables
                        if temp.data.locationv1?.latitude == nil || (temp.data.locationv1?.latitude == 0 && temp.data.locationv1?.longitude == 0 && temp.data.locationv1?.accuracy == 0) {
                            
                            temp.data.locationv1 = nil
                        }
                        
                        if temp.data.public_until == "" {
                            
                            temp.data.public_until = nil
                        }
                        
                        HATNotablesService.postNote(
                            userDomain: userDomain,
                            userToken: userToken,
                            note: temp,
                            successCallBack: { newNote, _ in
                                
                                do {
                                    
                                    guard let realm = RealmHelper.getRealm() else {
                                        
                                        return
                                    }
                                    
                                    try realm.write {
                                        
                                        realm.delete(tempNote)
                                        
                                        if let results = CachingHelper.getFromRealm(type: "notes") {
                                            
                                            for var item in results {
                                                
                                                if let jsonObject = NSKeyedUnarchiver.unarchiveObject(with: item.jsonData!) as? [Dictionary<String, Any>],
                                                    !jsonObject.isEmpty {
                                                    
                                                    let json = JSON(jsonObject[0])
                                                    var temp = HATNotesObject(dict: json.dictionaryValue)
                                                    
                                                    if temp.data.created_time == newNote.data.created_time {
                                                        
                                                        realm.delete(item)
                                                        temp.recordId = newNote.recordId
                                                        temp.endpoint = newNote.endpoint
                                                        item = JSONCacheObject(dictionary: [temp.toJSON()], type: "notes", expiresIn: nil, value: nil)
                                                        
                                                        realm.add(item)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } catch {
                                    
                                    print("error deleting from cache")
                                }
                            },
                            errorCallback: { error in
                                
                                CrashLoggerHelper.hatTableErrorLog(error: error)
                            }
                        )
                    }
                    
                    if note.data.updated_time != note.data.created_time {
                        
                        deleteNote(noteID: note.recordId, userToken: userToken, userDomain: userDomain, cacheTypeID: "notes-Delete", completion: {
                            
                            innerPostNote(note)
                        })
                    } else {
                        
                        innerPostNote(note)
                    }
                }
                
                if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let dictionary = JSON(tempDict)
                    var note = HATNotesObject()
                    note.inititialize(dict: dictionary.arrayValue[0].dictionaryValue)
                    
                    if note.data.photov1?.link != "" {
                        
                        if (tempDict[0]["imageData"] as? Data) != nil {
                            
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                            let url = URL(string: note.data.photov1!.link!)
                            imageView.hnk_setImage(from: url)
                            
                            HATFileService.uploadFileToHATWrapper(
                                token: userToken,
                                userDomain: userDomain,
                                fileToUpload: imageView.image!,
                                tags: ["photo", "iPhone", "notes"],
                                progressUpdater: nil,
                                completion: { (file, newToken) in
                                    
                                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: newToken)
                                    
                                    PresenterOfShareOptionsViewController.checkFilePublicOrPrivate(
                                        fileUploaded: file,
                                        receivedNote: note,
                                        viewController: nil,
                                        success: { imageURL in
                                            
                                            note.data.photov1 = HATNotesPhotoObject()
                                            note.data.photov1?.link = imageURL
                                            postNote(note)
                                    }
                                    )
                            },
                                errorCallBack: nil
                            )
                        } else {
                            
                            postNote(note)
                        }
                    } else {
                        
                        postNote(note)
                    }
                }
            }
            
            if notes.isEmpty {
                
                completion?()
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Post", sync: tryPosting)
    }
    
    /**
     Checks for unsynced notes to update
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedNotesToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil) {
        
        // Try deleting the notes
        func tryPosting(notes: [JSONCacheObject]) {
            
            completion?()
            
            // for each note parse it and try to delete it
            for tempNote in notes where tempNote.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                func updateNote(_ note: HATNotesObject) {
                    
                    var temp = note
                    
                    // remove location and public_until since it can mess up Notables
                    if temp.data.locationv1?.latitude == nil || (temp.data.locationv1?.latitude == 0 && temp.data.locationv1?.longitude == 0 && temp.data.locationv1?.accuracy == 0) {
                        
                        temp.data.locationv1 = nil
                    }
                    
                    if temp.data.public_until == "" {
                        
                        temp.data.public_until = nil
                    }
                    
                    HATNotablesService.updateNote(
                        note: temp,
                        userToken: userToken,
                        userDomain: userDomain,
                        success: { _, _ in
                            
                            do {
                                
                                guard let realm = RealmHelper.getRealm() else {
                                    
                                    return
                                }
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                }
                            } catch {
                                
                                print("error deleting from cache")
                            }
                    },
                        failed: { error in
                            
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                    }
                    )
                }
                
                if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let dictionary = JSON(tempDict)
                    var note = HATNotesObject()
                    note.inititialize(dict: dictionary.arrayValue[0].dictionaryValue)
                    
                    if note.data.photov1?.link != "" {
                        
                        if (tempDict[0]["imageData"] as? Data) != nil {
                            
                            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                            let url = URL(string: note.data.photov1!.link!)
                            imageView.hnk_setImage(from: url)
                            
                            if imageView.image != nil {
                                
                                HATFileService.uploadFileToHATWrapper(
                                    token: userToken,
                                    userDomain: userDomain,
                                    fileToUpload: imageView.image!,
                                    tags: ["photo", "iPhone", "notes"],
                                    progressUpdater: nil,
                                    completion: { (file, newToken) in
                                        
                                        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: newToken)
                                        
                                        PresenterOfShareOptionsViewController.checkFilePublicOrPrivate(
                                            fileUploaded: file,
                                            receivedNote: note,
                                            viewController: nil,
                                            success: { imageURL in
                                                
                                                note.data.photov1 = HATNotesPhotoObject()
                                                note.data.photov1?.link = imageURL
                                                
                                                updateNote(note)
                                            }
                                        )
                                    },
                                    errorCallBack: nil
                                )
                            }
                        } else {
                            
                            updateNote(note)
                        }
                    } else {
                        
                        updateNote(note)
                    }
                }
            }
            
            if notes.isEmpty {
                
                completion?()
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Update", sync: tryPosting)
    }
    
    static func addImageToNote(recordID: String, link: String, userToken: String, image: UIImage? = nil) {
        
        guard let results = CachingHelper.getFromRealm(type: "notes") else {
            
            return
        }
        
        for tempNote in results where tempNote.jsonData != nil {
            
            func saveImage(image: UIImage?, index: Int, dict: [Dictionary<String, Any>]) {
                
                guard let image = image else {
                    
                    return
                }
                
                var dict = dict
                if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                    
                    do {
                        
                        dict[index].updateValue(imageData, forKey: "imageData")
                        
                        guard let realm = RealmHelper.getRealm() else {
                            
                            return
                        }
                        
                        try realm.write {
                            
                            tempNote.jsonData = NSKeyedArchiver.archivedData(withRootObject: dict)
                            realm.add(tempNote)
                        }
                    } catch {
                        
                        print("error updating cache with image")
                    }
                }
            }
            
            if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(tempDict)
                var newNote = HATNotesObject()
                for (index, dictionary) in json.arrayValue.enumerated() {
                    
                    newNote.inititialize(dict: dictionary.dictionaryValue)
                    
                    if image != nil {
                        
                        saveImage(image: image, index: index, dict: tempDict)
                    } else if newNote.recordId == recordID {
                        
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
                        let url = URL(string: (newNote.data.photov1?.link)!)
                        imageView.hnk_setImage(
                            from: url,
                            placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                            headers: ["x-auth-token": userToken],
                            success: { image in
                                
                                saveImage(image: image, index: index, dict: tempDict)
                        },
                            failure: nil,
                            update: nil)
                    }
                }
            }
        }
    }
    
    /**
     Checks for unsynced cache
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedCache(userDomain: String, userToken: String) {
        
        // if user is connected to the internet try to sync cache
        if Reachability.isConnectedToNetwork() {
            
            NotesCachingWrapperHelper.checkForUnsyncedDeletes(userDomain: userDomain, userToken: userToken)
            NotesCachingWrapperHelper.checkForUnsyncedNotesToPost(userDomain: userDomain, userToken: userToken)
            NotesCachingWrapperHelper.checkForUnsyncedNotesToUpdate(userDomain: userDomain, userToken: userToken)
        }
    }
}
