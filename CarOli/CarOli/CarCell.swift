//
//  File.swift
//  CarOli
//
//  Created by zz on 05/12/2017.
//  Copyright © 2017 Lesta. All rights reserved.
//

import UIKit
class CarCell: UITableViewCell {
    @IBOutlet var brandLabel: UILabel!
    @IBOutlet var manufactureLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var gearboxLabel: UILabel!
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var displacementLabel: UILabel!
    @IBOutlet var oilConsumptionLabel: UILabel!
    var car:Car! {
        didSet {
            brandLabel.text = car.brand
            manufactureLabel.text = car.manufacture
            yearLabel.text = car.year
            gearboxLabel.text = car.gearbox
            modelLabel.text = car.model
            displacementLabel.text = car.displacement
            var consum = "油耗"
            
            if let consumption = car.oilConsumption {
                consum += consumption + "L"
            }
            oilConsumptionLabel.text =  consum
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
