//
//  objPreviewViewController.swift
//  Carrt Measure
//
//  Created by Varaha Maithreya on 7/19/21.
//  Copyright © 2021 carrt usf. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import Zip


@available(iOS 13.0, *)
extension objPreviewViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        //3. Update Our Status View
        DispatchQueue.main.async {

            //1. Update The Tracking Status
           // self.statusLabel.text = self.augmentedRealitySession.sessionStatus()

           // 2. If We Have Nothing To Report Then Hide The Status View & Shift The Settings Menu
            if let validSessionText = self.statusLabel.text{

                self.sessionLabelView.isHidden = validSessionText.isEmpty
            }

            if self.sessionLabelView.isHidden { self.settingsConstraint.constant = 26 } else { self.settingsConstraint.constant = 0 }

        }
    }
}
@available(iOS 13.0, *)
class objPreviewViewController: UIViewController {
    var filePath: URL!
    var fileName: String = ""
    var unzipDirectory: URL!
    @IBOutlet weak var sceneView: SCNView!
    
    //5. Create Arrays To Store All The Nodes Placed
    @IBOutlet weak var sessionLabelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    var nodesAdded = [SCNNode]()
    var angleNodes = [SCNNode]()
    var distanceNodes = [SCNNode]()
    var lineNodes = [SCNNode]()
    var showDistanceLabels = true
    var showAngleLabels = false
    
    //6. Create A Variable Which Determines Whether The User Wants To Join The Last & First Markers Together
    var joiningNodes = false
    
    //7. Create An Array Of UILabels Which Will Display Our Length In Different Units
    @IBOutlet var measurementLabels: [UILabel]!
    @IBOutlet var unitHolder: UIView!
    
    //8. Settings Menu
    @IBOutlet var settingsMenu: UIView!
    @IBOutlet var settingsConstraint: NSLayoutConstraint!
    @IBOutlet var planeDetectionController: UISegmentedControl!
    @IBOutlet var festurePointController: UISegmentedControl!
    @IBOutlet var showAnglesController: UISegmentedControl!
    @IBOutlet var showDistanceController: UISegmentedControl!
    var settingsMenuShown = false
    
    //9. Variables To Determine If We Are Placing Our Markers On Detected Planes Or Feature Points
    var placeOnPlane = false
    var showFeaturePoints = false
    var placementType: ARHitTestResult.ResultType = .featurePoint
    //var  scene: SCNScene!
    var  scene =  SCNScene()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sceneView.backgroundColor = UIColor.gray
       initView()
        
        initScene()
        
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    //-------------
    //MARK: Actions
    //-------------
    func initView() {
        
        
        // Allow user to manipulate camera
        sceneView.allowsCameraControl = true
        
        // Show FPS logs and timming
        // sceneView.showsStatistics = true
        
        // Set background color
        sceneView.backgroundColor = UIColor.gray
        
        // Allow user translate image
        sceneView.cameraControlConfiguration.allowsTranslation = true
        
        
    }
    
    func initScene() {
        
        //let fileManager = FileManager()
        unzipObjfile(fileUrl: filePath)
        
        print(filePath as Any)
        print(unzipDirectory as Any)
        
        // 1: Load .obj file
        do {
            
            let objfileName: String = fileName.replacingOccurrences(of: ".zip", with: ".obj")
            print(objfileName)
            let objfilePath: String = unzipDirectory.path.replacingOccurrences(of: ".zip", with: "")+"/"
           // let  fileStrPath = filePath.path.replacingOccurrences(of: ".zip", with: "")+"/"
            print(objfilePath)
            
          
                
              // scene =  SCNScene(named: "210801-15.obj", inDirectory: fileStrPath)!
            scene =   try SCNScene(url: URL(fileURLWithPath: objfilePath+objfileName), options: nil)
          
                
            
            print("scene replaced")
            
            clearMeasurementLabels()
            
           
            
        // 2: Add camera node
            
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // 3: Place camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 35)
        // 4: Set camera on scene
            scene.rootNode.addChildNode(cameraNode)
        
        // 5: Adding light to scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 35)
            scene.rootNode.addChildNode(lightNode)
        
        // 6: Creating and adding ambien light to scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
            scene.rootNode.addChildNode(ambientLightNode)
        
        
        // Set scene settings
            sceneView.scene = scene
        }
        catch {
            print("ERROR loading scene")
        }
        
    }
    
    func unzipObjfile(fileUrl: URL){
        let fileManager = FileManager()
        //let currentWorkingPath = fileManager.currentDirectoryPath
        //var sourceURL = fileUrl
        //sourceURL.appendPathComponent("file.txt")
        //var destinationURL = URL(fileURLWithPath: currentWorkingPath)
       // destinationURL.appendPathComponent("archive.zip")
        do {
            print(fileUrl)
            unzipDirectory = try Zip.quickUnzipFile(fileUrl)
            print("Directory unzipped")
            print(try fileManager.contentsOfDirectory(at: unzipDirectory, includingPropertiesForKeys: [.nameKey, .fileSizeKey]))
            
        } catch {
            print("Creation of ZIP archive failed with error:\(error)")
        }
        
    }
    
    /// Closes All The Node Markers To Form A Shape
    @IBAction func closeMarkers(){ closeNodes() }
    
    /// Removes All Measurement Data
    @IBAction func reset(){
        
        //1. Remove All Nodes From The Hierachy
        //scene.rootNode.enumerateChildNodes { (nodeToRemove, _) in nodeToRemove.removeFromParentNode() }
        
        //2. Clear The NodesAdded Array
        nodesAdded.removeAll()
        angleNodes.removeAll()
        distanceNodes.removeAll()
        lineNodes.removeAll()
        
        //3. Reset The Joining Boolean
        joiningNodes = false
        
        //4. Reset The Labels
        clearMeasurementLabels()
        settingsMenu.alpha = 0
        settingsMenuShown = false
    }
    
    
    @IBAction func BackButtonClicked(){
        
        //pop out View controller
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    //--------------
    //MARK: Settings
    //--------------

    /// Shows And Hides The Settings Menu
    @IBAction func showSettingsMenu(){
        
        var opacity: CGFloat = 0
        var angleOpacity: CGFloat = 0
        var markerOpacity: CGFloat = 0
        
        if settingsMenu.alpha == 0 {
            
            settingsMenu.alpha = 1
            settingsMenuShown = true
            //augmentedRealityView.rippleView()
            
        } else {
            
            settingsMenu.alpha = 0
            settingsMenuShown = false
            opacity = 1
            
            if showAngleLabels { angleOpacity = 1 }
            if showDistanceLabels { markerOpacity = 1 }
            
        }
        
        setNodesVisibility(angleNodes, opacity: angleOpacity)
        setNodesVisibility(distanceNodes, opacity: markerOpacity)
        let markerAndLineNodes = lineNodes + nodesAdded
        setNodesVisibility(markerAndLineNodes, opacity: opacity)
    }
    
    /// Hides The 3D Distance Labels
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func hideDistanceLabels(_ controller: UISegmentedControl){
   
        if controller.selectedSegmentIndex != 1 {
            
            showDistanceLabels = true
            
        }else{
            
            showDistanceLabels = false
        }
        
    }
    
    /// Hides The 3D Angle Labels
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func hideAngleLabels(_ controller: UISegmentedControl){
        

        if controller.selectedSegmentIndex != 1 {
            
            showAngleLabels = true
            
        }else{
            showAngleLabels = false
        }
            
    }
    
    /// Determines Whether The VideoNode Should Be Placed Using Plane Detection
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setPlaneDetection(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1 { placeOnPlane = false } else { placeOnPlane = true }
        
        //setupSessionPreferences()
    }
    
    /// Determines Whether The User Should Be Able To See FeaturePoints
    ///
    /// - Parameter controller: UISegmentedControl
    @IBAction func setFeaturePoints(_ controller: UISegmentedControl){
        
        if controller.selectedSegmentIndex == 1 { showFeaturePoints = false } else { showFeaturePoints = true }
       // setupSessionPreferences()
    }
    
    //----------------------
    //MARK: Marker Placement
    //----------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if joiningNodes { reset() }
        
        if settingsMenuShown { return }
        
        //1. Perform An ARHitTest To Search For Any Existing Planes Or Feature Points
        if placeOnPlane { placementType = .existingPlane } else { placementType = .featurePoint }
        
        //2. Get The Current Touch Location & Perform An ARHitTest
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView),
              let hitTest = self.sceneView.hitTest(currentTouchLocation).last else { return }
                
               print(hitTest.simdModelTransform)
        print(hitTest.worldCoordinates)
        
        //3. Add A Marker Node
       
            addMarkerNodeFromMatrixV2(hitTest.simdLocalCoordinates)
       
        
    }
    

    /// Adds An SCNSphere At The Current Touch Location
    ///
    /// - Parameter matrix: matrix_float4x4
    
    func addMarkerNodeFromMatrixV2(_ matrix: simd_float3){
    
        //1. Create The Marker Node & Add It  To The Scene
        let markerNode = MarkerNodeV2(fromMatrix: matrix)
        self.scene.rootNode.addChildNode(markerNode)
        
        //3. Add It To Our NodesAdded Array
        nodesAdded.append(markerNode)
        
        //4. Perform Any Calculations Needed
        getDistanceBetweenNodes(needsJoining: joiningNodes)
    
        guard let angleResult = calculateAnglesBetweenNodes(joiningNodes: joiningNodes, nodes: nodesAdded) else { return }
        createAngleNodeLabelOn(angleResult.midNode, angle: angleResult.angle)

    }
    
    
    func addMarkerNodeFromMatrix(_ matrix: matrix_float4x4){
    
        //1. Create The Marker Node & Add It  To The Scene
        let markerNode = MarkerNode(fromMatrix: matrix)
        self.scene.rootNode.addChildNode(markerNode)
        
        //3. Add It To Our NodesAdded Array
        nodesAdded.append(markerNode)
        
        //4. Perform Any Calculations Needed
        getDistanceBetweenNodes(needsJoining: joiningNodes)
    
        guard let angleResult = calculateAnglesBetweenNodes(joiningNodes: joiningNodes, nodes: nodesAdded) else { return }
        createAngleNodeLabelOn(angleResult.midNode, angle: angleResult.angle)

    }
    
    /// Joins The Last & First Nodes
    func closeNodes(){
    
        joiningNodes = false
        getDistanceBetweenNodes(needsJoining: joiningNodes)
        
        guard let angleResult = calculateAnglesBetweenNodes(joiningNodes: joiningNodes, nodes: nodesAdded) else { return }
        createAngleNodeLabelOn(angleResult.midNode, angle: angleResult.angle)
        
        guard let angleResultB = calculateFinalAnglesBetweenNodes(nodesAdded) else { return }
        createAngleNodeLabelOn(angleResultB.midNode, angle: angleResultB.angle)
     
    }
    
    //-------------------------------------------
    //MARK: Calculation + Distance & Angle Labels
    //-------------------------------------------
    
    /// Calculates The Distance Between 2 SCNNodes
    func getDistanceBetweenNodes(needsJoining: Bool){
        
        //1. If We Have More Than Two Nodes On Screen We Can Calculate The Distance Between Them
        if nodesAdded.count >= 2{
            
            guard let result = calculateDistanceBetweenNodes(joiningNodes: needsJoining, nodes: nodesAdded) else { return }
            
            //2. Draw A Line Between The Nodes
            let line = MeasuringLineNode(startingVector: result.nodeA, endingVector: result.nodeB)
            self.scene.rootNode.addChildNode(line)
            lineNodes.append(line)
            
            //3. Create The Distance Label
            createDistanceLabel(joiningNodes: needsJoining, nodes: nodesAdded, distance: result.distance)
        }
        
    }
    
    func getDistanceBetweenNodeswithVectors(needsJoining: Bool){
        
        //1. If We Have More Than Two Nodes On Screen We Can Calculate The Distance Between Them
        if nodesAdded.count >= 2{
            
            guard let result = calculateDistanceBetweenNodes(joiningNodes: needsJoining, nodes: nodesAdded) else { return }
            
            //2. Draw A Line Between The Nodes
            let line = MeasuringLineNode(startingVector: result.nodeA, endingVector: result.nodeB)
            self.scene.rootNode.addChildNode(line)
            lineNodes.append(line)
            
            //3. Create The Distance Label
            createDistanceLabel(joiningNodes: needsJoining, nodes: nodesAdded, distance: result.distance)
        }
        
    }
    
    /// Creates An Angle Label Between Three SCNNodes
    ///
    /// - Parameters:
    ///   - node: SCNNode
    ///   - angle: Double
    func createAngleNodeLabelOn(_ node: SCNNode, angle: Double){
        
        //1. Format Our Angle
        let formattedAngle = String(format: "%.2f°", angle)
        
        //2. Create The Angle Label & Add It To The Corresponding Node
        let angleText = TextNode(text: formattedAngle, colour: .white)
        angleText.position = SCNVector3(0, 0.01, 0)
        node.addChildNode(angleText)
        
        //3. Store It
        angleNodes.append(angleText)
        
        var opacity: CGFloat = 0
        
        if showAngleLabels { opacity = 1 }
        setNodesVisibility(angleNodes, opacity: opacity)
    }
    
    /// Clears The Measurement Labels
    func clearMeasurementLabels(){
        
        measurementLabels.forEach{ $0.text = "" }
        unitHolder.alpha = 0
    }
    
    /// Creates A Distance Label Between Two SCNNodes
    ///
    /// - Parameters:
    ///   - joiningNodes: Bool (Joins The Last Node Added To The First)
    ///   - nodes: [SCNNode]
    ///   - distance: Float
    func createDistanceLabel(joiningNodes: Bool, nodes: [SCNNode], distance: Float){
        
        //1. Get The Nodes Used For Postioning
        guard let nodes = positionalNodes(joiningNodes: joiningNodes, nodes: nodes) else { return }
        let nodeA = nodes.nodeA
        let nodeB = nodes.nodeB
        
        //2. Format Our Angle
        let formattedDistance = String(format: "%.2f", distance)
   
        //4. Create The Distance Label & Add It To The Scene
        let distanceLabel = TextNode(text: "\(formattedDistance)m", colour: .white)
        distanceLabel.placeBetweenNodes(nodeA, and: nodeB)
        self.scene.rootNode.addChildNode(distanceLabel)
        
        //5. Generate The Measurement Labels
        generateMeasurementLabelsFrom(distance)
        
        //6. Store It
        distanceNodes.append(distanceLabel)
        
        var opacity: CGFloat = 0
        
        if showDistanceLabels { opacity = 1 }
        setNodesVisibility(distanceNodes, opacity: opacity)
    }
    
    func generateMeasurementLabelsFrom(_ distanceInMetres: Float){
        
        let sequence = stride(from: 0, to: 5, by: 1)
        let measurements = convertedLengthsFromMetres(distanceInMetres)
    
        let suffixes = ["m", "cm", "mm", "ft", "in"]
        
        for index in sequence {
         
            let labelToDisplay = measurementLabels[index]
            let value = "\(String(format: "%.2f", measurements[index].value))\(suffixes[index])"
            labelToDisplay.text = value
        }
        
        unitHolder.alpha = 1
        
    }
    
    //---------------------
    //MARK: Node Visibility
    //---------------------
    
    
    /// Sets The Visibility Of The Angle & Distance Text Nodes
    ///
    /// - Parameters:
    ///   - nodes: [SCNNode]
    ///   - opacity: CGFloat
    func setNodesVisibility(_ nodes: [SCNNode], opacity: CGFloat) {
        
        nodes.forEach { (node) in node.opacity = opacity }
    
    }
    
    //---------------
    //MARK: ARSession
    //---------------
    
    /// Sets Up The ARSession
//    func setupARSession(){
//
//        //1. Set The AR Session
//        augmentedRealityView.session = augmentedRealitySession
//        augmentedRealityView.delegate = self
//        setupSessionPreferences()
//
//    }
//    func setupSessionPreferences(){
//
//        configuration.planeDetection = [planeDetection(.None)]
//        augmentedRealityView.debugOptions = debug(.None)
//
//        if placeOnPlane { configuration.planeDetection = [planeDetection(.Both)] }
//
//        if showFeaturePoints { augmentedRealityView.debugOptions = debug(.FeaturePoints) }
//
//        //4. Run The Session & Reset The Video Node
//        augmentedRealitySession.run(configuration, options: runOptions(.ResetAndRemove))
//        reset()
//
//    }
    
}

extension objPreviewViewController{
    
    /// Converts Metres To CM, MM, Feet & Inches
    ///
    /// - Parameter metres: Float
    /// - Returns: [String]
    func convertedLengthsFromMetres(_ metres: Float) -> ([Measurement<UnitLength>]){
        
        var measurements = [Measurement<UnitLength>]()
        
        //1. Convert The Length To The Units Needed
        let m = Measurement(value: Double(metres), unit: UnitLength.meters)
        let cm = m.converted(to: UnitLength.centimeters)
        let mm = m.converted(to: UnitLength.millimeters)
        let feet = m.converted(to: UnitLength.feet)
        let inches = m.converted(to: UnitLength.inches)
        
        //2. Add Them To Our Array & Return
        measurements.append(m)
        measurements.append(cm)
        measurements.append(mm)
        measurements.append(feet)
        measurements.append(inches)
        
        return measurements
    }
    
    /// Calculates The Angle In Degrees From Three Vectors
    ///
    /// - Parameters:
    ///   - start: GLKVector3
    ///   - mid: GLKVector3
    ///   - end: GLKVector3
    /// - Returns: Double
    func angleFromVectors(start: GLKVector3, mid: GLKVector3, end: GLKVector3) -> Double {
        
        //* Based On The Following Solution https://lonelycoding.com/angle-between-3-points-in-3d-space/ *//
        
        let vector1 = GLKVector3Subtract(start, mid)
        let vector2 = GLKVector3Subtract(end, mid)
        
        let vector1Normalized = GLKVector3Normalize(vector1)
        let vector2Normalized = GLKVector3Normalize(vector2)
        
        let result = vector1Normalized.x * vector2Normalized.x + vector1Normalized.y * vector2Normalized.y + vector1Normalized.z * vector2Normalized.z
        let angle: Double = Double(GLKMathRadiansToDegrees(acos(result)))
        
        return angle
    }
    
    func positionalNodes(joiningNodes: Bool, nodes: [SCNNode]) -> (nodeA: SCNNode, nodeB: SCNNode)?{
        
        var nodeA:SCNNode!
        var nodeB:SCNNode!
        
        //1. If We Are Joining Nodes (Creating A Shape) Get The Last & First Nodes
        if joiningNodes{
            
            guard let lastMarkerNode = nodes.last,
                  let firstMarkerNode = nodes.first else { return nil }
            
            nodeA = firstMarkerNode
            nodeB = lastMarkerNode
            
        }else{
            
            //2. Else Get The Last & Penultimate Nodes To Measure
            guard let lastMarkerNode = nodes.last else { return nil }
            let penultimateMarkerNode = nodes[nodes.count-2]
            
            nodeA = lastMarkerNode
            nodeB = penultimateMarkerNode
        }
    
        return (nodeA, nodeB)
    }
    
  
    /// Calculates The Distance Between Two SCNNodes
    ///
    /// - Parameter joiningNodes: Bool (Joins The Last Node Added To The First)
    /// - Returns: (distance: Float, nodeA: GLKVector3, nodeB: GLKVector3)
    func calculateDistanceBetweenNodes(joiningNodes: Bool, nodes: [SCNNode]) -> (distance: Float, nodeA: GLKVector3, nodeB: GLKVector3)?{
        
        guard let nodes = positionalNodes(joiningNodes: joiningNodes, nodes: nodes) else { return nil }
        let nodeA = nodes.nodeA
        let nodeB = nodes.nodeB
        
        //3. Convert The SCNVector3 Positions To GLKVector3
        let nodeAVector3 = GLKVector3Make(nodeA.position.x, nodeA.position.y, nodeA.position.z)
        let nodeBVector3 = GLKVector3Make(nodeB.position.x, nodeB.position.y, nodeB.position.z)
        
        //4. Calculate The Distance
        let distance = GLKVector3Distance(nodeAVector3, nodeBVector3)
        let meters = Measurement(value: Double(distance), unit: UnitLength.meters)
        print("Distance Between Markers Nodes = \(String(format: "%.2f", meters.value))m")
        
        //4. Return The Distance A Positions Of The Nodes
        return (distance: distance , nodeA: nodeAVector3, nodeB: nodeBVector3)
        
    }
    
    
    /// Calculates The Final Two Angles Of The Shape Constructed
    ///
    /// - Parameter nodes: [SCNNode]
    /// - Returns: (midNode: SCNNode, angle: Double)?
    func calculateFinalAnglesBetweenNodes(_ nodes: [SCNNode]) -> (midNode: SCNNode, angle: Double)?{
        
        //1. If A Shape With An Even Number Of Markers Has Been Created Then Perform The Following Calculation
        if nodes.count % 2 == 0{

            guard let firstNode = nodes.last,
            let midNode = nodes.first  else { return nil }
            let endNode = nodes[1]
            
            let angle = angleFromVectors(start: SCNVector3ToGLKVector3(firstNode.position),
                                         mid: SCNVector3ToGLKVector3(midNode.position),
                                         end: SCNVector3ToGLKVector3(endNode.position))
            
            return (midNode: midNode, angle: angle)
            
        }else{
        
            //2. A Shape With An Odd Number Of Markers Has Been Created
            guard let firstNode = nodes.last,
            let midNode = nodes.first  else { return nil }
            let endNode = nodes[1]
            
            let angle = angleFromVectors(start: SCNVector3ToGLKVector3(firstNode.position),
                                         mid: SCNVector3ToGLKVector3(midNode.position),
                                         end: SCNVector3ToGLKVector3(endNode.position))
            
            return (midNode: midNode, angle: angle)
        }
       
    }
    
    /// Calculates The Angle Between Three SCNNodes
    ///
    /// - Parameter nodes: [SCNNode]
    /// - Returns: (midNode: SCNNode, angle: Double)?
    func calculateAnglesBetweenNodes(joiningNodes: Bool, nodes: [SCNNode]) -> (midNode: SCNNode, angle: Double)?{
        
        //1. If The User Has Chosen To Join The Markers E.g. Make A Shape Then Get The Angle
        if joiningNodes{
            
            guard let firstNode = nodes.first else { return nil }
            let midNode = nodes[nodes.count-1]
            let endNode = nodes[nodes.count - 2]
            
            let angle = angleFromVectors(start: SCNVector3ToGLKVector3(firstNode.position),
                                         mid: SCNVector3ToGLKVector3(midNode.position),
                                         end: SCNVector3ToGLKVector3(endNode.position))
            
          
         
            //a. Return The Middle Node For Placing An Angle Label & The Angle Itself
            return (midNode: midNode, angle: angle)
          
        }else{
            
            //1. An Angle Can Only Be Calculated If We Have Three Nodes On Screen
            if nodes.count >= 3{
                
                //a. Get The Last Three Nodes From Our NodesAdded Array
                let firstNode = nodes[nodes.count - 3]
                let midNode = nodes[nodes.count-2]
                guard let endNode = nodes.last else { return nil }
                
                //b. Calculate The Angle Between Our Nodes
                let angle = angleFromVectors(start: SCNVector3ToGLKVector3(firstNode.position),
                                             mid: SCNVector3ToGLKVector3(midNode.position),
                                             end: SCNVector3ToGLKVector3(endNode.position))
                
                print("Angle Between Markers Nodes = \(String(format: "%.2f°", angle))")
                
                //c. Return The Middle Node For Placing An Angle Label & The Angle Itself
                return (midNode: midNode, angle: angle)
            }
        }

        return nil
        
    }
    
}

