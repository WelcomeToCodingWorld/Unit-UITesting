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
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var firBrandTF: UITextField!
    
    
    let cellID = "TableViewCell"
    
    
    var cars = [Car]() {
        didSet {
            printLog("cars did set to:\(cars)")
            if cars.isEmpty {
                manufactures.removeAll()
                serieses.removeAll()
                models.removeAll()
                years.removeAll()
                displacements.removeAll()
                gearboxes.removeAll()
            }
        }
    }
    
    // for displacement
    var manufactures = [String]()
    var serieses = [String]()
    var models = [String]()
    var years = [String]()
    var displacements = [String]()
    var gearboxes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (idx,dropDownItm) in dropDownLists.enumerated() {
//            dropDownLists[idx] = HHDropDownList.init(frame: dropDownItm.frame)
//            dropDownItm.backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
//            dropDownItm.highlightColor = UIColor(red: 125/255.0, green: 238/255.0, blue: 161/255.0, alpha: 1.0)
//            dropDownItm.haveBorderLine = true
//            dropDownItm.isExclusive = true
//            dropDownItm.delegate = self
//            dropDownItm.dataSource = self
//            dropDownItm.tag = idx
        }
        setupTable()
        searchTest()
    }
    
    @IBAction func filt(_ sender: Any) {
    }
    
    @IBAction func search(_ sender: Any) {
        cars.removeAll()
        self.searchTest()
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
        search()
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func searchTest() {
        let brand = "日产"
        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/manufacturers/getManufacturers?brandId=\(brand.encode())").responseJSON { (response) in
            guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                return
            }
            if let dic = arr.first {
                let manufacturersId = dic["manufacturersId"] as! String
                
                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/model/getModels?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())").responseJSON(completionHandler: { (response) in
                    guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                        return
                    }
                    if let dic = arr.first {
                        let modelsId = dic["modelsId"] as! String
                        printLog(modelsId)
                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/salesName/getSalesNames?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())").responseJSON(completionHandler: { (response) in
                            guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                return
                            }
                            
                            if let dic = arr.first {
                                let salesName = dic["salesName"] as! String
                                printLog(salesName)
                                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/year/getYears?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())&salesName=\(salesName.encode())").responseJSON(completionHandler: { (response) in
                                    guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                        return
                                    }
                                    
                                    if let dic = arr.first {
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
                                                            self.manufactures.append(car.manufacture)
                                                            self.serieses.append(car.series)
                                                            self.models.append(car.model)
                                                            self.years.append(car.year)
                                                            if let dp = car.displacement {
                                                                self.displacements.append(dp)
                                                            }
                                                            if let gb = car.gearbox {
                                                                self.gearboxes.append(gb)
                                                            }
                                                            if !self.models.contains(lastComponent) {
                                                                self.models.append(lastComponent)
                                                            }
                                                        }
                                                    }
                                                }
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
    
    func search() {
        let brand = "日产"
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
                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/salesName/getSalesNames?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())").responseJSON(completionHandler: { (response) in
                            guard let dic = response.result.value as? [String: Any],let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                return
                            }
                            
                            for dic in arr {
                                let salesName = dic["salesName"] as! String
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
                                                printLog(text)
                                            }
                                        })
                                    }
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
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TableViewCell else {
            fatalError("Can not found a cell")
        }
        cell.car = cars[indexPath.row]
        return cell
    }
}

// MARK: DropDownDelegate
extension ViewController:HHDropDownListDelegate {
    
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
