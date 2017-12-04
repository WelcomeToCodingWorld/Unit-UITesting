//
//  Util.swift
//  FileManagerDemo
//
//  Created by zz on 25/10/2017.
//  Copyright © 2017 zzkj. All rights reserved.
//

import Foundation
import UIKit
func printLog<T>(_ message:T,file:String = #file,method:String = #function,line:Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)],\(method):\(message)")
    #endif
}


func local(_ closure:()->()) {
    closure()
}

typealias Task = (_ cancel:Bool) -> Void

@discardableResult
func delay(_ time:TimeInterval,task:@escaping ()->()) -> Task? {
    var closure:(()->Void)? = task
    var result : Task?
    
    let t = DispatchTime.now() + time
    
    func dispatch_later(block:@escaping ()->()){
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    
    let delayedClosure:Task = {
        cancel in
        if let internalClosure = closure {
            if cancel == false {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        //task unfinished
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}

func cancel(_ task:Task?)  {
    task?(true)
}

// System app call
