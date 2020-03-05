//
//  MapFieldViewModel.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-27.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import RxSwift
import MapKit

class MapFieldViewModel {
    let mapFieldAllFieldState$: Observable<MapFieldState>
    let mapFieldInteraction: MapFieldInteraction
    var disposableMapFieldAllState: Disposable?
    var mapView: MKMapView!
    var fieldsPolygonsAnnotations: [(Field<Polygon>, MKPolygon, AnnotationWithData<PayloadFieldAnnotation>)?]?
    var fieldsMuliPolygonsAnnotations: [(Field<MultiPolygon>, [(MKPolygon, AnnotationWithData<PayloadFieldAnnotation>)?])]?
    
    let idClusterAnnotation = "idCLusterAnnotation"
    let idAnnotationView = "My annotation view"
    var currentSelectedAnnotation: AnnotationWithData<PayloadFieldAnnotation>?
    let disposeBag = DisposeBag()
    
    init(
        mapFieldAllFieldState$: Observable<MapFieldState>,
        mapFieldInteraction: MapFieldInteraction
    ) {
        self.mapFieldAllFieldState$ = mapFieldAllFieldState$
        self.mapFieldInteraction = mapFieldInteraction
    }
    
    func initRegion() {
        let location2D = CLLocationCoordinate2DMake(45.233023116000027, -73.355880542999955)
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        let region = MKCoordinateRegion(center: location2D, span: coordinateSpan)
        self.mapView.region = mapView.regionThatFits(region)
    }
    
    func handleAnnotation(mkAnnotation: MKAnnotation) -> MKAnnotationView? {
        if mkAnnotation is AnnotationWithData<PayloadFieldAnnotation> {
            let markerAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: self.idAnnotationView, for: mkAnnotation) as! MKMarkerAnnotationView
            configMarkerAnnotationView(markerAnnotationView: markerAnnotation)
            configRightCalloutAccessoryView(mkAnnotation: mkAnnotation, markerAnnotationView: markerAnnotation)
            return markerAnnotation
        }
        
        
        if mkAnnotation is MKClusterAnnotation {
            
        }
        
        return nil
    }
    
    func handleOverlay(overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? PolygonWithData<PayloadFieldAnnotation> {
            let polygonRenderer = MKPolygonRenderer(polygon: overlay)
            
            if overlay.data!.isSelected {
                configPolygonRendererSelected(polygonRenderer: polygonRenderer)
                return polygonRenderer
            }
            
            
            configPolygonRendererNotSelected(polygonRenderer: polygonRenderer)
            return polygonRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func registerAnnotationView() {
        self.mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: self.idAnnotationView)
    }
    
    func dispatchGetAllFields() {
        mapFieldInteraction.getAllField()
    }
    
    func initTitleNavigation(viewController: UIViewController) {
        viewController.navigationItem.title = "Carte"
    }
    
    func configTabBarItem(viewController: UIViewController) {
        let barIttem = UITabBarItem(title: "Carte", image: nil, tag: 25)
        barIttem.title = "Carte"
       // viewController.title = "Carte"
        viewController.tabBarItem = barIttem
    }
    
    func subscribeToTableViewControllerState() {
        self.disposableMapFieldAllState = self.mapFieldAllFieldState$.subscribe(onNext:{ state  in
            self.proccessInitMap(fieldPolygonAnnotation: state.fieldPolygonAnnotation, fieldMultiPolygonAnnotation: state.fieldMultiPolygonAnnotation)
        })
    }
    
    func disposeToTableViewControllerState() {
        self.disposableMapFieldAllState?.dispose()
    }
    
    public func handleAnnotationViewSelected(annotationView: MKAnnotationView) {
        if let selectedFieldRightCalloutView = (annotationView as? MKMarkerAnnotationView)?.rightCalloutAccessoryView as? SelectedFieldCalloutView,
            let annotationWithData = annotationView.annotation as? AnnotationWithData<PayloadFieldAnnotation>,
            let dataFromAnnotationView = annotationWithData.data {
            self.currentSelectedAnnotation = annotationWithData
            selectedFieldRightCalloutView.setStateButton(isSelected: dataFromAnnotationView.isSelected)
        }
    }
    
    private func proccessInitMap(
        fieldPolygonAnnotation: [(Field<Polygon>, MKPolygon, AnnotationWithData<PayloadFieldAnnotation>)?],
        fieldMultiPolygonAnnotation: [(Field<MultiPolygon>, [(MKPolygon, AnnotationWithData<PayloadFieldAnnotation>)?])]
    ) {
        self.fieldsPolygonsAnnotations = fieldPolygonAnnotation
        self.fieldsMuliPolygonsAnnotations = fieldMultiPolygonAnnotation
        
        fieldPolygonAnnotation.forEach { fieldPolygonAnnotationTuple in
            addAnnotation(in: self.mapView, mkPointAnnotation: fieldPolygonAnnotationTuple?.2)
            addOverlay(in: self.mapView, mkPolygon: fieldPolygonAnnotationTuple?.1)
        }
        
        fieldMultiPolygonAnnotation.forEach { fieldMultiPolygonAnnotationTuple in
            fieldMultiPolygonAnnotationTuple.1.forEach { tuplePolygonAnnotation in
                self.addAnnotation(in: self.mapView, mkPointAnnotation: tuplePolygonAnnotation?.1)
                self.addOverlay(in: self.mapView, mkPolygon: tuplePolygonAnnotation?.0)
            }
        }
    }
    
    private func addAnnotation(in mapView: MKMapView, mkPointAnnotation: AnnotationWithData<PayloadFieldAnnotation>?) {
        mkPointAnnotation.map {mapView.addAnnotation($0)}
    }
    
    private func addOverlay(in mapView: MKMapView, mkPolygon: MKPolygon?) {
        mkPolygon.map { mapView.addOverlay($0) }
    }
    
    private func configMarkerAnnotationView(markerAnnotationView: MKMarkerAnnotationView) {
        markerAnnotationView.titleVisibility = .adaptive
        markerAnnotationView.subtitleVisibility = .adaptive
        markerAnnotationView.markerTintColor = .black
        markerAnnotationView.clusteringIdentifier = self.idClusterAnnotation
        markerAnnotationView.displayPriority = .defaultHigh
        markerAnnotationView.canShowCallout = true
    }
    
    private func configRightCalloutAccessoryView(mkAnnotation: MKAnnotation, markerAnnotationView: MKMarkerAnnotationView) {
        guard let annotationWithData = mkAnnotation as? AnnotationWithData<PayloadFieldAnnotation> else { return }
        guard let dataFromAnnotation = annotationWithData.data else { return }
        
        if markerAnnotationView.rightCalloutAccessoryView == nil {
            let rightCalloutAccessoryView = SelectedFieldCalloutView()
            rightCalloutAccessoryView.addTargetHandleForButtonAdd(handleButtonAdd(buttonAdd:))
            rightCalloutAccessoryView.addTargetHandleForButtonCancel(handleButtonCancel(buttonCancel:))
            rightCalloutAccessoryView.setStateButton(isSelected: dataFromAnnotation.isSelected)
            return markerAnnotationView.rightCalloutAccessoryView = rightCalloutAccessoryView
        }
        
        if let rightCalloutAccessoryView = markerAnnotationView.rightCalloutAccessoryView as? SelectedFieldCalloutView {
            return rightCalloutAccessoryView.setStateButton(isSelected: dataFromAnnotation.isSelected)
        }
    }
    
    
    private func handleButtonAdd(buttonAdd: UIButton) {
        guard let dataFromAnnotation = currentSelectedAnnotation?.data else { return }
        guard let selectedFieldCalloutView = buttonAdd.superview as? SelectedFieldCalloutView else { return }
        
        dataFromAnnotation.isSelected = true
        selectedFieldCalloutView.setStateButton(isSelected: true)
        findFieldById(idField: dataFromAnnotation.idField)
            .do(onNext: { self.addFieldToListFieldView(tuple: $0, mapFieldInteraction: self.mapFieldInteraction) })
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe {
                if let polygonRenderer = $0.element?.3 as? MKPolygonRenderer {
                    self.configPolygonRendererSelected(polygonRenderer: polygonRenderer)
                }
        }.disposed(by: self.disposeBag)
    }
    
    private func configPolygonRendererSelected(polygonRenderer: MKPolygonRenderer) {
        polygonRenderer.fillColor = UIColor.green.withAlphaComponent(0.3)
        polygonRenderer.strokeColor = UIColor.yellow.withAlphaComponent(0.8)
        polygonRenderer.lineWidth = 2
    }
    
    private func configPolygonRendererNotSelected(polygonRenderer: MKPolygonRenderer) {
        polygonRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
        polygonRenderer.strokeColor = UIColor.yellow.withAlphaComponent(0.8)
        polygonRenderer.lineWidth = 2
    }
    
    private func handleButtonCancel(buttonCancel: UIButton) {
        guard let dataFromAnnotation = currentSelectedAnnotation?.data else { return }
        guard let selectedFieldCalloutView = buttonCancel.superview as? SelectedFieldCalloutView else { return }
        dataFromAnnotation.isSelected = false
        selectedFieldCalloutView.setStateButton(isSelected: false)
        
        findFieldById(idField: dataFromAnnotation.idField)
            .do(onNext: { self.removeFieldToListFieldView(tuple: $0, mapFieldInteraction: self.mapFieldInteraction) })
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe {
                if let polygonRenderer = $0.element?.3 as? MKPolygonRenderer {
                    self.configPolygonRendererNotSelected(polygonRenderer: polygonRenderer)
                }
        }.disposed(by: self.disposeBag)
        //TODO: dispatch to remove tableView
    }
    
    private func findFieldById(idField: Int) ->Observable<(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon, MKOverlayRenderer)> {
        if fieldsPolygonsAnnotations != nil {
            return Observable
                .from(fieldsPolygonsAnnotations!)
                .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
                .filter { self.filterSelectedById(idField: idField, field: $0?.0)}
                .flatMap { self.flapMapTupleFieldPolygonAnnotation(tuple: $0, idField: idField) }
                .reduce([]) { self.reduceTupleFieldPolygonAnnotation(tupleArray: $0, tuple: $1) }
                .flatMap { self.getOverlayRendererByPolygon(tuple: $0)}
                
                
        }
        
        return Observable.error(NSError(domain: "not found field with id \(idField)", code: 1))
    }
    
    private func filterSelectedById(idField: Int, field: Field<Polygon>?) -> Bool {
        if field != nil {
            return field!.id == idField
        }
        
        return false
    }
    
    private func flapMapTupleFieldPolygonAnnotation(tuple: (Field<Polygon>, MKPolygon, AnnotationWithData<PayloadFieldAnnotation>)?, idField: Int) -> Observable<(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon)> {
        if let field = tuple?.0, let annotationWithData = tuple?.2, let mkPolygon = tuple?.1 {
            return Observable.just((FieldType.polygon(field), annotationWithData, mkPolygon))
        }
        
        return Observable.error(NSError(domain: "not found field with id \(idField)", code: 1))
    }
    
    private func reduceTupleFieldPolygonAnnotation(tupleArray: [(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon)],tuple: (FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon)) ->  [(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon)] {
        var array = tupleArray
        array.append(tuple)
        return array
    }
    
    private func getOverlayRendererByPolygon(tuple: [(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon)]) -> Observable<(FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon, MKOverlayRenderer)> {
        if let over =  self.mapView.renderer(for: tuple[0].2 ) {
            return Observable.just( (tuple[0].0, tuple[0].1, tuple[0].2, over ) )
        }
        
        return Observable.error(NSError(domain: "", code: 1))
    }
    
    private func addFieldToListFieldView(tuple: (FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon, MKOverlayRenderer), mapFieldInteraction: MapFieldInteraction) {
        mapFieldInteraction.selectedField(field: tuple.0)
    }
    
    private func removeFieldToListFieldView(tuple: (FieldType, AnnotationWithData<PayloadFieldAnnotation>, MKPolygon, MKOverlayRenderer), mapFieldInteraction: MapFieldInteraction) {
        mapFieldInteraction.deselectedField(field: tuple.0)
    }
    
}
