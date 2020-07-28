//
//  Draw.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 5/3/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//

import UIKit
import AVKit

final class Draw {
    
    let g = Global.obj
    
    //MARK: Offset Values
    let iPhoneOffset = CGFloat(13) //kicks up some graphics
    let iPhoneXtraPx = CGFloat(18)
    let iPhoneNoXtra = CGFloat(0)
    let iPhoneMaxPro = CGFloat(896.0)
    let iPhoneXReg	 = CGFloat(812.0)
    let mainGray     = UIColor(displayP3Red: 35 / 255, green: 37 / 255, blue: 39 / 255, alpha: 1.0)
    let shadowColor	 = UIColor(displayP3Red: 35 / 2 / 255, green: 37 / 2 / 255, blue: 39 / 2 / 255, alpha: 1.0)
    let buttonOffset = CGFloat(30)
    let buttonSize 	 = CGFloat(30)
    let airplaySize  = CGFloat(52)
    
    let iPhoneHeight   : CGFloat
    let iPhoneWidth    : CGFloat
    var isIphoneX      : CGFloat
    let frameY         : CGFloat
    let iPhoneY        : CGFloat
    var sliderWidth    : CGFloat = 0
    var positionBottom : CGFloat = 0
    
    let isPhone		 : Bool
    
    //MARK: CUSTOMIZATIONS
    let labelOffset		: CGFloat
    let labelOffset2	: CGFloat
    let labelHeight		: CGFloat
    let fontSize		: CGFloat
    let playPauseY		: CGFloat
    let playPauseScale	: CGFloat
    
    //These Init Later based on PlayerView
    var AlbumArtSizeX	: CGFloat = 0
    var AlbumArtSizeY	: CGFloat = 0
    var centerX			: CGFloat = 0
    var centerY			: CGFloat = 0
    
    let iPadAlbumClearSpace: CGFloat
    let iPadTabHeightFactor: CGFloat
    
    //MARK: 1 - Draws PlayerView Rectangle
    func PlayerView(mainView: UIView) -> UIView  {
        
        var playerView = UIView()
        
        if self.isPhone {
            playerView = self.drawPlayerView(mainView: mainView, x: iPhoneWidth / 2, y: (frameY) / 2, width: iPhoneWidth, height: self.iPhoneY, isPhone: self.isPhone)
        } else {
            //Nav Bar width is from a previous view
            playerView = self.drawPlayerView(mainView: mainView, x: 0, y: 0, width: iPhoneWidth - g.navBarWidth, height: iPhoneHeight - g.tabBarHeight, isPhone: self.isPhone)
        }
        
        return playerView
    }
    
    
    //MARK: 2 - Draw Album Art Image View 
    func AlbumImageView(playerView: UIView) -> UIImageView {
        
        let albumArt = self.drawAlbumView(playerView: playerView, x: centerX, y: centerY, width: AlbumArtSizeX, height: AlbumArtSizeX, wire: false)
        albumArt.layer.shadowColor = shadowColor.cgColor
        albumArt.layer.shadowOpacity = 0
        albumArt.layer.shadowOffset = .zero
        albumArt.layer.shadowRadius = fontSize * 2
        albumArt.layer.shadowPath = UIBezierPath(rect: albumArt.bounds).cgPath
        albumArt.alpha = 1.0
        
        return albumArt
    }
    
    
    //MARK: 3 - Draw Artist Song Label for iPad
    func ArtistSongiPad(playerView: UIView) -> UILabel {
        let artistSong = self.drawLabels(playerView: playerView, x: centerX, y: labelOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold), wire: true)
        
        return artistSong
    }
    
    
    //MARK: 4 - Draw Artist and Song Labels for iPhone
    func ArtistSongiPhone(playerView: UIView ) -> [UILabel] {
        let artist = self.drawLabels(playerView: playerView, x: centerX, y: (AlbumArtSizeY - AlbumArtSizeX - labelOffset) / 2 - iPhoneOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .white, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.semibold), wire: true)
        
        let song = self.drawLabels(playerView: playerView, x: centerX, y: (AlbumArtSizeY - AlbumArtSizeX - labelOffset2) / 2 - iPhoneOffset, width: AlbumArtSizeX, height: labelHeight, align: .center, color: .systemGray, text: "", font: .systemFont(ofSize: fontSize, weight: UIFont.Weight.medium), wire: true)
        
        return [artist,song]
    }
    
    //MARK: 5 - Draw Volume Slider
    func VolumeSliders(playerView: UIView) -> UIView {
        let volumeSlider = self.drawVolumeSlider(playerView: playerView, centerX: centerX, centerY: positionBottom, rectX: 0, rectY: 0, width: sliderWidth, height: labelHeight)
		
        return volumeSlider
    }
    
    //MARK: 6 - Draw Player button
    func PlayerButton(playerView: UIView) -> UIButton {
        let player = self.drawButtons(playerView: playerView, centerX: centerX, centerY: positionBottom - playPauseY, rectX: 0, rectY: 0, width: buttonSize * playPauseScale, height: labelHeight, wire: false)
        return player
    }
    
    //MARK: 7 - Draw
    func SpeakerImage(playerView: UIView) -> UIImageView {
        let speakerView = self.drawImage(playerView: playerView, centerX: buttonOffset, centerY: positionBottom, rectX: 0, rectY: 0, width: buttonSize, height: buttonSize, wire: false)
        return speakerView
    }
    
    //MARK: 8 - Draw AirPlay Button
    func AirPlay(airplayView: UIView, playerView: UIView) -> (view: UIView, picker: AVRoutePickerView ) {
        
        let vp = self.drawAirPlay(airplayView: airplayView, playerView: playerView, centerX: playerView.frame.size.width - buttonOffset, centerY: positionBottom - (playPauseY / 1.5), rectX: 0, rectY: 0, width: airplaySize, height: airplaySize, wire: false)
    
        return vp
    }
    
    deinit { }
    
    
    init( frame: CGRect, isPhone: Bool, NavY: CGFloat, TabY: CGFloat) {
        
        self.isPhone = isPhone
        
        iPhoneHeight = frame.height
        iPhoneWidth  = frame.width
        
        //MARK: Here is we are checking if the user as an iPhone X (it has 18 more pixels in height / Status bar)
        
        let maxPro = iPhoneHeight == iPhoneMaxPro
        let iPhonX = iPhoneHeight == iPhoneXReg
        
        isIphoneX = (maxPro || iPhonX) ? iPhoneXtraPx : iPhoneNoXtra
        frameY = iPhoneHeight - isIphoneX
        self.iPhoneY = frameY - NavY - TabY
        
        //Drawing code constants
        switch iPhoneHeight {
            
            //MacCatalyst
            case 718...722.0 :
                labelOffset = 100
                labelOffset2 = 10
                labelHeight = 60
                fontSize = 16.5
                iPadAlbumClearSpace = 0
                iPadTabHeightFactor = 0
                playPauseY = 25
                playPauseScale = 2
            //iPad Pro 12.9"
            case 1024.0 :
                labelOffset = 45
                labelOffset2 = 140
                labelHeight = 60
                fontSize = 18
                iPadAlbumClearSpace = 200
                iPadTabHeightFactor = 1.9
                playPauseY = 60
                playPauseScale = 1.7
            //iPad 11"
            case 834.0 :
                labelOffset = 34
                labelOffset2 = 140
                labelHeight = 60
                fontSize = 16
                iPadAlbumClearSpace = 185
                iPadTabHeightFactor = 2.2
                playPauseY = 60
                playPauseScale = 1.7
            //iPad 9"
            case 810.0 :
                labelOffset = 0
                labelOffset2 = 140
                labelHeight = 30
                fontSize = 16
                iPadAlbumClearSpace = 150
                iPadTabHeightFactor = 1.7
                playPauseY = 60
                playPauseScale = 1.7
            
            //iPad 9"
            case 768.0 :
                labelOffset = 0
                labelOffset2 = 140
                labelHeight = 30
                fontSize = 16
                iPadAlbumClearSpace = 140
                iPadTabHeightFactor = 1.425
                playPauseY = 60
                playPauseScale = 1.7
            //Default is iPhone SE 2 / 7 / 8
            default :
                labelOffset = 100
                labelOffset2 = 10
                labelHeight = 60
                fontSize = 16.5
                iPadAlbumClearSpace = 0
                iPadTabHeightFactor = 0
                playPauseY = 70
                playPauseScale = 2
        }
    }
    
    
    //MARK: draw Player View
    func drawPlayerView(mainView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isPhone: Bool) -> UIView {
        let drawView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        drawView.backgroundColor = self.mainGray
        
        if isPhone {
            drawView.center = CGPoint(x: x, y: y)
        }
        
        mainView.addSubview(drawView)
        print(iPhoneHeight, isPhone)

        //MARK: Common constants - for iPhone and iPad
        switch (iPhoneHeight, isPhone) {
            //MARK: iPhone X and higher

            //MARK: MacCatalyst
            case (718.0...722.0,true) :
                AlbumArtSizeX = drawView.frame.size.width
                AlbumArtSizeY = drawView.frame.size.height
                centerX = drawView.frame.size.width / 2
                centerY = drawView.frame.size.height / 2 + 20
                positionBottom = CGFloat( drawView.frame.size.height - 25 )
            
            //MARK: iPad
            case (768.0,false), (810.0,false), (834.0,false), (1024.0,false) :
                AlbumArtSizeX = drawView.frame.size.width - (iPadAlbumClearSpace * 1.333)
                AlbumArtSizeY = drawView.frame.size.height - (iPadAlbumClearSpace * 1.333)
                centerX = drawView.frame.size.width / 2
                centerY = (drawView.frame.size.height - g.tabBarHeight) / 2
                positionBottom = CGFloat( drawView.frame.size.height - 30 )
            
            default:
                //defaults to Regular
                if isPhone {
                    AlbumArtSizeX = drawView.frame.size.width
                    AlbumArtSizeY = drawView.frame.size.height
                    centerX = drawView.frame.size.width / 2
                    centerY = drawView.frame.size.height / 2 + 20
                    positionBottom = CGFloat( drawView.frame.size.height - 25 )
                } else {
                    //iPad
                    AlbumArtSizeX = drawView.frame.size.width - (iPadAlbumClearSpace * 1.333)
                    AlbumArtSizeY = drawView.frame.size.height - (iPadAlbumClearSpace * 1.333)
                    centerX = drawView.frame.size.width / 2
                    centerY = (drawView.frame.size.height - g.tabBarHeight) / 2
                    positionBottom = CGFloat( drawView.frame.size.height - 30 )
            }
            
            
        }
        
        //common among all sizes
        sliderWidth = CGFloat( drawView.frame.size.width - 120 )
        
        return drawView
    }
    
    
    //MARK: draw Album Art View
    func drawAlbumView(playerView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> UIImageView {
        let drawView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        drawView.center = CGPoint(x: x, y: y)
        
        if wire {
            drawView.backgroundColor = .orange
        }
        
        playerView.addSubview(drawView)
        
        return drawView
    }
    
    
    //MARK: draw labels
    func drawLabels(playerView: UIView, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat,
                    align: NSTextAlignment, color: UIColor, text: String = "",
                    font: UIFont, wire: Bool) -> UILabel {
        
        let drawView = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        drawView.center = CGPoint(x: x, y: y)
        
        if wire {
            drawView.textColor = color
        }
        
        drawView.textAlignment = align
        
        drawView.text = text
        drawView.font = font
        drawView.numberOfLines = 2
        
        playerView.addSubview(drawView)
        
        return drawView
    }
    
    
    //MARK: Draw VolumeSlider
    func drawVolumeSlider(playerView: UIView, centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat) -> UIView {
        
        let slider = UIView(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        slider.center = CGPoint(x: centerX, y: centerY)
        
        //slider.minimumValue = 0
        //slider.maximumValue = 1
        //slider.isContinuous = true
        slider.tintColor = .systemBlue
        slider.backgroundColor = .red
        //slider.setThumbImage(UIImage(named: "knob"), for: .normal)
        //slider.setThumbImage(UIImage(named: "knob"), for: .highlighted)
        
        //mySlider.addTarget(self, action: #selector(ViewController.sliderValueDidChange(_:)), for: .valueChanged)
        
        playerView.addSubview(slider)
        return slider
    }
    
    
    //MARK: Draw Buttons
    func drawButtons(playerView: UIView, centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> UIButton {
        
        let button = UIButton(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        button.center = CGPoint(x: centerX, y: centerY)
        
        if wire { button.backgroundColor = .systemBlue }
        
        //mySlider.addTarget(self, action: #selector(ViewController.sliderValueDidChange(_:)), for: .valueChanged)
        
        playerView.addSubview(button)
        return button
    }
    
    func drawImage(playerView: UIView, centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> UIImageView {
        
        let image = UIImageView(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        image.center = CGPoint(x: centerX, y: centerY)
        
        if wire { image.backgroundColor = .systemBlue }
        
        let speakerImage = UIImage(named:Speakers.speaker1.rawValue)
        image.image = speakerImage
        
        playerView.addSubview(image)
        return image
    }
    
    
    //MARK: Draw Buttons
    func drawAirPlay(airplayView: UIView, playerView: UIView, centerX: CGFloat, centerY: CGFloat, rectX: CGFloat, rectY: CGFloat, width: CGFloat, height: CGFloat, wire: Bool) -> (view:UIView, picker: AVRoutePickerView)  {
        
        var airplayView = airplayView
        
        airplayView = UIView(frame:CGRect(x: rectX, y: rectY, width: width, height: height))
        airplayView.center = CGPoint(x: centerX, y: centerY)
        
        if wire { airplayView.backgroundColor = .systemPink }
        playerView.addSubview(airplayView)
        
        func setupAirPlayButton() -> AVRoutePickerView {
            let buttonFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            let airplayButton = AVRoutePickerView(frame: buttonFrame)
            
            airplayButton.prioritizesVideoDevices = false
            //airplayButton.delegate = self
            airplayButton.activeTintColor = UIColor.systemBlue
            airplayButton.tintColor = .systemBlue
            airplayView.addSubview(airplayButton)
            
            return airplayButton
        }
        
        let apButton = setupAirPlayButton()
        
        return (view:airplayView, picker: apButton)
    }
}
