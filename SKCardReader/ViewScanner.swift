//
//  ViewScanner.swift
//  CardScanner
//
//  Created by Syed Kashan on 09/09/2021.
//

import AVFoundation
import Foundation
import Vision
import UIKit

public protocol CardScannerDelegate: class {
    func extractedCardDetails(ccNumber: String, ccName: String, ccExpiry: String, ccCVV: String)
}

public class CardScannerView: UIView {
    
    // draws a rectangle layer over view
    var rectsArray: [CGRect]?
    
    // variables holding instances of
    private let device = AVCaptureDevice.default(for: .video)
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    
    
    var labelCardNumber: UILabel?
    var labelCardDate: UILabel?
    var labelCardHolderName: UILabel?
    var labelCardCVV: UILabel?
    var buttonComplete: UIButton?
    var buttonRescan: UIButton?
    
    public var labelChangeCardPosition: UILabel?
    
    private var cardNumber: String?
    private var cardDate: String?
    private var cardHolderName: String?
    private var cardCVV: String?
    
    public weak var delegate: CardScannerDelegate?
    
    // function to set camera and other layers
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        let width = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = width - (width * 0.45)
        let viewX = ((UIScreen.main.bounds.width * 0.2) / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2)
        
        let labelCardNumberX = viewX + 20
        let labelCardNumberY = viewY + height - 50
        
        labelCardNumber = UILabel(frame: CGRect(x: labelCardNumberX, y: labelCardNumberY, width: 100, height: 30))
        self.addSubview(labelCardNumber!)
        labelCardNumber?.translatesAutoresizingMaskIntoConstraints = false
        labelCardNumber?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: labelCardNumberX).isActive = true
        labelCardNumber?.topAnchor.constraint(equalTo: self.topAnchor, constant: labelCardNumberY).isActive = true
        labelCardNumber?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardNumber?.textColor = .white
        
        let labelCardDateX = viewX + 20
        let labelCardDateY = viewY + height - 90
        
        labelCardDate = UILabel(frame: CGRect(x: labelCardDateX, y: labelCardDateY, width: 100, height: 30))
        self.addSubview(labelCardDate!)
        labelCardDate?.translatesAutoresizingMaskIntoConstraints = false
        labelCardDate?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: labelCardDateX).isActive = true
        labelCardDate?.topAnchor.constraint(equalTo: self.topAnchor, constant: labelCardDateY).isActive = true
        labelCardDate?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardDate?.textColor = .white
        
        let labelCardCVVX = viewX + 140
        let labelCardCVVY = viewY + height - 90
        
        labelCardCVV = UILabel(frame: CGRect(x: labelCardCVVX, y: labelCardCVVY, width: 100, height: 30))
        self.addSubview(labelCardCVV!)
        labelCardCVV?.translatesAutoresizingMaskIntoConstraints = false
        labelCardCVV?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: labelCardCVVX).isActive = true
        labelCardCVV?.topAnchor.constraint(equalTo: self.topAnchor, constant: labelCardCVVY).isActive = true
        labelCardCVV?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardCVV?.textColor = .white
        
        let labelCardHolderNameX = viewX + 20
        let labelCardHolderNameY = viewY + height - 130
        
        labelCardHolderName = UILabel(frame: CGRect(x: labelCardHolderNameX, y: labelCardHolderNameY, width: 100, height: 30))
        self.addSubview(labelCardHolderName!)
        labelCardHolderName?.translatesAutoresizingMaskIntoConstraints = false
        labelCardHolderName?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: labelCardHolderNameX).isActive = true
        labelCardHolderName?.topAnchor.constraint(equalTo: self.topAnchor, constant: labelCardHolderNameY).isActive = true
        labelCardHolderName?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelCardHolderName?.textColor = .white
        
        
        let labelChangeCardPositionX = viewX + 40
        let labelChangeCardPositionY = viewY - 50
        
        labelChangeCardPosition = UILabel(frame: CGRect(x: labelChangeCardPositionX, y: labelChangeCardPositionY, width: 150, height: 30))
        self.addSubview(labelChangeCardPosition!)
        labelChangeCardPosition?.translatesAutoresizingMaskIntoConstraints = false
        labelChangeCardPosition?.numberOfLines = 0
        labelChangeCardPosition?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: labelChangeCardPositionX).isActive = true
        labelChangeCardPosition?.topAnchor.constraint(equalTo: self.topAnchor, constant: labelChangeCardPositionY).isActive = true
        labelChangeCardPosition?.textAlignment = .center
        labelChangeCardPosition?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        labelChangeCardPosition?.textColor = .white
        labelChangeCardPosition?.sizeToFit()
        
        let buttonCompleteX = viewX
        let buttonCompleteY = viewY + height + 30
        buttonComplete = UIButton(frame: CGRect(x: buttonCompleteX, y: buttonCompleteY, width: 100, height: 50))
        self.addSubview(buttonComplete!)
        buttonComplete?.translatesAutoresizingMaskIntoConstraints = false
        buttonComplete?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: viewX * 5.1).isActive = true
        buttonComplete?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: viewX * -1).isActive = true
        buttonComplete?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -90).isActive = true
        buttonComplete?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonComplete?.setTitle("Confirm", for: .normal)
        buttonComplete?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.6)
        buttonComplete?.layer.cornerRadius = 10
        buttonComplete?.layer.masksToBounds = true
        buttonComplete?.isHidden = true
        buttonComplete?.addTarget(self, action: #selector(scanCompleted), for: .touchUpInside)
        
        let buttonRescanX = viewX
        let buttonRescanY = viewY + height + 30
        buttonRescan = UIButton(frame: CGRect(x: buttonRescanX, y: buttonRescanY, width: 100, height: 50))
        self.addSubview(buttonRescan!)
        buttonRescan?.translatesAutoresizingMaskIntoConstraints = false
        buttonRescan?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: viewX).isActive = true
        buttonRescan?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: viewX * -5.1).isActive = true
        buttonRescan?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -90).isActive = true
        buttonRescan?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonRescan?.setTitle("Rescan", for: .normal)
        buttonRescan?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.6)
        buttonRescan?.layer.cornerRadius = 10
        buttonRescan?.layer.masksToBounds = true
        buttonRescan?.isHidden = true
        buttonRescan?.addTarget(self, action: #selector(reScan), for: .touchUpInside)
        
        self.rectsArray = [CGRect(x: viewX, y: viewY, width: width, height: height)]
        
        setCaptureCameraViews()
        startCapturing()
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.bounds
    }
    
    // adds a camera layer to view assigned
    private func addPreviewLayer() {
        self.backgroundColor = .clear
        self.layer.insertSublayer(previewLayer, at: 0)
    }
    // configuration for setting camera input
    private func addCameraInput() {
        guard let device = device else { return }
        guard let cameraInput = try? AVCaptureDeviceInput(device: device) else {return}
        captureSession.addInput(cameraInput)
    }
    // configuration for setting an image output
    private func addVideoOutput() {
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }
    // create view to place card inside
    private func makeCardHolderView() {
        guard let rectsArray = rectsArray else {
            return
        }
        for holeRect in rectsArray {
            let path = UIBezierPath(roundedRect: holeRect, cornerRadius: 10)
            
            UIColor.clear.setFill()
            UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.copy)
            
            let layer = CAShapeLayer()
            layer.masksToBounds = false
            layer.path = path.cgPath
            layer.strokeColor = UIColor.white.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 2
            self.layer.addSublayer(layer)
            
            path.fill()
        }
    }
    
    @objc func scanCompleted() {
        guard let number = cardNumber,
              let name = cardHolderName,
              let expiry = cardDate,
              let cvv = cardCVV else {return}
        self.delegate?.extractedCardDetails(ccNumber: number, ccName: name, ccExpiry: expiry, ccCVV: cvv)
    }
    @objc func reScan() {
        DispatchQueue.main.async {
            self.labelCardNumber?.text = ""
            self.labelCardDate?.text = ""
            self.labelCardHolderName?.text = ""
            self.labelCardCVV?.text = ""
            self.cardNumber = ""
            self.cardCVV = ""
            self.cardDate = ""
            self.cardHolderName = ""
            self.buttonRescan?.isHidden = true
            self.buttonComplete?.isHidden = true
            self.captureSession.startRunning()
        }
    }
    
    func setCaptureCameraViews() {
        addCameraInput()
        addPreviewLayer()
        addVideoOutput()
        makeCardHolderView()
    }
    func startCapturing() {
        self.captureSession.startRunning()
    }
    
    // MARK: - Data extraction from card detected image
    
    private func handleObservedPaymentCard(in frame: CVImageBuffer) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.extractPaymentCardData(frame: frame)
        }
    }
    private func extractPaymentCardData(frame: CVImageBuffer) {
        let ciImage = CIImage(cvImageBuffer: frame)
        let width = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = width - (width * 0.45)
        let viewX = ((UIScreen.main.bounds.width * 0.2) / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2)
        
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        
        // Desired output size
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
        
        // Apply resizing
        resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        
        guard let outputImage = resizeFilter.outputImage else {return}
        
        let croppedImage = outputImage.cropped(to: CGRect(x: viewX, y: viewY, width: width, height: height))
        
        if #available(iOS 13.0, *) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            
            let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
            try? stillImageRequestHandler.perform([request])
            
            guard let texts = request.results as? [VNRecognizedTextObservation], texts.count > 0 else {
                // no text detected
                return
            }
            let arrayLines = texts.flatMap({ $0.topCandidates(20).map({ $0.string }) })
            
            for line in arrayLines {
                print("Trying to parse: \(line)")
                
                let trimmed = line.replacingOccurrences(of: " ", with: "")
                
                if trimmed.count == 16 &&
                    trimmed.isOnlyNumbers {
                    print("Card Number: \(line)")
                    DispatchQueue.main.async {
                        self.labelCardNumber?.text = line
                        self.cardNumber = line
                    }
                    continue
                }
                
                if trimmed.count == 3 &&
                    trimmed.isOnlyNumbers {
                    print("CVV Number: \(line)")
                    DispatchQueue.main.async {
                        self.labelCardCVV?.text = line
                        self.cardCVV = line
                    }
                    continue
                }
                
                if trimmed.count >= 5 && // 12/20
                    trimmed.count <= 7 && // 12/2020
                    trimmed.isDate {
                    print("Expiry Date: \(line)")
                    DispatchQueue.main.async {
                        self.labelCardDate?.text = line
                        self.cardDate = line
                    }
                    continue
                }

                if trimmed.count > 8 &&
                    line.contains(" ") &&
                    trimmed.isOnlyAlphabets {
                    print("Card Holder Name: \(line)")
                    DispatchQueue.main.async {
                        self.labelCardHolderName?.text = line
                        self.cardHolderName = line
                    }
                    continue
                }
            }
            DispatchQueue.main.async {
                if self.cardHolderName != nil && self.cardDate != nil && self.cardNumber != nil && self.cardCVV == nil {
                    self.labelChangeCardPosition?.text = "Please change card position"
                } else if self.cardCVV != nil && self.cardHolderName == nil && self.cardDate == nil && self.cardNumber == nil {
                    self.labelChangeCardPosition?.text = "Please change card position"
                } else {
                    self.labelChangeCardPosition?.text = ""
                }
                if self.cardHolderName != nil && self.cardDate != nil && self.cardNumber != nil && self.cardCVV != nil {
                    self.captureSession.stopRunning()
                    self.buttonRescan?.isHidden = false
                    self.buttonComplete?.isHidden = false
                }
            }
        }
    }
}

extension CardScannerView: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        handleObservedPaymentCard(in: frame)
    }
}

//
private extension String {
    var isOnlyAlphabets: Bool {
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    var isOnlyNumbers: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    // Date Pattern MM/YY or MM/YYYY
    var isDate: Bool {
        let arrayDate = components(separatedBy: "/")
        if arrayDate.count == 2 {
            let currentYear = Calendar.current.component(.year, from: Date())
            if let month = Int(arrayDate[0]), let year = Int(arrayDate[1]) {
                if month > 12 || month < 1 {
                    return false
                }
                if year < (currentYear - 2000 + 20) && year >= (currentYear - 2000) { // Between current year and 20 years ahead
                    return true
                }
                if year >= currentYear && year < (currentYear + 20) { // Between current year and 20 years ahead
                    return true
                }
            }
        }
        return false
    }
}
