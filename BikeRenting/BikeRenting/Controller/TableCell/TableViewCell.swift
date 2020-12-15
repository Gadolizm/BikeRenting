//
//  TableViewCell.swift
//  BikeRenting
//
//  Created by Gado on 04/12/2020.
//

import UIKit

class TableViewCell: UITableViewCell {

    // MARK:- Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var availabilitySwitch: UISwitch!
    
    // MARK:- Properties
    
    static let identifier = "TableViewCell"

    // MARK:- Override Functions
    // viewDidLoad
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK:- Actions
    
    
    // MARK:- Methods
    
    

    
}
