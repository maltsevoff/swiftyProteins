//
//  FilesManager.swift
//  swiftyProteins
//
//  Created by Yaroslava HLIBOCHKO on 7/28/19.
//  Copyright © 2019 Yaroslava HLIBOCHKO. All rights reserved.
//

import Foundation

class FileManager  {
    
    func findFileForLigandModel(name: String, completionHandler: @escaping (String?) -> Void)  {
        guard let url = URL(string: "https://files.rcsb.org/ligands/\(name.first!)/\(name)/\(name)_ideal.pdb") else { return }
        let task = URLSession.shared.downloadTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let pdbfile : String = try? String(contentsOf: data) {
                        completionHandler(pdbfile)
                    }
                }
            }
        }
        task.resume()
    }
    
    func findFileForLigandInformation(name: String, completionHandler: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://files.rcsb.org/ligands/download/\(name).cif") else { return }
        let task = URLSession.shared.downloadTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    if let cifFile: String = try? String(contentsOf: data) {
                        completionHandler(cifFile)
                    }
                }
            }
        }
        task.resume()
    }
}
