//
//  save_preset.swift
//  Filters2ProQ
//
//  Created by Jack Angione on 6/22/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct FFP_preset: FileDocument {
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    static var readableContentTypes: [UTType] { [.ffp] }

    func fileWrapper(configuration: WriteConfiguration) throws
        -> FileWrapper
    {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }

    var text: String = ""

    init(_ text: String = "") {
        self.text = text
    }
}

func save_preset(
    proQ_eq_bands: inout [[String]], export_document: inout FFP_preset,
    channel: Character
) throws {
    print("printing \(channel) stereo'd preset")
    //CLEAR EXISTING
    export_document.text = ""
    //first print preset heading info
    export_document.text +=
        "[Preset]\nSignature=FQ4p\nVersion=4\nAuthor=User\nDescription=\"Made With Filters2ProQ\"\n\n"
    export_document.text += "[Parameters]\n"

    var band_count: Int = 1
    let band_type_convert: [String: Int] = [
        "PK": 0, "LS": 1, "HS": 3, "LSC": 1, "HSC": 3,
    ]
    //stereo placement of bands
    let channel_detect: [Character: Int] = ["S": 2, "L": 0, "R": 1]

    for band in proQ_eq_bands {
        export_document.text += "Band \(band_count) Used=1 \n"
        export_document.text += "Band \(band_count) Enabled=1\n"
        export_document.text +=
            "Band \(band_count) Frequency=\(band[1])\n"
        export_document.text += "Band \(band_count) Gain=\(band[2])\n"
        export_document.text += "Band \(band_count) Q=\(band[3])\n"
        if let band_shape: Int = band_type_convert[band[0]] {
            export_document.text +=
                "Band \(band_count) Shape=\(band_shape)\n"
        } else {
            throw Preset_Creation_Error.invalid_band_type
        }
        export_document.text += "Band \(band_count) Slope=2\n"
        export_document.text +=
        "Band \(band_count) Stereo Placement=\(String(channel_detect[channel]!))\n"
        export_document.text += "Band \(band_count) Speakers=1\n"
        export_document.text += "Band \(band_count) Dynamic Range=0\n"
        export_document.text +=
            "Band \(band_count) Dynamics Enabled=1\n"
        export_document.text += "Band \(band_count) Dynamics Auto=1\n"
        export_document.text +=
            "Band \(band_count) Threshold=0.666666686534882\n"
        export_document.text += "Band \(band_count) Attack=50\n"
        export_document.text += "Band \(band_count) Release=50\n"
        export_document.text +=
            "Band \(band_count) External Side Chain=0\n"
        export_document.text +=
            "Band \(band_count) Side Chain Filtering=0\n"
        export_document.text +=
            "Band \(band_count) Side Chain Low Frequency=3.32192802429199\n"
        export_document.text +=
            "Band \(band_count) Side Chain High Frequency=14.287712097168\n"
        export_document.text +=
            "Band \(band_count) Side Chain Audition=0\n"
        export_document.text +=
            "Band \(band_count) Spectral Enabled=0\n"
        export_document.text +=
            "Band \(band_count) Spectral Density=50\n"
        export_document.text += "Band \(band_count) Solo=0\n"
        band_count += 1
    }
    //print remaining "empty" bands
    for band in (band_count...24) {
        export_document.text += "Band \(band) Used=0\n"
        export_document.text += "Band \(band) Enabled=1\n"
        export_document.text +=
            "Band \(band) Frequency=9.96578407287598\n"
        export_document.text += "Band \(band) Gain=0\n"
        export_document.text += "Band \(band) Q=0.5\n"
        export_document.text += "Band \(band) Shape=0\n"
        export_document.text += "Band \(band) Slope=2\n"
        export_document.text += "Band \(band) Stereo Placement=2\n"
        export_document.text += "Band \(band) Speakers=1\n"
        export_document.text += "Band \(band) Dynamic Range=0\n"
        export_document.text += "Band \(band) Dynamics Enabled=1\n"
        export_document.text += "Band \(band) Dynamics Auto=1\n"
        export_document.text +=
            "Band \(band) Threshold=0.666666686534882\n"
        export_document.text += "Band \(band) Attack=50\n"
        export_document.text += "Band \(band) Release=50\n"
        export_document.text += "Band \(band) External Side Chain=0\n"
        export_document.text += "Band \(band) Side Chain Filtering=0\n"
        export_document.text +=
            "Band \(band) Side Chain Low Frequency=3.32192802429199\n"
        export_document.text +=
            "Band \(band) Side Chain High Frequency=14.287712097168\n"
        export_document.text += "Band \(band) Side Chain Audition=0\n"
        export_document.text += "Band \(band) Spectral Enabled=0\n"
        export_document.text += "Band \(band) Spectral Density=50\n"
        export_document.text += "Band \(band) Solo=0\n"
    }
    //print extra info
    export_document.text +=
        "Processing Mode=1\nProcessing Resolution=1\n"
    export_document.text +=
        "Character=0\nGain Scale=1\nOutput Level=0\nOutput Pan=0\nOutput Pan Mode=0\nBypass=0\nOutput Invert Phase=0\n"
    export_document.text +=
        "Auto Gain=0\nAnalyzer Show Pre-Processing=1\nAnalyzer Show Post-Processing=1\nAnalyzer Show External Spectrum=1\n"
    export_document.text +=
        "Analyzer External Spectrum=-1\nAnalyzer Range=0\nAnalyzer Resolution=3\nAnalyzer Speed=2\nAnalyzer Tilt=2\n"
    export_document.text +=
        "Analyzer Freeze=0\nAnalyzer Show Collisions=0\nSpectrum Grab=0\nDisplay Range=2\nReceive Midi=0\nSolo Gain=0\n"

    export_document.text += "Band 1 Spectral Tilt=1\n"
    export_document.text += "Band 2 Spectral Tilt=1\n"
    export_document.text += "Band 3 Spectral Tilt=1\n"
    export_document.text += "Band 4 Spectral Tilt=1\n"
    export_document.text += "Band 5 Spectral Tilt=1\n"
    export_document.text += "Band 6 Spectral Tilt=1\n"
    export_document.text += "Band 7 Spectral Tilt=0\n"
    export_document.text += "Band 8 Spectral Tilt=0\n"
    export_document.text += "Band 9 Spectral Tilt=0\n"
    export_document.text += "Band 10 Spectral Tilt=0\n"
    export_document.text += "Band 11 Spectral Tilt=0\n"
    export_document.text += "Band 12 Spectral Tilt=0\n"
    export_document.text += "Band 13 Spectral Tilt=0\n"
    export_document.text += "Band 14 Spectral Tilt=0\n"
    export_document.text += "Band 15 Spectral Tilt=0\n"
    export_document.text += "Band 16 Spectral Tilt=0\n"
    export_document.text += "Band 17 Spectral Tilt=0\n"
    export_document.text += "Band 18 Spectral Tilt=0\n"
    export_document.text += "Band 19 Spectral Tilt=0\n"
    export_document.text += "Band 20 Spectral Tilt=0\n"
    export_document.text += "Band 21 Spectral Tilt=0\n"
    export_document.text += "Band 22 Spectral Tilt=0\n"
    export_document.text += "Band 23 Spectral Tilt=0\n"
    export_document.text += "Band 24 Spectral Tilt=0"
}

enum Preset_Creation_Error: Error {
    case invalid_band_type
}
