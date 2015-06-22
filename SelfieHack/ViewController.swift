//
//  ViewController.swift
//  SelfieHack
//
//
import UIKit
import AVFoundation

class ViewController: UIViewController,  AVCaptureMetadataOutputObjectsDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    var faceRectangleFrameView:UIView?
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    var buttonBeep = AVAudioPlayer()
    var secondBeep = AVAudioPlayer()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBAction func start(sender: AnyObject) {
        captureSession.startRunning()
    }
    
    @IBAction func stop(sender: AnyObject) {
        captureSession.stopRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        
        //2
        var error: NSError?
        
        //3
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        //4
        return audioPlayer!
    }

    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        
        //2
        var error: NSError?
        
        //3
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        //4
        return audioPlayer!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("CONSOLE WORKS")
        // Do any additional setup after loading the view, typically from a nib.
        buttonBeep = self.setupAudioPlayerWithFile("ButtonTap", type:"wav")
        secondBeep = self.setupAudioPlayerWithFile("SecondBeep", type:"wav")
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        //CONFIGURE THE RECTANGLE THAT APPEARS AROUND THE FACE
        faceRectangleFrameView = UIView()
        faceRectangleFrameView?.layer.borderColor = UIColor.greenColor().CGColor    //set the color of the rectangle
        faceRectangleFrameView?.layer.borderWidth = 2                               //set the width of the rectangle
        
        //ACCESSING THE DEVICES
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as? AVCaptureVideoPreviewLayer
                        previewLayer!.frame = self.view.bounds
                        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                        beginSession() //call begin session function
                    }//if
                }//if
            }//if
        }//for
    }//viewDidLoad
    
    func beginSession() {
        /*
        FUNCTION TO CONFIGURE THE CAMERA AND THE SCREEN
        */
        var output = AVCaptureStillImageOutput()
        var err : NSError? = nil                                                            //set the error
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))   //addInput along with error
        if err != nil {
            println("error: \(err?.localizedDescription)")                                  //if there's an error print the error
        }//if
        
        //CONFIGURE THE PREVIEW LAYER
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        
        self.view.addSubview(startButton)           //add startbutton to the view that displays the camera output
        self.view.addSubview(stopButton)            //add stopbutton to the view that displays the camera output
        
        view.addSubview(faceRectangleFrameView!)    //add the rectangle that appears around the face to the view that displays the camera output
        view.bringSubviewToFront(faceRectangleFrameView!)
        output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        captureSession.startRunning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            //set the bounds for the rectangle outline that appears around the face.
            faceRectangleFrameView?.frame = CGRectZero  //if there is no face, set bounds = 0
            return
        }//if
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataFaceObject
        
        if metadataObj.type == AVMetadataObjectTypeFace {
            // If the found metadata is equal to the FaceObject Data then update the frames and check for the different face parameters.
            /*
            //FEATURED TO BE ADDED IN THE FUTURE
            
            //SOME PROPERTIES THAT CAN BE OBTAINED FROM THE FACE OBJECT.
            var faceObject = metadataObj
            println("faceID: \(faceObject.faceID)")
            
            if(faceObject.hasRollAngle){
            println("roll angle: \(faceObject.rollAngle)")
            }//if
            else{
            println("no roll angle associated")
            }//else
            
            if(faceObject.hasYawAngle){
            println("yaw angle: \(faceObject.yawAngle)")
            }//if
            else{
            println("no yaw angle associated")
            }//else
            */
            
            /*
            get coordinates of the dimensions of the screen which
            gives the height and the width of the total screen.
            use these dimensions to calculate the position of the face
            with respect to screen
            */
            var bounds = UIScreen.mainScreen().bounds   //coordinates of the whole screen.
            var width = bounds.size.width               //width from coordinates of the whole screen.
            var height = bounds.size.height             //height from coordinates of the whole screen.
            
            println("screen dimensions--> Bounds: \(bounds), Height: \(height), Width: \(width)")
            
            //SOME EXAMPLE DATA. USE THIS TO CREATE THE ALGORITHM.
            //screen bounds: (0.0, 0.0, 414.0, 736.0)
            //screen width: 414.0
            //screen height: 736.0
            
            /*
            get coordinates of the position of the face on the screen
            and calculate the height and width from those coordinates
            */
            var faceBounds = metadataObj.bounds                 // coordinates of the position of the face
            var faceWidth = faceBounds.size.width      //width of the face position calculated with respect to screen width.
            var faceHeight = faceBounds.size.height   //height of the face position calculated with respect to screen height.
            
            println("face dimensions--> Bounds: \(faceBounds), Height: \(faceHeight * height), Width: \(faceWidth * width)")
            
            //set the bounds for the rectangle outline that appears around the face.
            faceRectangleFrameView?.frame = metadataObj.bounds  //the bounds are obtained from the face object
            
<<<<<<< HEAD
            //WRITE THE CODE FOR ALGORITHM THAT INDICATES THE POSITION OF THE FACE HERE.
            if(faceHeight * height > 400 && faceHeight * height < 500){
                println("height centered")
                
                if(faceWidth * width > 50 && faceWidth * width < 200){
                    println("width centered")
                    buttonBeep.play()

                    
                    //INCLUDE IMAGE CAPTURE HERE
                    
=======
                //WRITE THE CODE FOR ALGORITHM THAT INDICATES THE POSITION OF THE FACE HERE.
                if(faceHeight * height > 400 && faceHeight * height < 500){
                    println("height centered")
                    buttonBeep.play()
                    
                    if(faceWidth * width > 100 && faceWidth * width < 200){
                        println("width centered")
                        secondBeep.play()
                        
                        //INCLUDE IMAGE CAPTURE HERE
                        if let VideoConnection =
                            stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo){
                                stillImageOutput?.captureStillImageAsynchronouslyFromConnection(VideoConnection, completionHandler: {(sampleBuffer, error) in
                                })
                                
                        }
                        
                        
                    }//if
                    else{
                        println("width not centered")
                    }//else
>>>>>>> origin/master
                }//if
                else{
                    println("width not centered")
                    secondBeep.play()
                }//else
            }//if
            else{
                println("height not centered")
                secondBeep.play()
            }//else
            
            
        }//if
    }//captureOutput
}//ViewController




