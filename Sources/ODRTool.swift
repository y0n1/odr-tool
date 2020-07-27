//
//  AddODRTags.swift
//  add-odr-tags
//
//  Created by Jonathan Kilzi on 28/07/2020.
//  Copyright © 2020 Jonathan Kilzi. All rights reserved.
//

import Foundation
import PathKit
import XcodeProj
import ArgumentParser

// Tasks:
//  - Read the xcodeproj file
//  - Add the resources to the project
//  - Assign the resources to Targets
//  - Add On Demand Resource Tags to each resource
//  - Write the xcodeproj file


struct ODRTool: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "odrtool")
    
    @Option(
        name: NameSpecification.shortAndLong,
        help: "The path to the .xcodeproj directory"
    )
    var projectPath: String;
    
    @Option(
        name: NameSpecification.shortAndLong,
        help: "The resource's name to be tagged; the generated tag will carry this value"
    )
    var resourceName: String;
    
    fileprivate func addResourceTags(pbxproj: PBXProj) throws -> Void  {
        let ASSET_TAGS = "ASSET_TAGS"
        let KNOWN_ASSET_TAGS = "KnownAssetTags"
        let RESOURCE_NAME = self._resourceName.wrappedValue
        let fileReferences = Utils.findFileReferencesBy(path: RESOURCE_NAME, pbxproj)
        
        for fileRef in fileReferences {
            let buildFiles = Utils.findBuildFilesBy(fileRef, pbxproj)
            
            for buildFile in buildFiles {
                buildFile.settings = buildFile.settings ?? Dictionary<String, Any>()
                let assetTags = (buildFile.settings?[ASSET_TAGS] as? [String]) ?? []
                buildFile.settings?.updateValue([RESOURCE_NAME] + assetTags, forKey: ASSET_TAGS)
                let resourcesBuildPhases = Utils.findResourcesBuildPhasesBy(buildFile, pbxproj)
                
                for resourcesBuildPhase in resourcesBuildPhases {
                    let nativeTargets = Utils.findNativeTargetsBy(resourcesBuildPhase, pbxproj)
                    
                    for nativeTarget in nativeTargets {
                        let projects = pbxproj.projects.filter { project in
                            return project.targets.contains { target in target.uuid == nativeTarget.uuid }
                        }
                        
                        for project in projects {
                            let knownAssetTags = (project.attributes[KNOWN_ASSET_TAGS] as? [String]) ?? []
                            project.attributes.updateValue([RESOURCE_NAME] + knownAssetTags, forKey: KNOWN_ASSET_TAGS)
                        }
                    }
                }
            }
        }
    }
    
    mutating func run() throws {
        let projectPath = Path(self._projectPath.wrappedValue)
        let xcodeproj = try XcodeProj(path: projectPath)
        try self.addResourceTags(pbxproj: xcodeproj.pbxproj)
        try xcodeproj.write(path: projectPath)
    }
}
