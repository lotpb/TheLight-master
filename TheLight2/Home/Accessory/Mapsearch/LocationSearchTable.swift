//
//  LocationSearchTable.swift
//  places
//
//  Created by Ashish Verma on 11/7/17.
//  Copyright © 2017 Ashish Verma. All rights reserved.
//

import UIKit
import MapKit


@available(iOS 13.0, *)
final class LocationSearchTable: UITableViewController {
    
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    //Formats Address to Display
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    func setupTableView() {
        self.tableView!.backgroundColor = .systemGray4
        self.tableView!.tableFooterView = UIView(frame: .zero)
    }

    //returns number of rows for the LocationSearchTable
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    //itterate the data inside the tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = .secondarySystemGroupedBackground
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name //selectedItem.locality
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }

    //Action for selectedRow
     override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
         let selectedItem = matchingItems[indexPath.row].placemark
         handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
         dismiss(animated: true)

         self.performSegue(withIdentifier: "DetailedVC", sender: indexPath);
     }
     //perfoms segue
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "DetailedVC" ,
             let nextScene = segue.destination as? DetailedMapVC ,
             let indexPath = self.tableView.indexPathForSelectedRow {
             let selectedRow = matchingItems[indexPath.row]
             nextScene.mapData = selectedRow
         }
     }
}
//creates a custom MKLocalSearchRequest and gets MKLocalSearchResponse
@available(iOS 13.0, *)
extension LocationSearchTable: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
@available(iOS 13.0, *)
extension LocationSearchTable {

}
@available(iOS 13.0, *)
extension LocationSearchTable {

}
