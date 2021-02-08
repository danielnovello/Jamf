#!/usr/bin/swift
//Extension attribute for Jamf
import Foundation

//ByteCountFormatter
let formatter = ByteCountFormatter()
formatter.allowedUnits = .useAll
formatter.countStyle = .file
formatter.includesUnit = true
formatter.isAdaptive = true

//Calculate
let fileURL = URL(fileURLWithPath:"/")
do {
    let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
    if let capacity = values.volumeAvailableCapacityForImportantUsage {
        //Pretty
        print("<result>\(formatter.string(fromByteCount: (capacity)))</result>")
        //Bytes
        //print(capacity)
    } else {
        print("<result>Capacity is unavailable</result>")
    }
} catch {
    print("<result>Error retrieving capacity: \(error.localizedDescription)</result>")
}

