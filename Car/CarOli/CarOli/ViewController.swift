//
//  ViewController.swift
//  CarOli
//
//  Created by Li on 2017/11/27.
//  Copyright © 2017年 Lesta. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {

    
    @IBOutlet var dropDownLists: [HHDropDownList]!
    var xmlParser : XMLParser?
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    
    
    @IBOutlet var firBrandTF: UITextField!
    
    
    let cellID = "TableViewCell"
    
    
    var cars = [Car]() {
        didSet {
            filteredCars = cars
            if cars.isEmpty {
                manufactures = ["请选择"]
                serieses = ["请选择"]
                models = ["请选择"]
                years = ["请选择"]
                displacements = ["请选择"]
                gearboxes = ["请选择"]
            }else {
                if let firstCar = cars.first {
                    filterConditions = [firstCar.manufacture,firstCar.series,firstCar.model,firstCar.year,firstCar.displacement!,firstCar.gearbox!]
                }
                
                manufactures.removeAll()
                serieses.removeAll()
                models.removeAll()
                years.removeAll()
                displacements.removeAll()
                gearboxes.removeAll()
                for car in cars {
                    manufactures.uniqueAppend(car.manufacture)
                    serieses.uniqueAppend(car.series)
                    models.uniqueAppend(car.model)
                    years.uniqueAppend(car.year)
                    if let dp = car.displacement {
                        displacements.uniqueAppend(dp)
                    }
                    if let gb = car.gearbox {
                        gearboxes.uniqueAppend(gb)
                    }
                }
            }
            reloadDropdownList()
            
        }
    }
    
    var filteredCars = [Car]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    // for displacement
    var manufactures = [String]()
    var serieses = [String]()
    var models = [String]()
    var years = [String]()
    var displacements = [String]()
    var gearboxes = [String]()
    
    
    var filterConditions = [String].init(repeating: "请选择", count: 6)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (idx,dropDownItm) in dropDownLists.enumerated() {
            dropDownItm.delegate = self
            dropDownItm.dataSource = self
            dropDownItm.tag = idx
            dropDownItm.haveBorderLine = true
            dropDownItm.isExclusive = true
        }
        setupView()
        setupTable()
        search(brand: firBrandTF.text!)
    }
    
    func setupView() {
        firBrandTF.text = "日产"
        searchButton.layer.cornerRadius = 3.0
        searchButton.layer.borderColor = UIColor.lightGray.cgColor
        searchButton.layer.borderWidth = 1
        
        filterButton.layer.cornerRadius = 3.0
        filterButton.layer.borderColor = UIColor.lightGray.cgColor
        filterButton.layer.borderWidth = 1
    }
    
    @IBAction func filt(_ sender: Any) {
        filteredCars.removeAll()
        if filterConditions.contains(where: { (string) -> Bool in
            return string != "请选择"
        }) {
            filteredCars = cars.filter({ (car) -> Bool in
//                let bBrand = (firBrandTF.text == "请选择") ? false : (car.brand == firBrandTF.text)
                
                let bManufacture = (filterConditions[0] == "请选择") ? false : (car.manufacture == filterConditions[0])
                let bSeries = (filterConditions[1] == "请选择") ? false : (car.series == filterConditions[1])
                let bModel = (filterConditions[2] == "请选择") ? false : (car.model == filterConditions[2])
                let bYear = (filterConditions[3] == "请选择") ? false : (car.year == filterConditions[3])
                let bDisplacement = (filterConditions[4] == "请选择") ? false : (car.displacement == filterConditions[4])
                let bGearbox = (filterConditions[5] == "请选择") ? false : (car.gearbox == filterConditions[5])
                
                return bManufacture && bSeries && bModel && bYear && bDisplacement && bGearbox
            })
        }
        
    }
    
    @IBAction func search(_ sender: Any) {
        if let text = firBrandTF.text, !text.isEmpty {
            cars.removeAll()
            self.search(brand: text)
        }
    }
    
    func reloadDropdownList() {
        for ddl in dropDownLists {
            ddl.reloadData()
        }
    }
    
    func setupTable() {
        tableView.tableFooterView = UIView()
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 218
        tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func search(brand:String) {
        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/manufacturers/getManufacturers?brandId=\(brand.encode())").responseJSON { (response) in
            guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                return
            }
            for dic in arr {
                let manufacturersId = dic["manufacturersId"] as! String
                
                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/model/getModels?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())").responseJSON(completionHandler: { (response) in
                    guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                        return
                    }
                    for dic in arr {
                        let modelsId = dic["modelsId"] as! String
                        printLog(modelsId)
                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/salesName/getSalesNames?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())").responseJSON(completionHandler: { (response) in
                            guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                return
                            }
                            
                            for dic in arr {
                                let salesName = dic["salesName"] as! String
                                printLog(salesName)
                                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/year/getYears?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())&salesName=\(salesName.encode())").responseJSON(completionHandler: { (response) in
                                    guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                        return
                                    }
                                    
                                    for dic in arr {
                                        let compressId = dic["compressId"] as! String
                                        
                                        let year = dic["yearFull"] as! String
                                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/fuchs/getData", method: .post, parameters: ["compressId":compressId]).responseData(completionHandler: { (response) in
                                            let string = String.init(data: response.data!, encoding: .utf8)!
                                            guard let startRange = string.range(of: "发动机油") else {
                                                return
                                            }
                                            guard let endRange = string.range(of: "变速箱油") else {
                                                return
                                            }
                                            let subString = String(string[startRange.upperBound ..< endRange.lowerBound])
                                            let arr = subString.components(separatedBy: "</tr>")
                                            for index in 0 ..< arr.count - 1 {
                                                let subString = arr[index]
                                                guard let range = subString.range(of: "L") else {
                                                    continue
                                                }
                                                let result = subString[subString.index(range.lowerBound, offsetBy: -5) ..< range.lowerBound]
                                                let text = "\(brand);\(manufacturersId);\(modelsId);\(salesName);\(year);\(result)\n\n"
                                                let components = salesName.components(separatedBy: ",")
                                                var displacement : String?
                                                var gearBox : String?
                                                
                                                for (idx,component) in components.enumerated() {
                                                    let subComponents = component.components(separatedBy: " ")
                                                    if idx == 0 {
                                                        displacement = subComponents.first
                                                        gearBox = subComponents.last
                                                        
                                                    }else {
                                                        if let lastComponent = subComponents.last {
                                                            let car = Car(brand: brand, manufacture: manufacturersId, series:modelsId, model: lastComponent, year: year, displacement: displacement , gearbox:gearBox ,oilConsumption: String.init(result))
                                                            self.cars.append(car)
                                                        }
                                                    }
                                                }
                                                self.filteredCars = self.cars
                                                self.tableView.reloadData()
                                                printLog(text)
                                            }
                                        })
                                    }
//                                    if let dic = arr.first {
//                                        let compressId = dic["compressId"] as! String
//
//                                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/fuchs/getData", method: .post, parameters: ["compressId":compressId]).responseData(completionHandler: { (response) in
//                                            printLog(response.request?.url)
//                                            if let data = response.data {
////                                                printLog(String.init(data: data, encoding: .utf8))
//                                                self.xmlParser = XMLParser(data: data)
//                                                self.xmlParser?.shouldProcessNamespaces = true
//                                                self.xmlParser?.shouldReportNamespacePrefixes = true
//                                                self.xmlParser?.shouldResolveExternalEntities = true
//                                                self.xmlParser?.shouldGroupAccessibilityChildren = true
//                                                self.xmlParser?.delegate = self
//                                                self.xmlParser?.parse()
//                                            }else {
//                                                printLog(response.error?.localizedDescription as Any)
//                                            }
//                                        })
//                                    }
                                })
                            }
                        })
                    }
                })
            }
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: UITableViewDataSource
extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TableViewCell else {
            fatalError("Can not found a cell")
        }
        cell.car = filteredCars[indexPath.row]
        return cell
    }
    
    // MARK:- LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        printLog("\(dropDownLists[0].frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        printLog("\(dropDownLists[0].frame)")
        for (_,ddl) in dropDownLists.enumerated() {
            ddl.indicatiorPosition = CGPoint(x: ddl.frame.size.width - 8, y: ddl.frame.size.height/2)
            ddl.textPosition = CGPoint(x: ddl.frame.size.width/2, y: ddl.frame.size.height/2)
        }
    }
}

// MARK: DropDownDelegate
extension ViewController:HHDropDownListDelegate {
    func dropDownList(_ dropDownList: HHDropDownList!, didSelectItemName itemName: String!, at index: Int) {
        filterConditions[dropDownList.tag] = itemName
    }
}

// MARK: DropDownDataSource
extension ViewController:HHDropDownListDataSource {
    func listData(for dropDownList: HHDropDownList!) -> [String]! {
        switch dropDownList.tag {
        case 0:
            return manufactures
        case 1:
            return serieses
        case 2:
            return models
        case 3:
            return years
        case 4:
            return displacements
        case 5:
            return gearboxes
        default:
            return [String]()
        }
    }
}


// MARK: XMLParserDelegate
extension ViewController:XMLParserDelegate {
    // MARK:- Handling XML
    // document
    func parserDidStartDocument(_ parser: XMLParser) {
        printLog("parse start")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        printLog("parse end")
    }
    
    // element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        printLog("start parse element:\(elementName)")
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        printLog("end parse element:\(elementName)")
    }
    
    // mapping namespace prefix
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        printLog("start mapping prefix:\(prefix)")
    }
    
    func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
        printLog("end mapping prefix:\(prefix)")
    }
    
    // external entity
    func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
        printLog("resolve external entity:\(name)")
        return nil
    }
    
    // parseErrorOccourred
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        printLog("an parse error:\(parseError.localizedDescription) occurred")
    }
    
    // validationErrorOccourred
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        printLog("an validation error:\(validationError.localizedDescription) occurred")
    }
    
    // found characters of current element
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        printLog("found characters:\(string) of current element")
    }
    
    // found ignorableWhiteSpace of current element
    func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        printLog("found ignorableWhiteSpace:\(whitespaceString) of current element")
    }
    
    // found a comment in document
    func parser(_ parser: XMLParser, foundComment comment: String) {
        printLog("found a comment:\(comment) in document")
    }
    
    
    // found a CDATA block
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        printLog("found a CDATA block:\(CDATABlock)")
    }
    
    // MARK:- Handling the DTD
    // encounter a declaration of an attribute that is associated with a specific element.
    func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        printLog("encounter the declaration of  attribute:\(attributeName) that is associated with \(elementName)")
    }
    
    // encounters a declaration of an element with a given model.
    func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        printLog("encounter the declaration of  element:\(elementName)")
    }
    
    // encounters an internal entity declaration.
    func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
        printLog("encounters the declaration of  internal entity :\(name)")
    }
    
    // encounters an unparsed entity declaration.
    func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
        printLog("encounters the declaration of  unparsed internal entity :\(name)")
    }
    
    // encounters a notation declaration.
    func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
        printLog("encounters the declaration of notation:\(name)")
    }
}

extension String {
    func encode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

extension Array where Element == String {
    public mutating func uniqueAppend(_ newElement: String) {
        if self.contains(newElement) {
            return
        }else {
            self.append(newElement)
        }
    }
}

struct Car {
    var brand:String
    var manufacture:String
    var series:String
    var model:String
    var year:String
    var displacement:String?
    var gearbox : String?
    var oilConsumption:String?
    
}
