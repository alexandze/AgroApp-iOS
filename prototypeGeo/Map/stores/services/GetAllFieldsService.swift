//
//  GetAllFields.swift
//  prototypeGeo
//
//  Created by Alexandre Andze Kande on 2020-01-27.
//  Copyright © 2020 Alexandre Andze Kande. All rights reserved.
//

import Foundation
import MapKit

extension MapFieldService {
    public func getFields() -> ([(Field<Polygon>, MKPolygon, MKPointAnnotation)?], [(Field<MultiPolygon>, [(MKPolygon, MKPointAnnotation )?])])? {
        let fieldsGeoJson = self.mapFieldRepository.getFieldGeoJsonArray()
        
        return fieldsGeoJson.map { (fieldsGeoJsonUnwrap: FieldGeoJsonArray) -> ([(Field<Polygon>, MKPolygon, MKPointAnnotation)?], [(Field<MultiPolygon>, [(MKPolygon, MKPointAnnotation )?])]) in
            let tupleFormatFieldJson = formatFieldsGeoJson(fieldsGeoJson: fieldsGeoJsonUnwrap)
            let fieldMKPolygonMKPointAnnotation = createMKPolygonMKPointAnnotationFor(fields: tupleFormatFieldJson.0)
            let fieldMKMultiPolygonMKPointAnnotation = createMKMultiPolygonMKPoinAnnotationFor(fields: tupleFormatFieldJson.1)
            return (fieldMKPolygonMKPointAnnotation, fieldMKMultiPolygonMKPointAnnotation)
        }
    }

    private func formatFieldsGeoJson(fieldsGeoJson: FieldGeoJsonArray) -> ([Field<Polygon>], [Field<MultiPolygon>]) {
        let fieldPolygon = formatFieldsGeoJsonToFieldPolygon(fieldsGeoJson: fieldsGeoJson)
        let fieldMultiPolygon = formatFieldsGeoJsonToFieldMultiPolygon(fieldsGeoJson: fieldsGeoJson)
        return (fieldPolygon, fieldMultiPolygon)
    }

    private func formatFieldsGeoJsonToFieldPolygon(fieldsGeoJson: FieldGeoJsonArray) -> [Field<Polygon>] {
        let fieldsPolygone = filterPolygon(fieldsGeoJson: fieldsGeoJson)
        
        return fieldsPolygone.features.map {(feature: Feature) -> Field<Polygon> in
            let type = feature.geometry.type!
            let id = feature.id
            let coordinates = feature.geometry.coordinates![0]
            let polygon = Polygon(value: coordinates)
            return Field(id: id, name: "", type: type, culturalPratice: nil, coordinates: polygon)
        }
    }

    private func formatFieldsGeoJsonToFieldMultiPolygon(fieldsGeoJson: FieldGeoJsonArray) -> [Field<MultiPolygon>] {
        let fieldMultiPolygons = filterMultiPolygon(fieldsGeoJson: fieldsGeoJson)
        
        return fieldMultiPolygons.features.map { (feature: Feature) -> Field<MultiPolygon> in
            let type = feature.geometry.type!
            let id = feature.id
            let coordinates = feature.geometry.coordinatesMulti![0]
            let multiPolyon = MultiPolygon(value: coordinates)
            return Field(id: id, name: "", type: type, culturalPratice: nil, coordinates: multiPolyon)
        }
    }


    private func filterPolygon(fieldsGeoJson: FieldGeoJsonArray) -> FieldGeoJsonArray {
        FieldGeoJsonArray(features: fieldsGeoJson.features.filter { $0.geometry.type == "Polygon" })
    }

    private func filterMultiPolygon(fieldsGeoJson: FieldGeoJsonArray) -> FieldGeoJsonArray {
        FieldGeoJsonArray(features: fieldsGeoJson.features.filter { $0.geometry.type == "MultiPolygon" })
    }


    ///////////////////////
    private func calculCenterPolygon(from mapPoint:[MKMapPoint]) -> CLLocationCoordinate2D? {
        let minLatitude = getMinLatitude(from: mapPoint)
        let maxLatitude = getMaxLatitude(from: mapPoint)
        let minLongitude = getMinLongitude(from: mapPoint)
        let maxLongitude = getMaxLongitude(from: mapPoint)
        
        if let minLatitude = minLatitude,
            let maxLatitude = maxLatitude,
            let minLongitude = minLongitude,
            let maxLongitude = maxLongitude {
            let centerLatitude = minLatitude + ((maxLatitude - minLatitude) / 2)
            let centerLongitude = minLongitude + ((maxLongitude - minLongitude) / 2)
            return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        }
        
        return nil
    }
    
    private func getMaxLatitude(from mapPoint:[MKMapPoint]) -> Double? {
        let max = mapPoint.max {$0.coordinate.latitude < $1.coordinate.latitude }
        return max?.coordinate.latitude
    }

    private func getMinLatitude(from mapPoint:[MKMapPoint]) -> Double? {
        let min  = mapPoint.min {$0.coordinate.latitude < $1.coordinate.latitude }
        return min?.coordinate.latitude
    }

    private func getMinLongitude(from mapPoint:[MKMapPoint]) -> Double? {
        let min  = mapPoint.min {$0.coordinate.longitude < $1.coordinate.longitude }
        return min?.coordinate.longitude
    }

    private func getMaxLongitude(from mapPoint:[MKMapPoint]) -> Double? {
        let max = mapPoint.max {$0.coordinate.longitude < $1.coordinate.longitude }
        return max?.coordinate.longitude
    }
    
    //////////////
    private func createMKPolygonMKPointAnnotationFor(fields: [Field<Polygon>]) -> [(Field<Polygon>, MKPolygon, MKPointAnnotation)?] {
        fields.map { createFieldWithMKPolygon(field: $0) }
    }

    private func createMKMultiPolygonMKPoinAnnotationFor(fields: [Field<MultiPolygon>]) -> [(Field<MultiPolygon>, [(MKPolygon, MKPointAnnotation )?])] {
        fields.map { createFieldWithMKMultiPolygon(field: $0) }
    }
    
    private func createMapPoints(from polygonType: PolygonType) -> [MKMapPoint] {
        polygonType.map { MKMapPoint(CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])) }
    }

    private func createPolygon(from mapPoint: [MKMapPoint]) -> MKPolygon {
        MKPolygon(points: mapPoint, count: mapPoint.count)
    }

    private func createFieldWithMKPolygon(field: Field<Polygon>) -> (Field<Polygon>, MKPolygon, MKPointAnnotation)? {
        let mapPoint = createMapPoints(from: field.coordinates.value)
        let mkPolygon = createPolygon(from: mapPoint)
        let centerLocationCoordinate2D = calculCenterPolygon(from: mapPoint)
        
        return centerLocationCoordinate2D.map { (location: CLLocationCoordinate2D) -> (Field<Polygon>, MKPolygon, MKPointAnnotation) in
            let mkPointannotation = createPointAnnotation(locationCoordinate2D: location, title: "\(field.id)", subtitle: nil)
            
            return (field, mkPolygon, mkPointannotation)
        }
    }

    private func createFieldWithMKMultiPolygon(field: Field<MultiPolygon>) -> (Field<MultiPolygon>, [(MKPolygon, MKPointAnnotation)?]) {
       let mkPolygonsAndMkPointAnnotation = field.coordinates.value.map {(polygonType: PolygonType) -> (MKPolygon, MKPointAnnotation)? in
            let mapPoint = createMapPoints(from: polygonType)
            let mkPolygon = createPolygon(from: mapPoint)
            let centerLocationCoordinate2D = calculCenterPolygon(from: mapPoint)
        
            return centerLocationCoordinate2D.map {(location: CLLocationCoordinate2D) -> (MKPolygon, MKPointAnnotation) in
                let mkPointannotation = createPointAnnotation(locationCoordinate2D: location, title: "\(field.id)", subtitle: "")
                return (mkPolygon, mkPointannotation)
            }
        }
        
        return (field, mkPolygonsAndMkPointAnnotation)
    }

    

    private func createPointAnnotation(locationCoordinate2D: CLLocationCoordinate2D, title: String?, subtitle: String?) -> MKPointAnnotation {
        let locationCoordianate = locationCoordinate2D
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = locationCoordianate
        pointAnnotation.title = title
        pointAnnotation.subtitle = subtitle
        return pointAnnotation
    }
}