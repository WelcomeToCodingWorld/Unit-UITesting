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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        textView.delegate = self
//        textField.delegate = self
//        textField.text = "日产"
//        textField.returnKeyType = .search
//        textView.keyboardDismissMode = .onDrag
        search()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        search()
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func search() {
        let brand = "日产"
        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/manufacturers/getManufacturers?brandId=\(brand.encode())").responseJSON { (response) in
            guard let dic = response.result.value as? [String: Any] else {
                return
            }
            guard let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                return
            }
            for dic in arr {
                let manufacturersId = dic["manufacturersId"] as! String
                
                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/model/getModels?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())").responseJSON(completionHandler: { (response) in
                    guard let dic = response.result.value as? [String: Any] else {
                        return
                    }
                    guard let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                        return
                    }
                    for dic in arr {
                        let modelsId = dic["modelsId"] as! String
                       
                        Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/salesName/getSalesNames?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())").responseJSON(completionHandler: { (response) in
                            guard let dic = response.result.value as? [String: Any] else {
                                return
                            }
                            guard let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
                                return
                            }
                            for dic in arr {
                                let salesName = dic["salesName"] as! String
                                
                                Alamofire.request("http://oilchooser.fuchs.com.cn:90/fuchs/level/year/getYears?brandId=\(brand.encode())&manufacturersId=\(manufacturersId.encode())&modelId=\(modelsId.encode())&salesName=\(salesName.encode())").responseJSON(completionHandler: { (response) in
                                    guard let dic = response.result.value as? [String: Any] else {
                                        return
                                    }
                                    guard let arr = dic["value"] as? Array<Dictionary<String,Any>> else {
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
                                                print(text)
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

extension String {
    func encode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}


