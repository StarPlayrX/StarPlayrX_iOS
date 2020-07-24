
//
//  Player.swift
//  StarPlayrX
//
//  Created by Todd on 2/9/19.
//  Copyright © 2019 Todd Bruss. All rights reserved.
//

import UIKit
import AVKit

//UIGestureRecognizerDelegate
class PlayerViewController: UIViewController, AVRoutePickerViewDelegate  {
    
    let g = Global.obj
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }
    override var prefersHomeIndicatorAutoHidden : Bool { return true }
    
    @IBOutlet weak var mainView: UIView!
    
    //UI Variables
    weak var PlayerView   : UIView!
    weak var AlbumArt     : UIImageView!
    weak var Artist       : UILabel?
    weak var Song         : UILabel?
    weak var ArtistSong   : UILabel?
    weak var VolumeSlider : UISlider!
    weak var PlayerXL     : UIButton!
    weak var SpeakerView  : UIImageView!
    
    var playerViewTimerX = Timer()
    var AirPlayView      = UIView()
    var AirPlayBtn       = AVRoutePickerView()
    var allStarButton    = UIButton(type: UIButton.ButtonType.custom)
    
    var currentSpeaker = Speakers.speaker0
    var previousSpeaker = Speakers.speaker3
    
    //other variables
    let rounder = Float(10000.0)
    var sliderIsMoving = false
    var channelString = "Channels"
    
    //Art Queue
    public let ArtQueue = DispatchQueue(label: "ArtQueue", qos: .background )
    
    func Pulsar() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 2
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.25
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        self.AirPlayView.layer.add(pulseAnimation, forKey: nil)
    }
    
    
    func noPulsar() {
        self.AirPlayView.layer.removeAllAnimations()
    }
    
    func PulsarAnimation(tune: Bool = false) {
        if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
            Pulsar()
            
            if tune {
                Player.shared.change()
            }
            
        } else {
            noPulsar()
            
            if tune {
                Player.shared.change()
            }
        }
    }
    
    
    func startVolumeTimer() {
        invalidateTimer()
        self.playerViewTimerX = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(systemVolumeUpdater), userInfo: nil, repeats: true)
    }
    
    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        systemVolumeUpdater()
        startVolumeTimer()
        PulsarAnimation(tune: true)
    }
    
    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        invalidateTimer()
        systemVolumeUpdater()
        PulsarAnimation(tune: true)
    }
    
    
    func checkForAllStar() {
        let data = g.ChannelArray
        
        for c in data {
            if c.channel == g.currentChannel {
                
                if c.preset {
                    allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
                } else {
                    allStarButton.setImage(UIImage(named: "star_off"), for: .normal)
                }
                break
            }
        }
    }
    
    override func loadView() {
        super.loadView()
 		
        var isPhone = true
        var NavY = CGFloat(0)
        var TabY = CGFloat(0)
        
        //MARK: Draws out main Player View object : visible "Safe Area" only - calculated
        if let navY = self.navigationController?.navigationBar.frame.size.height,
            let tabY = self.tabBarController?.tabBar.frame.size.height {
            
            NavY = navY
            TabY = tabY
            isPhone = true
            
        } else if let tabY = self.tabBarController?.tabBar.frame.size.height {
            
            NavY = 0
            TabY = tabY
            isPhone = false
        }
        	
        drawPlayer(frame: mainView.frame, isPhone: isPhone, NavY: NavY, TabY: TabY)
    }
    
    func drawPlayer(frame: CGRect, isPhone: Bool, NavY: CGFloat, TabY: CGFloat) {
        //Instantiate draw class
         let draw = Draw(frame: frame, isPhone: isPhone, NavY: NavY, TabY: TabY)
            

        //MARK: 1 - PlayerView must run 1st
    	PlayerView = draw.PlayerView(mainView: mainView)
        
        if let pv = PlayerView {
            AlbumArt = draw.AlbumImageView(playerView: pv)
            
            //print("isPhone", isPhone)
            if isPhone {
                let artistSongLabelArray = draw.ArtistSongiPhone(playerView: pv)
                Artist = artistSongLabelArray[0]
                Song   = artistSongLabelArray[1]
            } else {
                ArtistSong = draw.ArtistSongiPad(playerView: pv)
            }
            
            VolumeSlider = draw.VolumeSliders(playerView: pv)
            addSliderAction()
            
            PlayerXL = draw.PlayerButton(playerView: pv)
            PlayerXL.addTarget(self, action: #selector(PlayPause), for: .touchUpInside)
            
            SpeakerView = draw.SpeakerImage(playerView: pv)
            updatePlayPauseIcon(play: true)
            setAllStarButton()
            
            //#if !targetEnvironment(simulator)
            	let vp = draw.AirPlay(airplayView: AirPlayView, playerView: pv)
            
            	AirPlayBtn = vp.picker
            	AirPlayView = vp.view
            //#endif
        }
    }
    
    func startupVolume() {
        
        func runsimulation() {
            let value = Player.shared.player.volume
            VolumeSlider.setValue(value, animated: true)
            self.setSpeakers(value: value)
        }
        runsimulation()

    }
    
    func shutdownVolume() {
            
    }
    
    @objc func OnDidUpdatePlay(){
        DispatchQueue.main.async {
            self.updatePlayPauseIcon(play: true)
        }
    }
    
    
    @objc func OnDidUpdatePause(){
        DispatchQueue.main.async {
            self.updatePlayPauseIcon(play: false)
        }
    }
    
    //MARK: Start Observers
    func setVolumeObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(gotVolumeDidChange), name: .gotVolumeDidChange, object: nil)
    }
    
    func removeVolumeObserver() {
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePlay), name: .didUpdatePlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidUpdatePause), name: .didUpdatePause, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfoAnimated), name: .gotNowPlayingInfoAnimated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GotNowPlayingInfo), name: .gotNowPlayingInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotVolumeDidChange), name: .gotVolumeDidChange, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .didUpdatePlay, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didUpdatePause, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotNowPlayingInfoAnimated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotNowPlayingInfo, object: nil)
        NotificationCenter.default.removeObserver(self, name: .willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .gotVolumeDidChange, object: nil)
    }
    //MARK: End Observers
    
    
    //MARK: Update Play Pause Icon
    func updatePlayPauseIcon(play: Bool? = nil) {
        
        switch play {
            case .none :
                
                Player.shared.state == PlayerState.playing ?
                    self.PlayerXL.setImage(UIImage(named: "pause_button"), for: .normal) :
                    self.PlayerXL.setImage(UIImage(named: "play_button"), for:  .normal)
            
            case .some(true) :
                
                self.PlayerXL.setImage(UIImage(named: "pause_button"), for: .normal)
            
            case .some(false) :
                self.PlayerXL.setImage(UIImage(named: "play_button"), for: .normal)
        }
    }
    
    func setAllStarButton() {
        allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
        allStarButton.accessibilityLabel = "All Stars Preset"
        allStarButton.addTarget(self, action:#selector(AllStarX), for: .touchUpInside)
        allStarButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        let barButton = UIBarButtonItem(customView: allStarButton)
        
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
    
    @objc func AllStarX() {
        let sp = Player.shared
        sp.SPXPresets = [String]()
        
        var index = -1
        for d in g.ChannelArray {
            index = index + 1
            if d.channel == g.currentChannel {
                g.ChannelArray[index].preset = !g.ChannelArray[index].preset
                
                if g.ChannelArray[index].preset {
                    allStarButton.setImage(UIImage(named: "star_on"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset On, \(g.currentChannelName)"
                    
                } else {
                    allStarButton.setImage(UIImage(named: "star_off"), for: .normal)
                    allStarButton.accessibilityLabel = "All Stars Preset Off, \(g.currentChannelName)"
                    
                }
            }
            
            if g.ChannelArray[index].preset {
                sp.SPXPresets.append(d.channel)
            }
        }
        
        if !sp.SPXPresets.isEmpty {
            UserDefaults.standard.set(sp.SPXPresets, forKey: "SPXPresets")
        }
    }
    
    //MARK: Magic tap for the rest of us
    @objc func doubleTapped() {
        PlayPause()
    }
    
    func doubleTap() {
        //Pause Gesture
        let doubleFingerTapToPause = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped) )
        doubleFingerTapToPause.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleFingerTapToPause)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
        doubleTap()
        AirPlayBtn.delegate = self
        
        #if targetEnvironment(simulator)
        	let value = Player.shared.player.volume
        	VolumeSlider.setValue(value, animated: true)
        	self.setSpeakers(value: value)
        #endif
    }
    
    @objc func GotNowPlayingInfoAnimated() {
        GotNowPlayingInfo(true)
    }
    
    @objc func GotNowPlayingInfo(_ animated: Bool = true) {
        let pdt = g.NowPlaying
        
        func accessibility() {
            Artist?.accessibilityLabel = pdt.artist + ". " + pdt.song + "."
            ArtistSong?.accessibilityLabel = pdt.artist + ". " + pdt.song + "."
            Artist?.isHighlighted = true
            AlbumArt.accessibilityLabel = "Album Art, " + pdt.artist + ". " + pdt.song + "."
        }
        
        func staticArtistSong() -> Array<(lbl: UILabel?, str: String)> {
            let combo  = pdt.artist + " • " + pdt.song + " — " + g.currentChannelName
            let artist = pdt.artist
            let song   = pdt.song
            
            let combine = [
                
                ( lbl: self.Artist,     str: artist ),
                ( lbl: self.Song,       str: song ),
                ( lbl: self.ArtistSong, str: combo ),
            ]
            
            return combine
        }
        
        
        accessibility()
        let labels = staticArtistSong()
        
        self.AlbumArt.layer.shadowOpacity = 1.0
        
        func presentArtistSongAlbumArt(_ artist: UILabel, duration: Double) {
            DispatchQueue.main.async {
                UIView.transition(with: self.AlbumArt,
                                  duration:duration,
                                  options: .transitionCrossDissolve,
                                  animations: { _ = [self.AlbumArt.image = pdt.image, self.AlbumArt.layer.shadowOpacity = 1.0] },
                                  completion: nil)
                
                for i in labels {
                    UILabel.transition(with: i.lbl ?? artist,
                                       duration: duration,
                                       options: .transitionCrossDissolve,
                                       animations: { i.lbl?.text = i.str},
                                       completion: nil)
                }
            }
        }
        
        func setGraphics(_ duration: Double) {
            
            if duration == 0 {
                self.AlbumArt.image = pdt.image
                self.AlbumArt.layer.shadowOpacity = 1.0
                
                for i in labels {
                   i.lbl?.text = i.str
                }
                
            } else {
                DispatchQueue.main.async {
                    //iPad
                    if let artistSong = self.ArtistSong {
                		presentArtistSongAlbumArt(artistSong, duration: duration)
                    //iPhone
                    } else if let artist = self.Artist {
                        presentArtistSongAlbumArt(artist, duration: duration)
                    }
                }
            }
       
        }
        
        if animated {
            setGraphics(0.5)
        } else if let _ = Artist?.text?.isEmpty {
            setGraphics(0.0)
        } else {
            setGraphics(0.25)
        }
    }
    
    @objc func PlayPause() {
        if Player.shared.player.isBusy && Player.shared.state == PlayerState.playing {
            updatePlayPauseIcon(play: false)
            Player.shared.state = .paused
            Player.shared.pause()
        } else {
            updatePlayPauseIcon(play: true)
            Player.shared.state = .stream
            
            DispatchQueue.global().async {
                Player.shared.player.pause()
                Player.shared.playX()
            }
        }
    }
    
    func invalidateTimer() {
        self.playerViewTimerX.invalidate()
    }
    
    
    func startup() {
        startupVolume()
        PulsarAnimation(tune: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _  = Artist?.text?.isEmpty {
            Player.shared.syncArt()
        }
    
        title = g.currentChannelName
        startup()
        checkForAllStar()
        isSliderEnabled()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        shutdownVolume()
        
        UIView.transition(with: self.AlbumArt,
                          duration:0.4,
                          options: .transitionCrossDissolve,
                          animations: { _ = [self.AlbumArt.layer.shadowOpacity = 0.0] },
                          completion: nil)
        
    }
    
    deinit {
        removeObservers()
    }
    
    //MARK: Speaker Volume with Smooth Frame Animation
    func setSpeakers(value: Float) {
        self.previousSpeaker = self.currentSpeaker
        switch (value) {
            case 0 :
                self.currentSpeaker = .speaker0
            case 0..<0.1 :
                self.currentSpeaker = .speaker1
            case 0.1..<0.2 :
                self.currentSpeaker = .speaker2
            case 0.2..<0.3 :
                self.currentSpeaker = .speaker3
            case 0.3..<0.4 :
                self.currentSpeaker = .speaker4
            case 0.4..<0.5 :
                self.currentSpeaker = .speaker5
            case 0.5..<0.6 :
                self.currentSpeaker = .speaker6
            case 0.6..<0.7 :
                self.currentSpeaker = .speaker7
            case 0.7..<0.8 :
                self.currentSpeaker = .speaker8
            case 0.8..<0.9 :
                self.currentSpeaker = .speaker9
            case 0.9...1.0 :
                self.currentSpeaker = .speaker10
            
            default :
                self.currentSpeaker = .speaker0
        }
        
        if self.previousSpeaker != self.currentSpeaker || value == 0.0 {
            let speakerName = self.currentSpeaker.rawValue
            
            UIView.transition(with: self.SpeakerView,
                              duration:0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.SpeakerView.image = UIImage(named: speakerName) },
                              completion: nil)
        
            self.previousSpeaker = self.currentSpeaker
        }
    }
    
    
    //MARK: Adjust the volume
    @objc func VolumeChanged(slider: UISlider, event: UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                    removeVolumeObserver()
                
                case .moved:
                    DispatchQueue.main.async {
                        let value = slider.value
                        self.setSpeakers(value: value)

                        Player.shared.player.volume = value

                	}
                case .ended:
                    setVolumeObserver()
                default:
                    return
            }
        }
    }
    
    
    //MARK: Add Volume Slider Action
    func addSliderAction() {
        VolumeSlider.addTarget(self, action: #selector(VolumeChanged(slider:event:)), for: .valueChanged)
    }
    
    
    //MARK: Remove Volume Slider Action
    func removeSlider() {
        VolumeSlider.removeTarget(nil, action: #selector(VolumeChanged(slider:event:)), for: .valueChanged)
    }
    
    
    @objc func gotVolumeDidChange(_ notification: NSNotification) {
        if sliderIsMoving { return }
        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                
            
            }
            
            
            #if !targetEnvironment(simulator)
            if !g.demomode {
                let slider = VolumeSlider.value
                
                let roundedSlider = round(rounder * slider) / rounder
                let roundedVolume = round(rounder * volume) / rounder
                
                if roundedSlider != roundedVolume {
                    
                    DispatchQueue.main.async {
                        self.VolumeSlider.setValue(volume, animated: true)
                    }
                }
            }
            #endif
            
         
            
        } else {
            //This creates a one time loop back if volume comes back nil
            #if !targetEnvironment(simulator)
            if !g.demomode {
                systemVolumeUpdater()
            }
            #endif
        }
    }
    
    
    @objc func systemVolumeUpdater() {
        switch UIApplication.shared.applicationState {
            
            case .active:
                airplayRunner()
            case .background:
                airplayRunner()
            default:
                ()
        }
    }
    
    
    func isSliderEnabled() {
        if Player.shared.avSession.currentRoute.outputs.first?.portType == .usbAudio  {
            VolumeSlider.isEnabled = false
        } else {
            VolumeSlider.isEnabled = true
        }
        
        #if !targetEnvironment(simulator)
        if g.demomode {
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay  {
                VolumeSlider.isEnabled = false
            } else {
                VolumeSlider.isEnabled = true
            }
        }
        #endif
    }
    
    
    func airplayRunner() {
        if tabBarController?.tabBar.selectedItem?.title == channelString && title == g.currentChannelName {
            if Player.shared.avSession.currentRoute.outputs.first?.portType == .airPlay {
                
            } else {
               
            }
            
            isSliderEnabled()
        }
    }
    
    
    override func accessibilityPerformMagicTap() -> Bool {
        PlayPause()
        return true
    }
    
    
    @objc func willEnterForeground() {
        startup()
    }
    
}

