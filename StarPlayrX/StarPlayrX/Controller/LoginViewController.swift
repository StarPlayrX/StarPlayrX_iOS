//
//  LoginViewController.swift
//  StarPlayr
//
//  Created by Todd Bruss on 2/8/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import SafariServices
import AVKit



class LoginViewController: UIViewController {
    
    let g = Global.obj
    let p = Player.shared
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    
    @IBAction func tip_jar_paypal(_ sender: Any) {
        website(url: "https://www.paypal.com/paypalme/starplayrx")
    }
    
    @IBAction func starplayrx_dot_com(_ sender: Any) {
        website(url: "https://starplayrx.com")
    }
    
    @IBAction func Trial(_ sender: Any) {
        website(url: "https://care.siriusxm.com/sirpromoplanselection_view.action?programCode=ESSPS3MOFREE&intcmp=NPR_all_SXIRES-launch_tryfree_3for0_040819_ES")
    }
    
    func website(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var StatusField: UILabel!
    
   
    //login button action
    @IBAction func loginButton(_ sender: Any) {
        self.g.Username = self.userField.text ?? ""
        self.g.Password = self.passField.text ?? ""
        self.prog(0.0, "Start", animated: false)
        self.autoLogin()
    }
    
    @objc func pausePlayBack() {
        self.p.pause()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        p.magicTapped()
        return true
    }
    
    func displayError(title: String, message: String, action: String) {
        
        self.prog(0.0, "")
        self.loginButton.isEnabled = true
        self.loginButton.alpha = 1.0
        self.showAlert(title: title, message: message, action: action)
        
    }
    
    func autoLogin() {
        let net = Network.ability
        
        //MARK: 1 - Logging In
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.5
        self.view?.endEditing(true)
        
        var ping : String? = nil
        let pingUrl = "\(self.g.insecure)\(self.g.localhost):" + String(self.p.port) + "/ping"
        
        Async.api.Text(endpoint: pingUrl) { p in
            
            ping = p
            
            //Check if Local Web Server is Up
            if let pg = ping, pg != "pong" {
                //print("Launching the Server.")
                net.LaunchServer()
            }
            
            if !net.networkIsConnected {
                self.displayError(title: "Network error", message: "Check your internet connection and try again.", action: "OK")
            } else {
                self.prog(0.01, "Login")
                self.login()
            }
        }
    }
    
    //MARK: 1 - Login
    func login() {
        let endpoint = g.insecure + g.local + ":" + String(p.port)  + "/api/v2/autologin"
        let method = "login"
        let request = ["user":g.Username,"pass":g.Password] as Dictionary
        
        if g.Username == g.demoname {
            g.demomode = true
        } else {
            g.demomode = false
        }
        
        func failureMessage() {
            self.displayError(title: "Network error", message: "Check your internet connection and try again.", action: "OK")
        }
        
        Async.api.Post(request: request, endpoint: endpoint, method: method) { result in
            
            guard
                let result = result,
                let data = result.data?["data"] as? String,
                let message = result.data?["message"] as? String,
                let success = result.data?["success"] as? Bool
                else { return  }
            
            if success {
                
                //MARK: 2 - Logging In
                
                UserDefaults.standard.set(self.g.Username, forKey: "user")
                UserDefaults.standard.set(self.g.Password, forKey: "pass")
                self.g.userid = data
                UserDefaults.standard.set(self.g.userid, forKey: "userid")
                
                self.prog(0.2, "Session")
                self.session()
                
            } else {
                DispatchQueue.main.async {
                    self.loginButton.isEnabled = true
                    self.loginButton.alpha = 1.0
                    
                    if data == "411" {
                        
                        self.prog(0, "")
                        self.closeStarPlayr(title: "Local Network Error",
                                            message: message, action: "Close StarPlayrX")
                    } else {
                        self.displayError(title: "Login Error", message: message, action: "OK")
                    }
                }
            }
        }
    }
    
    
    //MARK 2 - Session
    func session() {
        let endpoint = g.insecure + Global.obj.local + ":" + String(p.port) + "/api/v2/session"
        let method = "cookies"
        let request = ["channelid":"siriushits1"] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method) { result in
            
            self.prog(0.3, "Channels")
            
            if let data = result?.data?["data"] as? String {
                self.channels(channelLineUpId:data)
            } else {
                self.channels(channelLineUpId:"350")
            }
        }
    }
    
    //MARK 3 - Channels
    func channels(channelLineUpId: String) {
        
        let endpoint = g.insecure + g.local + ":" + String(p.port) + "/api/v2/channels"
        let method = "channels"
        let request = ["channeltype" : "" ] as Dictionary
        
        Async.api.Post(request: request, endpoint: endpoint, method: method) { result in
            if let data = result?.data?["data"] as? [String : Any] {
                self.g.ChannelList = data
                
                self.prog(0.4, "Artwork")
                
                self.art(channelLineUpId: channelLineUpId)
            } else {
                self.displayError(title: "Error reading channels", message: "Possible network error.", action: "OK")
            }
        }
    }
    
    //MARK 4 - Artwork
    func art(channelLineUpId: String) {
        
        // self.embeddedAlbumArt(filename: "bluenumbers") //load by default
        
        //large channel art checksum
        let GetChecksum = UserDefaults.standard.string(forKey: "largeChecksumXD") ?? "0"
        
        //get large art checksum
        let checksumUrl = g.secure + g.domain + ":" + g.secureport + "/large/checksum"
        
        g.imagechecksum = ""
        
        Async.api.Text(endpoint: checksumUrl) { sum in
            
            self.prog(0.6, "Artwork")
            
            if let check = sum {
                self.g.imagechecksum = String(check)
            } else {
                self.g.imagechecksum = self.g.websitedown
            }
            
            runArt()
        }
        
        func runArt() {
            
            self.embeddedAlbumArt(filename: "demoart", process: false)
            
            func nextStep() {
                self.prog(0.6, "Processing")
                
                self.processing()
            }
            
            func runBlue(_ str: Int) {
                //print("BLUE: \(str)")
                self.embeddedAlbumArt(filename: "bluenumbers", process: true)
                UserDefaults.standard.removeObject(forKey: "channelDataXD")
                UserDefaults.standard.removeObject(forKey: "largeChecksumXD")
                //UserDefaults.standard.synchronize()
                
            }
            
            func runFailure(_ str: Int) {
                //print("FAILURE: \(str)")
                self.embeddedAlbumArt(filename: "demoart", process: true)
                UserDefaults.standard.removeObject(forKey: "channelDataXD")
                UserDefaults.standard.removeObject(forKey: "largeChecksumXD")
                //UserDefaults.standard.synchronize()
            }
            
            if g.demomode {
                runBlue(0)
            } else if g.imagechecksum == GetChecksum {
                do {
                    if let readData = UserDefaults.standard.data(forKey: "channelDataXD"),
                        let chData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(readData),
                        let cd = chData as? [String : Data], !cd.isEmpty {
                        
                        g.ChannelData = cd
                        nextStep()
                        
                    } else {
                        runFailure(1)
                    }
                    
                } catch {
                    runFailure(2)
                    print(error)
                }
            } else {
                
                let dataUrl = "\(g.secure)\(g.domain):\(g.secureport)/large"
                
                Async.api.CommanderData(endpoint: dataUrl, method: "large-art") { (data) in
                    guard let d = data,
                        let chData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(d),
                        let cdata = chData as? [String : Data],
                        !cdata.isEmpty
                        else { runFailure(3); return }
                    
                    self.g.ChannelData = cdata
                    
                    do {
                        let writeData = try NSKeyedArchiver.archivedData(withRootObject: self.g.ChannelData as Any, requiringSecureCoding: false)
                        UserDefaults.standard.set(writeData, forKey: "channelDataXD")
                        UserDefaults.standard.set(self.g.imagechecksum, forKey: "largeChecksumXD")
                        nextStep()
                    } catch {
                        runFailure(4)
                        print(error)
                    }
                }
            }
        }
    }
    
    
    
    func guide() {
        //MARK: Skip Check
        p.updatePDT() { success in
            if success {
                
                if let i = self.g.ChannelArray.firstIndex(where: {$0.channel == self.g.currentChannel}) {
                    let item = self.g.ChannelArray[i].largeChannelArtUrl
                    self.p.updateDisplay(key: self.g.currentChannel, cache: self.p.pdtCache, channelArt: item)
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .updateChannelsView, object: nil)
                }
                
                self.finish()
            } else {
                self.finish()
                //print("GUIDE ERROR.")
                //self.prog(0, "")
                //self.showAlert(title: "Error reading reading Guide",
                //message: "Posible network error.", action: "OK")
            }
        }
    }
    
    func prog(_ Float: Float, _ Text: String, animated: Bool = true) {
        DispatchQueue.main.async {
            runProg()
        }
        
        func runProg() {
            //MARK: Invoke using getFloat(Float)
            let getFloat = { (_ Float: Float) -> Float in
                if let bar = self.progressBar?.progress {
                    return Float < 1 && Float > 0 ? bar + 0.1 : Float
                } else {
                    return Float
                }
            }
            
            let value = getFloat(Float) //return value
            
            if Float == 1.0  {
                loginButton.isEnabled = true
                loginButton.alpha = 1.0
            }
            
            StatusField.text = Text
            progressBar?.setProgress( value, animated: animated)
        }
    }
    
    func finish() {
        self.prog(1.0, "Complete")
        
        DispatchQueue.main.async {
            runFinish()
        }
        
        func runFinish() {
            self.loginButton.isEnabled = true
            self.loginButton.alpha = 1.0
            self.tabItem(index: 1, enable: true, selectItem: true)
        }
    }
    
    
    func processing()  {
        func runFailure() {
            self.displayError(title: "Channel List Error", message: "Check your internet connection and try again.", action: "OK")
        }
        
        guard let channelList = g.ChannelList else { runFailure(); return }
        
        //g.ChannelList = nil
        
        g.ChannelArray = tableData()
        
        let sortedChannelList = Array(channelList.keys).sorted {$0.localizedStandardCompare($1) == .orderedAscending}
        let detail = NSMutableAttributedString(string: "\n" , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        let song = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]);
        detail.append(song)
        
        for ch in sortedChannelList {
            
            if let blueprint = channelList[ch] as? [String : Any],
                let number = blueprint["channelNumber"] as? String,
                var name = blueprint["name"] as? String,
                let mediumImage = blueprint["mediumImage"] as? String,
                let category = blueprint["category"] as? String,
                let preset = blueprint["preset"] as? Bool,
                let tinyImageData = UIImage(named: "xplaceholder") {
                
                //We do not allow SiriusXM in channel names, plus it's kind of redundant
                name = name.replacingOccurrences(of: "SiriusXM", with: "Sirius")
                name = name.replacingOccurrences(of: "SXM", with: "SPX")
                
                let title = NSMutableAttributedString(string: number + " ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
                let channel = NSMutableAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
                
                title.append(channel)
                
                let item = (searchString: number + name , name: name, channel: number, title: title, detail: detail, image: tinyImageData, channelImage: tinyImageData, albumUrl: "", largeAlbumUrl: "", largeChannelArtUrl: mediumImage, category: category, preset: preset )
                g.ChannelArray.append(item)
            } else {
                runFailure();
            }
        }
        
        
        //Read in the presets
        let x = (UserDefaults.standard.array(forKey: "SPXPresets") ?? ["2","3","4"]) as [String]
        
        p.SPXPresets = x
        if !p.SPXPresets.isEmpty && !g.ChannelArray.isEmpty {
            var c = -1
            for b in g.ChannelArray {
                c += 1
                
                for a in p.SPXPresets {
                    if a == b.channel {
                        g.ChannelArray[c].preset = true
                        break
                    }
                }
            }
        }
        
        self.prog(0.7, "Icons")
        self.processChannelIcons()
    }
    
    
    
    //Adds in Channel Art from Data Dictionary
    func processChannelIcons()  {
        // if !g.ChannelArray.isEmpty && !(g.ChannelData?.isEmpty ?? true) {
        for i in 0..<g.ChannelArray.count {
            let channel = g.ChannelArray[i].channel
            if let chArt = g.ChannelData?[channel], let img = UIImage(data: chArt) {
                g.ChannelArray[i].channelImage = img
                g.ChannelArray[i].image = img
            }
        }
        // }
        
        self.prog(0.8, "Guide")
        guide()
    }
    
    
    //Show Alert
    func showAlert(title: String, message:String, action:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { action in
            switch action.style{
                case .default:
                    print("")
                case .cancel:
                    print("")
                case .destructive:
                    print("")
                
                @unknown default:
                    print("error")
            }}))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func closeStarPlayr(title: String, message:String, action:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: { action in
            switch action.style{
                case .default:
                    exit(0)
                case .cancel:
                    print("")
                case .destructive:
                    print("")
                
                @unknown default:
                    print("error.")
            }}))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //set tab item
    func tabItem(index: Int, enable: Bool, selectItem: Bool) {
        let tabBarArray = self.tabBarController?.tabBar.items
        
        if let tabBarItems = tabBarArray, tabBarItems.count > 0 {
            let tabBarItem = tabBarItems[index]
            tabBarItem.isEnabled = enable
        }
        
        if selectItem {
            self.tabBarController?.selectedIndex = index
        }
    }
    
    func turnOffFullScreen() {
        func bitSet(_ bits: [Int]) -> UInt {
            return bits.reduce(0) { $0 | (1 << $1) }
        }
        
        func property(_ property: String, object: NSObject, set: [Int], clear: [Int]) {
            if let value = object.value(forKey: property) as? UInt {
                object.setValue((value & ~bitSet(clear)) | bitSet(set), forKey: property)
            }
        }
        
        // disable full-screen button
        if  let NSApplication = NSClassFromString("NSApplication") as? NSObject.Type,
            let sharedApplication = NSApplication.value(forKeyPath: "sharedApplication") as? NSObject,
            let windows = sharedApplication.value(forKeyPath: "windows") as? [NSObject] {
            for window in windows {
                property("styleMask", object: window, set: [], clear: [3])
                property("collectionBehavior", object: window, set: [9], clear: [7, 8])
            }
        }
        
    }


    override func viewDidAppear(_ animated: Bool) {
        turnOffFullScreen()
    }
    
    //view did load
    override func viewDidLoad() {
        super.viewDidLoad()

    
        
        self.tabItem(index: 1, enable: false, selectItem: false)
        self.g.Username = UserDefaults.standard.string(forKey: "user") ?? ""
        self.g.Password = UserDefaults.standard.string(forKey: "pass") ?? ""
        self.userField.text = self.g.Username
        self.passField.text = self.g.Password
        
        //gUserid = UserDefaults.standard.string(forKey: "userid") ?? ""
        
        if !self.g.Username.isEmpty && !self.g.Password.isEmpty {
            
            if UIAccessibility.isVoiceOverRunning {
                let utterance = AVSpeechUtterance(string: "Star Player X, Logging In")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                utterance.rate = 0.5
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
            
            self.prog(0.0, "Start", animated: false)
            self.autoLogin()
        }
        
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(self.pausePlayBack) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleFingerTapToPause)
        
        turnOffFullScreen()

    }
    
    func embeddedAlbumArt(filename: String, process: Bool = false) {
        if let art = Sync.io.readLocalDataFile(filename: filename) {
            
            do {
                if let d = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData( art ),
                    let dict = (d as? [String : Data]) /* converts Any to [String : Data] */ {
                    g.ChannelData = dict
                    
                    if process {
                        self.prog(0.6, "Processing")
                        self.processing()
                    }
                }
            } catch {
                //the next step will run even if this fails
                //MARK: To Do - Need to fix this
                print(error)
            }
        }
    }
}
