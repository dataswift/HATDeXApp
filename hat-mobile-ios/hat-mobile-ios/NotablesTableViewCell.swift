//
//  NotablesTableViewCell.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 8/11/16.
//  Copyright © 2016 Green Custard Ltd. All rights reserved.
//

import UIKit

// MARK: Class

/// the notables table view cell class
class NotablesTableViewCell: UITableViewCell, UICollectionViewDataSource {
    
    // MARK: - Variables
    
     var sharedOn: [String] = []
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the info of the post
    @IBOutlet weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the data of the post
    @IBOutlet weak var postDataLabel: UILabel!
    /// An IBOutlet for handling the username of the post
    @IBOutlet weak var usernameLabel: UILabel!
    /// An IBOutlet for handling the profile image of the post
    @IBOutlet weak var profileImage: UIImageView!
    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Setup cell
    
    /**
     Sets up the cell from the note
     
     - parameter cell: The cell to set up
     - parameter note: The data to show on the cell
     - parameter indexPath: The index path of the cell
     - returns: NotablesTableViewCell
     */
    func setUpCell(_ cell: NotablesTableViewCell, note: NotesData, indexPath: IndexPath) -> NotablesTableViewCell {
        
        let newCell = self.initCellToNil(cell: cell)
        
        // if the note is shared get the shared on string as well
        if note.data.shared {
            
            newCell.sharedOn = note.data.sharedOn.stringToArray()
            self.sharedOn = newCell.sharedOn
        }
        
        // get the notes data
        let notablesData = note.data
        // get the author data
        let authorData = notablesData.authorData
        // get the last updated date
        let date = FormatterHelper.formatDateStringToUsersDefinedDate(date: note.lastUpdated)

        // format the info label
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSStrokeColorAttributeName: UIColor.init(colorLiteralRed: 0/255, green: 150/255, blue: 136/255, alpha: 1),
            NSFontAttributeName: UIFont(name: "Open Sans", size: 11)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let string = "Posted "+date
        var shareString: String = ""
        if !notablesData.shared {
            
            shareString = " Private Note"
        }
        
        let partOne = NSAttributedString(string: string)
        let partTwo = NSAttributedString(string: shareString, attributes: textAttributes)
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
                
        // create this zebra like color based on the index of the cell
        if (indexPath.row % 2 == 1) {
            
            newCell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 51/255, green: 74/255, blue: 79/255, alpha: 1)
        }
        
        // show the data in the cell's labels
        newCell.postDataLabel.text = notablesData.message
        newCell.usernameLabel.text = authorData.phata
        newCell.postInfoLabel.attributedText = combination
        
        // flip the view to appear from right to left
        newCell.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        // return the cell
        return newCell
    }
    
    // MARK: - CollectionView datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // return the number of elements in the array
        return self.sharedOn.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // set up cell from the reuse identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "socialCell", for: indexPath) as!SocialImageCollectionViewCell
        
        // update the image of the cell accordingly
        if self.sharedOn[indexPath.row] == "facebook" {
            
            cell.socialImage.image = UIImage(named: "Facebook")
        } else if self.sharedOn[indexPath.row] == "marketsquare" {
            
            cell.socialImage.image = UIImage(named: "Marketsquare")
        }
        
        // flip the image to appear correctly
        cell.socialImage.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        //return the cell
        return cell
    }
    
    func initCellToNil(cell: NotablesTableViewCell) -> NotablesTableViewCell {
        
        cell.postDataLabel.text = ""
        cell.usernameLabel.text = ""
        cell.postInfoLabel.text = ""
        cell.sharedOn.removeAll()
        self.sharedOn.removeAll()
        cell.collectionView.reloadData()
        cell.contentView.backgroundColor = UIColor.init(colorLiteralRed: 29/255, green: 49/255, blue: 53/255, alpha: 1)

        return cell
    }
}