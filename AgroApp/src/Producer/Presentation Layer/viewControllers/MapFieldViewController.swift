//
//  MapFieldViewController.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-27.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import UIKit
import MapKit

class MapFieldViewController: UIViewController, MKMapViewDelegate {

    var mapFieldViewModel: MapFieldViewModel
    var mapFieldView: MapFieldView

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(mapFieldViewModel: MapFieldViewModel) {
        self.mapFieldViewModel = mapFieldViewModel
        self.mapFieldView = MapFieldView(mapFieldViewModel: self.mapFieldViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = self.mapFieldView
        self.mapFieldViewModel.mapFieldView = self.mapFieldView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapFieldView.mapView?.delegate = self
        self.mapFieldViewModel.subscribeToTableViewControllerState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapFieldViewModel.disposeToTableViewControllerState()
        self.mapFieldView.mapView?.showsUserLocation = false
        self.mapFieldView.mapView?.delegate = nil
        self.mapFieldView.mapView?.removeFromSuperview()
        self.mapFieldView.mapView = nil
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapFieldViewModel.registerAnnotationView()
        self.mapFieldViewModel.mapFieldInteraction.getAllFieldAction()
        self.mapFieldViewModel.initTitleNavigation(of: self)
        self.mapFieldViewModel.initRegion()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        self.mapFieldViewModel.handle(mkAnnotation: annotation)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.mapFieldViewModel.handle(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.mapFieldViewModel.handleAnnotationViewSelected(annotationView: view)
    }

    deinit {
        print("****** deint MapFieldViewController  *****")
    }
}
