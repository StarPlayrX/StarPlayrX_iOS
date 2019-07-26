//
//  LaunchServer.swift
//  StarPlayr
//
//  Created by Todd on 3/1/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import CameoKit
import PerfectHTTPServer
import PerfectHTTP
import AVKit

private let autoLoginQueue = DispatchQueue(label: "VoiceOverQueue", qos: .background)

func LaunchServer() {
    startup = true
    do {
        //Find the first Open port
        for i in port...64999 {
            let (isFree, _) = checkTcpPortForListen(port: UInt16(i))
            if isFree {
                port = UInt16(i)
                break;
            }
        }
        
        let server = HTTPServer.Server(name: localhost, address: local, port: Int(port), routes: routes() )
        try HTTPServer.launch(wait: false, server)
        startup = false

    } catch {
        print(error)
        startup = false
    }
}


