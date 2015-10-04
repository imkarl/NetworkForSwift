//
//  AppDelegate.swift
//  NetworkForSwift
//
//  Created by King on 15/10/4.
//  Copyright © 2015 King. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var btnSubmit: NSButton!
    @IBOutlet weak var rbUnitTypeKb: NSButton!
    @IBOutlet weak var rbUnitTypeMb: NSButton!
    
    var statusItem: NSStatusItem!
    // 显示单位
    var mShowUnit = UnitType.KB
    // 显示文本颜色
    var mShowColor = 1

    enum UnitType {
        case MB
        case KB
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // 设置状态栏
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem.button?.font = NSFont.init(name: "TrebuchetMS", size: 10)
        statusItem.button?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        statusItem.button?.alignment = NSTextAlignment.Left
        //statusItem.button?.attributedTitle = NSAttributedString.init
        
        showStatusText(0, obytes: 0)
        
        // 执行异步线程，监听网络状态
        NSThread.detachNewThreadSelector("asynExec", toTarget: self, withObject: 1)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func toogleUnitTypeKb(sender: AnyObject) {
        rbUnitTypeMb.state = 0
    }
    @IBAction func toogleUnitTypeMb(sender: AnyObject) {
        rbUnitTypeKb.state = 0
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        if (rbUnitTypeKb.state == 1) {
            mShowUnit = UnitType.KB
        } else {
            mShowUnit = UnitType.MB
        }
        
    }
    
    /**
     * 异步执行内容
     */
    func asynExec() {
        while (true){
            // 获取网络流量情况
            let result = run("sar -n DEV 1 1").read()
            // 获取流量统计信息
            var networkInfo = getNetworkInfo(result)
            
            // 将流量信息展示到状态栏
            showStatusText(networkInfo[0], obytes: networkInfo[1])
        }
    }
    
    /**
     * 将流量信息展示到状态栏
     */
    func showStatusText(ibytes: Int, obytes: Int) {
        var message = "↑"
        
        switch mShowUnit {
            case UnitType.MB:
                message += String(obytes/1024/1024)
                message += " Mb/s\n↓"
                message += String(obytes/1024)
                message += " Mb/s"
            case UnitType.KB:
                message += String(ibytes/1024/1024)
                message += " Kb/s\n↓"
                message += String(ibytes/1024)
                message += " Kb/s"
        }
        
        statusItem.button?.title = message
        
        
    }
    
    /**
     * 获取流量统计信息
     * return [下载,上传]
     */
    func getNetworkInfo(data: String) -> [Int] {
        
        var lines = data.split("\n")
        var data = ""
        
        // 去除冗余信息
        for l in 1...lines.count{
            let line = lines[l-1]
            if (line.containsString("en0")) {
                
                let items = line.split(" ")
                for i in 1...items.count{
                    let item = items[i-1]
                    if (!item.isEmpty) {
                        
                        data += item+",";
                        
                    }
                }
                data += "\n";
                
            }
        }
        
        var ibytes = 0
        var obytes = 0
        // 获取到上传下载的流量
        lines = data.split("\n")
        for l in 1...lines.count{
            let line = lines[l-1]
            
            let items = line.split(",")
            for i in 1...items.count{
                let item = items[i-1]
                if (i == 4) {
                    ibytes += Int(item)!
                } else if (i == 6) {
                    obytes += Int(item)!
                }
            }
        }
        
        return [ibytes, obytes]
        
    }

}

