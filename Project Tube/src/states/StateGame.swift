//
//  StateGame.swift
//  Project Tube
//
//  Created by LegACy on 6/22/14.
//  Copyright (c) 2014 Raka Mahesa. All rights reserved.
//

import SceneKit;
import QuartzCore;

class StateGame {
	init() {
		//Create material for ball
		let BallMaterial						= SCNMaterial();
		BallMaterial.diffuse.contents			= UIImage(named: "texture");
		BallMaterial.locksAmbientWithDiffuse	= true;
		
		//Create animation for ball
		let BallAnimation			= CABasicAnimation(keyPath: "rotation");
		BallAnimation.toValue		= NSValue(SCNVector4: SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI)));
		BallAnimation.repeatCount	= MAXFLOAT;
		BallAnimation.duration		= 1;
		
		//Create ball
		m_Ball							= SCNNode();
		m_Ball.geometry					= SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.5);
		m_Ball.geometry.firstMaterial	= BallMaterial;
		m_Ball.addAnimation(BallAnimation, forKey: nil);
		
		//Create camera
		m_Camera			= SCNNode();
		m_Camera.camera		= SCNCamera();
		m_Camera.rotation	= SCNVector4(x: 1, y: 0, z: 0, w: -15.0 / 180.0 * Float(M_PI));
		
		//Create sun
		let Sun			= SCNNode();
		Sun.light		= SCNLight();
		Sun.light.type	= SCNLightTypeOmni;
		Sun.position	= SCNVector3(x: 200, y: 200, z: -50);
		
		//Create basic lighting
		let AmbientLight			= SCNNode();
		AmbientLight.light			= SCNLight();
		AmbientLight.light.type		= SCNLightTypeAmbient;
		AmbientLight.light.color	= UIColor.darkGrayColor();
		
		//Create and populate scene
		m_Tube	= SCNNode();
		m_Scene = SCNScene();
		m_Scene.rootNode.addChildNode(Sun);
		m_Scene.rootNode.addChildNode(AmbientLight);
		m_Scene.rootNode.addChildNode(m_Camera);
		m_Scene.rootNode.addChildNode(m_Tube);
		m_Scene.rootNode.addChildNode(m_Ball);
		
		//Start
		setup();
	}
	
	func setup() {
		//Initialize
		m_Distance	= 0;
		m_TubeAngle	= 0;
		m_Straight	= 4;
		m_ExitTile	= INITIAL_EXIT;
		
		//Reset object
		var TubeChildren: SCNNode[] = [];
		for Child: AnyObject in m_Tube.childNodes	{ if (Child is SCNNode) { TubeChildren.append(Child as SCNNode); }	}
		for Child in TubeChildren					{ Child.removeFromParentNode();										}
		m_Ball.position	= SCNVector3(x: 0, y: -1.375, z: 0);
		
		//For all segment
		var Z: Float = -0.5;
		for var i = 0; i < SEGMENT_MAX; i++ {
			//Create segment
			generateSegment(m_Tube, z: Z);
			Z -= TILE_LENGTH + SEGMENT_GAP;
		}
		
		//Setup scene
		updateScene();
	}
	
	func getScene() -> SCNScene {
		//Return the state scene
		return m_Scene;
	}
	
	func update(time: Int, touches: TouchInfo[]) {
		//Travel
		let Factor = Float(time) / 1000.0;
		m_Distance += 3.0 * Factor;
		
		//If touched
		if (touches[0].isPressed()) {
			//Change angle
			m_TubeAngle += touches[0].getOffsetX() / 10.0 * Float(M_PI) * Factor;
			m_Tube.rotation = SCNVector4(x: 0, y: 0, z: 1, w: m_TubeAngle);
		}
		
		//Update
		updateScene();
	}
	
	func updateScene() {
		//Set objects position
		m_Ball.position		= SCNVector3(x: m_Ball.position.x, y: m_Ball.position.y, z: -0.5 - m_Distance);
		m_Camera.position	= SCNVector3(x: m_Ball.position.x, y: m_Ball.position.y + 1.5, z: m_Ball.position.z + 2.5);
		
		//Check segment
		let Segment : SCNNode = m_Tube.childNodes[0] as SCNNode;
		if (Segment.position.z - TILE_LENGTH >= -m_Distance) {
			//Remove and generate
			Segment.removeFromParentNode();
			generateSegment(m_Tube, z: Segment.position.z - (Float(SEGMENT_MAX) * (TILE_LENGTH + SEGMENT_GAP)));
		}
	}
	
	func generateSegment(tube: SCNNode, z: Float) {
		//Initialize tiles
		var Tiles: Int[] = [];
		for var i = 0; i < TUBE_SLICES; i++ { Tiles.append(0); }
		Tiles[m_ExitTile] = 1;
		
		//if straight, do nothing
		if (m_Straight > 0) { m_Straight--; }
		else {
			//Determine new data
			var Offset = 0;
			while Offset == 0 { Offset = Int(arc4random_uniform(UInt32(TUBE_SLICES / 2))) - (TUBE_SLICES / 4); }
			m_Straight = 1 + Int(arc4random_uniform(2));
			
			//While there's offset
			while Offset != 0 {
				//Change tile
				m_ExitTile += Offset > 0 ? 1 : -1;
				if (m_ExitTile >= TUBE_SLICES)	{ m_ExitTile -= TUBE_SLICES; }
				else if (m_ExitTile < 0)		{ m_ExitTile += TUBE_SLICES; }
				
				//Put tile
				Tiles[m_ExitTile] = 1;
				
				//Next
				Offset += Offset > 0 ? -1 : 1;
			}
		}
		
		//Create segment
		let Segment			= SCNNode();
		Segment.position	= SCNVector3(x:  0, y: 0, z: z);
		
		//For each tile
		for var i = 0; i < Tiles.count; i++ {
			//If not empty
			if (Tiles[i] > 0) {
				//Create floor
				let Floor		= SCNNode();
				Floor.position	= SCNVector3(x:  2, y: 0, z: 0);
				Floor.geometry	= SCNBox(width: 0.25, height: 1.2, length: TILE_LENGTH, chamferRadius: 0.02);
				
				//Create material for floor
				Floor.geometry.firstMaterial							= SCNMaterial();
				Floor.geometry.firstMaterial.diffuse.contents			= UIColor(red: 1, green: 0, blue: 0, alpha: 1);
				Floor.geometry.firstMaterial.locksAmbientWithDiffuse	= true;
				
				//Create slice
				let Slice		= SCNNode();
				Slice.rotation	= SCNVector4(x: 0, y: 0, z: 1, w: Float(i) * 30.0 / 180.0 * Float(M_PI));
				Slice.addChildNode(Floor);
				
				//Add to segment
				Segment.addChildNode(Slice);
			}
		}
		
		//Attach
		tube.addChildNode(Segment);
	}
	
	//Constants
	let TILE_LENGTH: Float	= 1.5;
	let SEGMENT_GAP: Float	= 0.1;
	let INITIAL_EXIT: Int	= 9;
	let TUBE_SLICES: Int	= 12;
	let SEGMENT_MAX: Int	= 12;
	
	//Data
	var m_Straight: Int		= 0;
	var m_ExitTile: Int		= 0;
	var m_Distance: Float	= 0;
	var m_TubeAngle: Float	= 0;
	
	//Scene objects
	var m_Ball:		SCNNode;
	var m_Tube:		SCNNode;
	var m_Camera:	SCNNode;
	var m_Scene:	SCNScene;
}
