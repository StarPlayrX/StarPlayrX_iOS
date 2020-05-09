//
//  Extensions.swift
//  StarPlayr
//
//  Created by Todd on 3/2/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import CameoKit

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(cgImage!, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}


extension String {
    var isReady: Bool {
        //Can't run this at startup
        let pingUrl = "http://localhost:" + String(Player.shared.port) + "/ping"
        return TextSync(endpoint: pingUrl, method: "ping") == "pong" ? true : false
    }
}


//Some extra variables, so we can check the status of our AVPlayer
extension AVQueuePlayer {
    
    var isTwin: Bool {
        let g = Global.obj
        return g.lastchannel == g.currentChannel
    }
    
    var isDead: Bool {
        return rate == 0 || currentItem == .none || error != nil
    }
    
    var isBusy: Bool {
        return rate == 1 && currentItem != .none && error == nil
    }
}


extension Notification.Name {
    static let didUpdatePlay = Notification.Name("didUpdatePlay")
    static let didUpdatePause = Notification.Name("didUpdatePause")
    static let updateChannelsView = Notification.Name("updateChannelsView")
    static let gotNowPlayingInfo = Notification.Name("gotNowPlayingInfo")
    static let gotNowPlayingInfoAnimated = Notification.Name("gotNowPlayingInfoAnimated")
    static let gotSessionInterruption = AVAudioSession.interruptionNotification
    static let gotRouteChangeNotification = AVAudioSession.routeChangeNotification
    static let gotVolumeDidChange = NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    static let willEnterForegroundNotification = UIApplication.willEnterForegroundNotification
}


extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
