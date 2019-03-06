//
//  ViewController.swift
//  Enablon Response
//
//  Created by Josh Kaplan on 2/15/19.
//  Copyright © 2019 Josh Kaplan. All rights reserved.
//

import UIKit
import Eureka
import MapKit
import CoreLocation

class ViewController: FormViewController, CLLocationManagerDelegate {
    
    
    let locationManager = CLLocationManager()
    

    
    override func viewDidLoad() {
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
    
        
        
        navigationItem.title = "Enablon Response"
        
        super.viewDidLoad()
        
        createAlertForm()
        
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let currentCoordinateLatitude = location.coordinate.latitude
            let currentCoordinateLongitude = location.coordinate.longitude
        }
    }

    
    func createAlertForm() {
        
        let responseOption1Default = "I'm Safe"
        let responseOption2Default = "I Need Assistance"
        
        guard let currentDeviceCoordinate = locationManager.location?.coordinate else { return }
        guard let currentLatt  = locationManager.location?.coordinate.latitude else { return }
        guard let currentLong = locationManager.location?.coordinate.longitude else { return }
        let currentLocationString = "CLLocation(latitude: \(currentLatt), longitude: \(currentLong))"
        print(currentLocationString)
        
        form +++ Section("Alert Info")
            
            <<< TextRow("AlertName") { row in
                row.title = "Alert Name"
                row.placeholder = "Alert Name"
        }
            <<< TextAreaRow("AlertMessage") { row in
                row.title = "Alert Message Body"
                row.placeholder = "Alert Message"
            }
        
            <<< ActionSheetRow<String>() {
                $0.title = "Severity"
                $0.tag = "Severity"
                $0.selectorTitle = "Select Severity"
                $0.options = ["1 - Low","2 - Medium","3 - High"]
//                $0.value = "Two"    // initially selected
        }
            <<< LocationRow("EventLocation"){
                $0.title = "Event GPS Location"
                $0.value = CLLocation(latitude: currentLatt, longitude: currentLong)
        }
        
        form +++ Section("Response Options")
//            <<< CheckRow("ResponseRequiredBool1") { row in
//                row.title = "Response Required?"
//        }
            <<< SwitchRow("ResponseRequiredBool") { row in
                row.title = "Response Required?"
            }
            <<< TextRow("Response1") { row in
                row.hidden = Condition.function(["ResponseRequiredBool"], { form in
                    return !((form.rowBy(tag: "ResponseRequiredBool") as? SwitchRow)?.value ?? false)
                })
                row.title = "Press 1 for"
                row.value = responseOption1Default
        }
        
            <<< TextRow("Response2") { row in
                row.hidden = Condition.function(["ResponseRequiredBool"], { form in
                    return !((form.rowBy(tag: "ResponseRequiredBool") as? SwitchRow)?.value ?? false)
                })
                row.title = "Press 2 for"
                row.value = responseOption2Default
        }
        
        form +++ Section("Select Message Recipients")
            <<< MultipleSelectorRow<String>() {
                $0.title = "Select Locations"
                $0.options = ["CHI - Silver Runs", "DEN - Whiteleaf","PAR - Bluesky", "PER - North Star"]
                $0.tag = "recipient"
            }
        
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Send Alert"
                }.onCellSelection({ (cell, row) in
                    let alertMessage: TextAreaRow! = self.form.rowBy(tag: "AlertMessage")
                    let messageValue = alertMessage!.value
                    
                    let nameRow: TextRow! = self.form.rowBy(tag: "AlertName")
                    let nameValue = nameRow!.value
                    
                    let locationGPSSelection: LocationRow! = self.form.rowBy(tag: "EventLocation")
                    guard let locationGPSLatValue  = locationGPSSelection!.value?.coordinate.latitude else { return }
                    guard let locationGPSLonValue  = locationGPSSelection!.value?.coordinate.longitude else { return }
                    let locationGPSCoordinates = "\(locationGPSLatValue),\(locationGPSLonValue)"
                    
                    let responseRow: SwitchRow! = self.form.rowBy(tag: "ResponseRequiredBool")
                    let responseSelection = responseRow!.value ?? false
                    
                    let responseOpt1Row: TextRow! = self.form.rowBy(tag: "Response1")
                    guard let responseOpt1 = responseOpt1Row!.value else { return }
                    
                    let responseOpt2Row: TextRow! = self.form.rowBy(tag: "Response2")
                    guard let responseOpt2 = responseOpt2Row!.value else { return }

                    
                    let locationSelection = self.form.rowBy(tag: "recipient").flatMap({ (row) -> String? in
                        if let row = row as? MultipleSelectorRow<String> {
                            return row.value?.joined(separator: ",")
                        }
                        return nil
                    })
                    
                    let selectedGPSLocationRow: LocationRow! = self.form.rowBy(tag: "EventLocation")
                    guard let selectedGPSLocation = selectedGPSLocationRow!.value else { return }
                    
                    guard let alertSeverity = self.form.rowBy(tag: "Severity")?.baseValue else { return }
                    
                    print(locationSelection ?? "Empty")

                    
                    /* Send Alert */
                    
                    let alert = UIAlertController(title: "Alert Sent", message: "Your alert named \(nameValue!) has been sent!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    /* End Send Alert */
                    
                    /* Clear Form */
                    
                    self.form.rowBy(tag: "AlertMessage")?.baseValue = ""
                    self.form.rowBy(tag: "AlertName")?.baseValue = ""
                    self.form.rowBy(tag: "ResponseRequiredBool")?.baseValue = nil
                    self.form.rowBy(tag: "recipient")?.baseValue = ""
                    self.form.rowBy(tag: "Severity")?.baseValue = ""
                    self.form.rowBy(tag: "Response1")?.baseValue = responseOption1Default
                    self.form.rowBy(tag: "Response2")?.baseValue = responseOption2Default
                    self.form.rowBy(tag: "EventLocation")?.baseValue = CLLocation(latitude: currentLatt, longitude: currentLong)
                    
                    
                    func postToZapier() {
                        /* Send Zapier Webhook Call */
                        
                        let alertParameters = ["alertMessageText": messageValue!, "alertName": nameValue!, "alertEventLocationGPS": "\(locationGPSCoordinates)", "alertRecipientLocation": locationSelection, "responseRequired": responseSelection, "severity": alertSeverity, "responseOpt1": responseOpt1, "responseOpt2": responseOpt2] as [String : Any]
                        
                        guard let devURL = URL(string: "https://hooks.zapier.com/hooks/catch/2853627/p5e7iz/") else { return }
                        
                        guard let prodURL = URL(string: "https://hooks.zapier.com/hooks/catch/2853627/p2moc4/") else { return }
                        
                        var request =  URLRequest(url: prodURL)
                        
                        request.httpMethod = "POST"
                        guard let httpBody = try? JSONSerialization.data(withJSONObject: alertParameters, options: []) else {
                            return }
                        request.httpBody = httpBody
                        
                        let session = URLSession.shared
                        session.dataTask(with: request) { (data, response, error) in
                            if let response = response {
                                print(response)
                            }
                            
                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    print(json)
                                } catch {
                                    print(error)
                                }
                            }
                            }.resume()
                        
                    }
                    
                postToZapier()

                })

        
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            print("Josh says \(location.coordinate)")
//        }
//    }
}


//MARK: LocationRow

public final class LocationRow: OptionsRow<PushSelectorCell<CLLocation>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = MapViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return MapViewController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let location = $0 else { return "" }
            let fmt = NumberFormatter()
            fmt.maximumFractionDigits = 4
            fmt.minimumFractionDigits = 4
            let latitude = fmt.string(from: NSNumber(value: location.coordinate.latitude))!
            let longitude = fmt.string(from: NSNumber(value: location.coordinate.longitude))!
            return  "\(latitude), \(longitude)"
        }
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}

public class MapViewController : UIViewController, TypedRowControllerType, MKMapViewDelegate {
    
    public var row: RowOf<CLLocation>!
    public var onDismissCallback: ((UIViewController) -> ())?
    
    lazy var mapView : MKMapView = { [unowned self] in
        let v = MKMapView(frame: self.view.bounds)
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
        }()
    
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = UIImage(named: "map_pin", in: Bundle(for: MapViewController.self), compatibleWith: nil)
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 10.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        return ellipse
        }()
    
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.fillRule = .nonZero
        layer.lineCap = .butt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = .miter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.gray.cgColor
        return layer
        }()
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        if let value = row.value {
            let region = MKCoordinateRegion(center: value.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            mapView.setRegion(region, animated: true)
        }
        else{
            mapView.showsUserLocation = true
        }
        updateTitle()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
    }
    
    
    @objc func tappedDone(_ sender: UIBarButtonItem){
        let target = mapView.convert(ellipsisLayer.position, toCoordinateFrom: mapView)
        row.value = CLLocation(latitude: target.latitude, longitude: target.longitude)
        onDismissCallback?(self)
    }
    
    func updateTitle(){
        let fmt = NumberFormatter()
        fmt.maximumFractionDigits = 4
        fmt.minimumFractionDigits = 4
        let latitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.latitude))!
        let longitude = fmt.string(from: NSNumber(value: mapView.centerCoordinate.longitude))!
        title = "\(latitude), \(longitude)"
    }
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
        })
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
        })
        updateTitle()
    }
}
