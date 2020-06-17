//
//  MapUI.swift
//  TheLight2
//
//  Created by Peter Balsamo on 5/7/20.
//  Copyright © 2020 Peter Balsamo. All rights reserved.
//

import SwiftUI
import MapKit

struct MapUI: View {

    @State var manager = CLLocationManager()
    @State var alert = false

    var body: some View {

        MapView(manager: $manager, alert: $alert).alert(isPresented: $alert) {

            Alert(title: Text("Please Enable Location Access In Settings Pannel !!!"))
        }
    }
}

struct MapUI_Previews: PreviewProvider {
    static var previews: some View {
        MapUI()
    }
}

struct MapView : UIViewRepresentable {

    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    let map = MKMapView()

    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(parent1: self)
    }

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {


        let center = CLLocationCoordinate2D(latitude: 13.086, longitude: 80.2707)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.region = region
        manager.requestWhenInUseAuthorization()
        manager.delegate = context.coordinator
        manager.startUpdatingLocation()
        return map
    }
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {

    }

    class Coordinator : NSObject,CLLocationManagerDelegate{

        var parent : MapView

        init(parent1 : MapView) {

            parent = parent1
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

            if status == .denied{

                parent.alert.toggle()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            let location = locations.last
            let point = MKPointAnnotation()

            let georeader = CLGeocoder()
            georeader.reverseGeocodeLocation(location!) { (places, err) in
                if err != nil{
                    print((err?.localizedDescription)!)
                    return
                }

                let place = places?.first?.locality
                point.title = place
                point.subtitle = "Current"
                point.coordinate = location!.coordinate
                self.parent.map.removeAnnotations(self.parent.map.annotations)
                self.parent.map.addAnnotation(point)

                let region = MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.parent.map.region = region
            }
        }
    }
}
