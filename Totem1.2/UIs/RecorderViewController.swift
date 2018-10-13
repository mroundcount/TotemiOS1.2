//
//  RecorderViewController.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/16/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit
import AVFoundation


class RecorderViewController: UIViewController, AVAudioRecorderDelegate {
    
    private let recorderRule = recorderCharLimit()
    
    @IBOutlet weak var feedBtn: UIBarButtonItem!
    @IBOutlet weak var recordNavBtn: UIBarButtonItem!
    @IBOutlet weak var profileBtn: UIBarButtonItem!
    
    
    @IBAction func feedBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "recorderToFeed", sender: nil)
    }
    @IBAction func profileBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "recorderToProfile", sender: nil)
    }
    
    @IBOutlet weak var recordingImage: UIImageView!
    

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var finishedBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var descriptionTxt: UITextField!

    
 
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var defaultTxt: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTxt.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        publishBtn.isHidden = true
        pauseBtn.isHidden = true
        finishedBtn.isHidden = true
        descriptionTxt.isHidden = true
        publishBtn.isHidden = true

        defaultTxt.text = "Click anywhere and start talking"
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        recordNavBtn.isEnabled = false
        
        //asking the user for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
    }
    
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        print(textView.text); //the textView parameter is the textView where text was changed
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if recorderRule.validation(description: descriptionTxt.text) == true {
            defaultTxt.text = " Hey pal shorten the text a bit, that space costs money you know.... "
        } else {
            defaultTxt.text = " "
        }
    }
    
    
    
    
    @IBAction func recordBtn(_ sender: UIButton) {

        if audioRecorder == nil{
            
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")

            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

            //Start Audio Recodring
            do {
                //pass in the URL and the settings defined above
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                publishBtn.isHidden = true
                pauseBtn.isHidden = false
                finishedBtn.isHidden = false
                recordBtn.isHidden = true
                defaultTxt.isHidden = true
                publishBtn.isHidden = true
                
                //rerecord settings
                pauseBtn.setTitle("Pause", for: .normal)
                finishedBtn.setTitle("Finished", for: .normal)
                recordingImage.isHidden = false
                
                recordingImage.loadGif(name: "recording")
                
                start()

            }
            catch {
                displayALert(title: "Oh my.....", message: "Recording Failed")
            }
        }
    }
    
    

    @IBAction func pauseBtn(_ sender: UIButton) {
    if (finishedBtn.titleLabel?.text == "Finished") {
            if (pauseBtn.titleLabel?.text == "Pause") {
                //When recording is paused
                recordingImage.isHidden = true
                
                let blueColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255/255.0, alpha: 1.0)
                view.backgroundColor = blueColor
                
                audioRecorder.pause()
                
                pauseBtn.setTitle("Resume", for: .normal)
            } else {
                //When recording is active
                pauseBtn.setTitle("Pause", for: .normal)
                recordingImage.loadGif(name: "recording")
                recordingImage.isHidden = false
                
                audioRecorder.record()
            }
        } else {
            if (pauseBtn.titleLabel?.text == "Pause") {
                audioPlayer.pause()
                pauseBtn.setTitle("Resume", for: .normal)
            } else {
                pauseBtn.setTitle("Pause", for: .normal)
                audioPlayer.play()
                
            }
        }
    }
    
    

    @IBAction func finishedBtn(_ sender: UIButton) {
        finishedAction ()
    }
    
    func finishedAction () {
    if (finishedBtn.titleLabel?.text == "Finished") {
            //When clicked
            pauseBtn.setTitle("Pause", for: .normal)
        
            publishBtn.isHidden = false
            recordingImage.isHidden = true
            descriptionTxt.isHidden = false
            publishBtn.isHidden = false
            defaultTxt.isHidden = false
            defaultTxt.text = "Play it back, hey if ya fucked up click anywhere to record again"
            
            //view.backgroundColor = UIColor.darkGray
            let greenColor = UIColor(red: 10/255.0, green: 156/255.0, blue: 54/255.0, alpha: 1.0)
            view.backgroundColor = greenColor
            
            recordBtn.isHidden = false
            
            //stop the audio recording
            audioRecorder.stop()
            audioRecorder = nil
        
            pauseBtn.isHidden = true
        
            finishedBtn.setTitle("Playback", for: .normal)
        
            // This is just a test to upload to s3
            let dataURL = getDirectory().appendingPathComponent("myrecorder.m4a")
            let s3Transfer = S3TransferUtility()
            do {
                let audioData = try Data(contentsOf: dataURL as URL)
                s3Transfer.uploadData(data: audioData)
            } catch {
                print("Unable to load data: \(error)")
            }
        }
        if (finishedBtn.titleLabel?.text == "Playback") {
            pauseBtn.isHidden = false
            let filename = getDirectory().appendingPathComponent("myrecorder.m4a")
            do{
                //initialize the audio player
                audioPlayer = try AVAudioPlayer(contentsOf: filename)
                audioPlayer.play()
            }
            catch{
                displayALert(title: "Oh no.....", message: "Playback Failed")
            }
        }
            
    }
    
    @IBAction func publishBtn(_ sender: UIButton) {
        
        print("playing back")
        let s3Transfer = S3TransferUtility()
    }

    //Recording functions
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    //Function that get's path to direcotry
    func getDirectory() -> URL{
        //Searching for all the URLS in the documents directory and taking the first one and returning the URL to the document directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //defining our constant.
        //We will use the first URL path
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function that displays an alert
    func displayALert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    

    
    
    
    //Timers

    //Timer variables
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var status: Bool = false
    
    //Timer functions
    func start() {
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        // Set Start/Stop button to true
        status = true
    }
    
    func stop() {
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        // Set Start/Stop button to false
        status = false
    }
    
    @objc func updateCounter() {
        // Calculate total time since timer started in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        // Calculate minutes
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        // Calculate seconds
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        
        // Calculate milliseconds
        let milliseconds = UInt8(time * 100)
        
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMilliseconds = String(format: "%02d", milliseconds)
        
        timerLbl.text = "\(strMinutes):\(strSeconds):\(strMilliseconds)"
        
        func eventTimer() {
            if seconds == 4 {
                finishedAction ()
                stop()
            }
        }
        //why must you have this?
        return(eventTimer())
        
        // Add time vars to relevant labels
        /*
        labelMinute.text = strMinutes
        labelSecond.text = strSeconds
        labelMillisecond.text = strMilliseconds
         */
    }
}
