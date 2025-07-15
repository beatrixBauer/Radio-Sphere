//
//  LocationManager.swift
//  Radio_Sphere
//

import Foundation
import CoreLocation

// MARK: LocationManager verwaltet die Abfrage der lokalen Radiosender, basierend auf dem aktuellen Standort

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var currentLocation: CLLocation?
    @Published var countryCode: String?
    @Published var state: String?
    @Published var nearestCity: String?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // Startet die Standortabfrage
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Beendet die Standortabfrage
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    // Standortaktualisierung behandeln
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.currentLocation = location
        print("Standort aktualisiert: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        reverseGeocodeLocation(location)
        stopLocationUpdates()
    }

    // Standortberechtigung ändern
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Standortberechtigung erteilt, Standort wird angefordert.")
            requestLocation()
        case .denied, .restricted:
            print("Standortberechtigung verweigert oder eingeschränkt.")
            stopLocationUpdates()
            currentLocation = nil
        case .notDetermined:
            print("Standortberechtigung noch nicht festgelegt.")
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Unbekannter Standortberechtigungsstatus.")
        }
    }

    // Geokodierung: Ländercode, Bundesland und nächste Stadt bestimmen
    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil, let placemark = placemarks?.first else { return }

            self.countryCode = placemark.isoCountryCode
            self.state = placemark.administrativeArea
            self.nearestCity = placemark.locality

            print("Ländercode: \(self.countryCode ?? "Unbekannt"), Bundesland: \(self.state ?? "Unbekannt"), Stadt: \(self.nearestCity ?? "Unbekannt")")
        }
    }

    // Berechnet die Entfernung zwischen dem aktuellen Standort und einem Radiosender
    func getDistanceToStation(station: RadioStation) -> CLLocationDistance? {
        guard let userLocation = currentLocation,
              let latitude = station.geo_lat,
              let longitude = station.geo_long else {
            return nil
        }
        let stationLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: stationLocation)
    }

    // Filtert Radiosender basierend auf der Entfernung zum aktuellen Standort (ohne Sortierung)
    func filterStationsByProximity(_ stations: [RadioStation], maxDistance: Double = 50000.0) -> [RadioStation] {
        guard let userLocation = currentLocation else {
            print("Standort nicht verfügbar")
            return stations
        }

        return stations.filter { station in
            guard let latitude = station.geo_lat, let longitude = station.geo_long else {
                return false
            }
            let stationLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distance = userLocation.distance(from: stationLocation)
            return distance <= maxDistance
        }
    }

}
