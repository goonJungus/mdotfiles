// wifiscan: prints nearby Wi-Fi networks in airport -s line format
// (SSID BSSID RSSI CHAN HT CC SECURITY) for the sketchybar wifi popup.
// CoreWLAN redacts SSIDs until the user grants Location once.
import Foundation
import CoreWLAN
import CoreLocation

final class Delegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ m: CLLocationManager, didChangeAuthorization s: CLAuthorizationStatus) {}
    func locationManagerDidChangeAuthorization(_ m: CLLocationManager) {}
    func locationManager(_ m: CLLocationManager, didFailWithError e: Error) {}
}

func secLabel(_ n: CWNetwork) -> String {
    if n.supportsSecurity(.wpa3Enterprise) { return "WPA3 Enterprise" }
    if n.supportsSecurity(.wpa3Personal) { return "WPA3 Personal" }
    if n.supportsSecurity(.wpa2Enterprise) { return "WPA2 Enterprise" }
    if n.supportsSecurity(.wpaEnterprise) || n.supportsSecurity(.wpaEnterpriseMixed) { return "WPA Enterprise" }
    if n.supportsSecurity(.wpa2Personal) { return "WPA2 Personal" }
    if n.supportsSecurity(.wpaPersonal) || n.supportsSecurity(.wpaPersonalMixed) { return "WPA Personal" }
    if n.supportsSecurity(.WEP) || n.supportsSecurity(.dynamicWEP) { return "WEP" }
    return "NONE"
}

let delegate = Delegate()
let manager = CLLocationManager()
manager.delegate = delegate
if manager.authorizationStatus == .notDetermined {
    manager.requestWhenInUseAuthorization()
    let deadline = Date().addingTimeInterval(25)
    while manager.authorizationStatus == .notDetermined && Date() < deadline {
        RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.2))
    }
}
let client = CWWiFiClient.shared()
if let iface = client.interface(), let nets = try? iface.scanForNetworks(withName: nil) {
    var seen = Set<String>()
    for n in nets.sorted(by: { $0.rssiValue > $1.rssiValue }) {
        guard let ssid = n.ssid, !ssid.isEmpty, ssid != "<redacted>", !seen.contains(ssid) else { continue }
        seen.insert(ssid)
        let sec = secLabel(n)
        print("\(ssid)  \(n.bssid ?? "00:00:00:00:00:00") \(n.rssiValue) \(n.wlanChannel?.channelNumber ?? 0) Y -- \(sec)")
    }
}
