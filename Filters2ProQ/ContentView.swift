import SwiftData
import SwiftUI
//
//  ContentView.swift
//  Filters2ProQ
//
//  Created by Jack Angione on 6/6/25.
//
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var importing_L = false
    @State private var importing_R = false
    @State private var exporting_L = false
    @State private var exporting_R = false
    
    @State private var selectedFile: URL?
    @State private var fileContent: String = ""
    @State private var filterList: [String] = []

    @State private var dual_channel: Bool = false
    //LEFT CHANNEL IS USED TO STEREO
    @State private var L_proQ_eq_bands: [[String]] = []
    @State private var R_proQ_eq_bands: [[String]] = []

    @State private var L_original_eq_bands: [[String]] = []
    @State private var R_original_eq_bands: [[String]] = []

    @State private var L_export_document: FFP_preset = FFP_preset()
    @State private var R_export_document: FFP_preset = FFP_preset()


    var body: some View {
        ScrollView {

            Toggle(isOn: $dual_channel) {
                Text("Stereo Filters")
                Text("Enable for separate left and right channels")

            }.toggleStyle(.switch)
            HStack {
                //LEFT
                VStack {
                    Button(
                        dual_channel ? "Import Left Filters" : "Import Filters"
                    ) {
                        importing_L = true

                    }.fileImporter(
                        isPresented: $importing_L,
                        allowedContentTypes: [.plainText],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                //CODE TO RUN ON IMPORT
                                selectedFile = url
                                if dual_channel {
                                    load_text_filters(
                                        from: url,
                                        proQ_eq_bands: &L_proQ_eq_bands,
                                        original_eq_bands: &L_original_eq_bands,
                                        channel: "L")
                                } else {

                                    load_text_filters(
                                        from: url,
                                        proQ_eq_bands: &L_proQ_eq_bands,
                                        original_eq_bands: &L_original_eq_bands,
                                        channel: "S")
                                }
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }.padding(20)
                        
                    VStack {
                        Text(dual_channel ? "Left Filters" : "Filter").bold()
                        Divider().frame(width: 150)
                        Grid {
                            GridRow {
                                Text("Band").bold()
                                Text("Type").bold()
                                Text("Frequency").bold()
                                Text("Gain").bold()
                                Text("Q").bold()
                            }
                            ForEach(0..<L_original_eq_bands.count, id: \.self) {
                                index in
                                GridRow {
                                    Text(String(index+1))
                                    Text(L_original_eq_bands[index][0] + " ")
                                    Text(L_original_eq_bands[index][1] + "Hz ")
                                    Text(L_original_eq_bands[index][2] + "db ")
                                    Text(L_original_eq_bands[index][3] + " ")
                                }
                                Divider()
                            }
                        }.padding(.horizontal, 20)
                    }

                    Button(
                        dual_channel ? "Export Left Preset" : "Export Preset"
                    ) {
                        exporting_L = true
                    }.fileExporter(
                        isPresented: $exporting_L, document: L_export_document,
                        contentType: .ffp, defaultFilename: "Filters2ProQ_L"
                    ) { result in
                        switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }.fileDialogDefaultDirectory(
                        URL(
                            fileURLWithPath:
                                "\(FileManager.default.homeDirectoryForCurrentUser)/Documents/FabFilter/Presets/Pro-Q 4/"
                        )
                    ).padding(20)
                    Spacer()
                }
                
                if dual_channel {
                    //RIGHT
                    Divider()
                    VStack(alignment: .center) {

                        Button("Import Right Filters") {
                            importing_R = true

                        }.fileImporter(
                            isPresented: $importing_R,
                            allowedContentTypes: [.plainText],
                            allowsMultipleSelection: false
                        ) { result in
                            switch result {
                            case .success(let urls):
                                if let url = urls.first {
                                    //CODE TO RUN ON IMPORT
                                    selectedFile = url
                                    load_text_filters(
                                        from: url,
                                        proQ_eq_bands: &R_proQ_eq_bands,
                                        original_eq_bands: &R_original_eq_bands,
                                        channel: "R")
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }.padding(20)
                        HStack {
                                VStack {
                                    Text("Right Filters ").bold()
                                    Divider().frame(width: 150)
                                    Grid {
                                        GridRow {
                                            Text("Band").bold()
                                            Text("Type").bold()
                                            Text("Frequency").bold()
                                            Text("Gain").bold()
                                            Text("Q").bold()
                                        }
                                        ForEach(
                                            0..<R_original_eq_bands.count,
                                            id: \.self
                                        ) { index in
                                            GridRow {
                                                Text(String(index+1))
                                                Text(
                                                    R_original_eq_bands[index][
                                                        0] + " ")
                                                Text(
                                                    R_original_eq_bands[index][
                                                        1] + "Hz ")
                                                Text(
                                                    R_original_eq_bands[index][
                                                        2] + "db ")
                                                Text(
                                                    R_original_eq_bands[index][
                                                        3] + " ")
                                            }
                                            Divider()
                                        }
                                    }.padding(.horizontal, 20)
                                }
                        }
                        Button("Export Right Preset") {
                            exporting_R = true
                        }.fileExporter(
                            isPresented: $exporting_R,
                            document: R_export_document,
                            contentType: .ffp, defaultFilename: "Filters2ProQ_R"
                        ) { result in
                            switch result {
                            case .success(let url):
                                print("Saved to \(url)")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }.fileDialogDefaultDirectory(
                            URL(
                                fileURLWithPath:
                                    "\(FileManager.default.homeDirectoryForCurrentUser)/Documents/FabFilter/Presets/Pro-Q 4/"
                            )
                        ).padding(20)
                        Spacer()
                    }
                }
            }
            
        }
    }
    private func load_text_filters(
        from url: URL, proQ_eq_bands: inout [[String]],
        original_eq_bands: inout [[String]], channel: Character
    ) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Could not access security scoped resource")
            return
        }

        defer { url.stopAccessingSecurityScopedResource() }

        do {
            //
            if url.pathExtension.lowercased() == "txt" {
                fileContent = try String(contentsOf: url, encoding: .utf8)
                filterList = fileContent.split(separator: "\n").map(String.init)
            } else {
                fileContent = "File loaded: \(url.lastPathComponent)"
            }
            print("Successfully loaded file content")
            proQ_eq_bands.removeAll()
            original_eq_bands.removeAll()
            for filter in filterList {
                //TODO IF LINE STARTS WITH FILTER AND LINE IS 8 OR MORE WORDS LONG
                let filter_info = filter.split(separator: " ")
                print("GETTING EQ BANDS")
                if filter_info[0] == "Filter" && filter_info.count >= 8 {
                    if filter_info[3] == "HS" || filter_info[3] == "LS"
                        || filter_info[3] == "LSC" || filter_info[3] == "HSC"
                    {
                        //store filter band converted to proQ preset values
                        proQ_eq_bands.append([
                            String(filter_info[3]),
                            convert_freq(filter_freq: String(filter_info[5])),
                            String(filter_info[8]),
                            convert_q(filter_qfactor: "0.7"),
                        ])
                        //store original filter band info to display
                        original_eq_bands.append([
                            String(filter_info[3]), String(filter_info[5]),
                            String(filter_info[8]), "0.7",
                        ])
                    } else {
                        //store filter band converted to proQ preset values
                        proQ_eq_bands.append([
                            String(filter_info[3]),
                            convert_freq(filter_freq: String(filter_info[5])),
                            String(filter_info[8]),
                            convert_q(filter_qfactor: String(filter_info[11])),
                        ])
                        //store original filter band info to display
                        original_eq_bands.append([
                            String(filter_info[3]), String(filter_info[5]),
                            String(filter_info[8]), String(filter_info[11]),
                        ])
                    }
                }
            }
            do {
                if(channel=="L"||channel=="S")
                {
                    try save_preset(proQ_eq_bands: &proQ_eq_bands,
                        export_document: &L_export_document, channel: channel)
                }
                else {
                    try save_preset(proQ_eq_bands: &proQ_eq_bands,
                                    export_document: &R_export_document, channel: channel)
                }
                
            } catch {
                print("Error saving preset")
            }

        } catch {
            print("Error reading file: \(error.localizedDescription)")
            fileContent = "Error loading file"
        }
    }
    private func convert_freq(filter_freq: String) -> String {
        //preset frequency = log2(eq band frequency)
        if let filter_freq_decimal: Double = Double(filter_freq) {
            return String(log2(filter_freq_decimal))
        }

        return "Frequency Conversion Error"
    }
    private func convert_q(filter_qfactor: String) -> String {
        // *ProQ implements a different scale of q factor compared to other EQs
        // Pro-Q Q = Butterworth Q / sqrt(0.5)
        // exponential equation: eq qfactor = .025*1600^preset_number
        // 1=.025*1600^.5

        //convert buttersworth q to proQ equivalent
        if var proq_q: Double = Double(filter_qfactor) {
            proq_q = proq_q / sqrt(0.5)
            return String((log(proq_q / 0.025) / log(1600)))
        }

        return "Q Conversion Error"
    }

   
    
}
