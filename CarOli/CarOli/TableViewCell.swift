//
//  TableViewCell.swift
//  CarOli
//
//  Created by zz on 05/12/2017.
//  Copyright © 2017 Lesta. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var brandLabel: UILabel!
    @IBOutlet var manufactureLabel: UILabel!
    @IBOutlet var seriesLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var gearboxLabel: UILabel!
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var displacementLabel: UILabel!
    @IBOutlet var oilConsumptionLabel: UILabel!
    var car:Car! {
        didSet {
            brandLabel.text = car.brand
            manufactureLabel.text = car.manufacture
            seriesLabel.text = car.series
            yearLabel.text = car.year + "款"
            gearboxLabel.text = car.gearbox
            modelLabel.text = car.model
            displacementLabel.text = car.displacement
            var consum = "油耗:"
            
            if let consumption = car.oilConsumption {
                consum += consumption + "L"
            }
            oilConsumptionLabel.text =  consum
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
