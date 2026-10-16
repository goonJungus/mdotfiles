// wifi-ssid: prints the current Wi-Fi SSID.
// Reads the AirPort dynamic-store entry's CachedScanRecord (which still
// carries the real SSID) without needing Location Services.
import CoreWLAN
import Foundation
import SystemConfiguration

func currentSSID() -> String? {
    guard let store = SCDynamicStoreCreate(nil, "wifi-ssid" as CFString, nil, nil),
          let dict = SCDynamicStoreCopyValue(store, "State:/Network/Interface/en0/AirPort" as CFString) as? [String: Any] else {
        return nil
    }
    if let s = dict["SSID_STR"] as? String, !s.isEmpty, s != "<redacted>" { return s }
    if let data = dict["CachedScanRecord"] as? Data {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            defer { unarchiver.finishDecoding() }
            if let net = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? [String: Any] {
                if let s = net["SSID_STR"] as? String, !s.isEmpty { return s }
                if let s = net["SSID"] as? String, !s.isEmpty { return s }
                if let d = net["SSID"] as? Data, let s = String(data: d, encoding: .utf8),
                   !s.trimmingCharacters(in: .controlCharacters).isEmpty { return s }
            }
        } catch { }
    }
    return nil
}

if let ssid = currentSSID() {
    print(ssid)
}
