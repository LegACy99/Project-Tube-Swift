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
		m_Distance			= 0;
		m_TubeAngle			= 0;
		m_FloorAngle		= 270;
		m_FloorTargetAngle	= 0;
		m_FloorStraight		= 0;
		
		//Reset object
		var TubeChildren: SCNNode[] = [];
		for Child: AnyObject in m_Tube.childNodes	{ if (Child is SCNNode) { TubeChildren.append(Child as SCNNode); }	}
		for Child in TubeChildren					{ Child.removeFromParentNode();										}
		m_Ball.position	= SCNVector3(x: 0, y: -1.375, z: 0);
		
		//For all segment
		var Z: Float = 0;
		for var i = 0; i < SEGMENT_MAX; i++ {
			//Create segment
			let Segment			= createTubeSegment();
			Segment.position	= SCNVector3(x:  0, y: 0, z: Z - 0.5);
			m_Tube.addChildNode(Segment);
			
			//Next
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
			//Two finger?
			if (touches[1].isPressed()) {
				//Calculate angle
				let Offset	= touches[1].getCurrentY() - touches[1].getStartY();
				let Angle	= m_Camera.rotation.w - (Offset / 10000.0 * Float(M_PI));
				
				//Update
				//m_Camera.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Angle);
			} else {
				//Get offset
				/*let Offset = touches[0].getCurrentY() - touches[0].getStartY();
				
				//Calculate position
				var CameraY = m_Camera.position.y;
				var CameraZ = m_Camera.position.z;
				if (touches[0].getStartX() > 240)	{ CameraY -= Offset / 1000.0; }
				else								{ CameraZ += Offset / 1000.0; }
				
				//Update
				m_Camera.position = SCNVector3(x: 0, y: CameraY, z: CameraZ);*/
				
				//Change angle
				m_TubeAngle += touches[0].getOffsetX() / 10.0 * Float(M_PI) * Factor;
				m_Tube.rotation = SCNVector4(x: 0, y: 0, z: 1, w: m_TubeAngle);
			}
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
			//Configure angle
			/*m_FloorAngle -= 8.0;
			if (m_FloorAngle < 0)			{ m_FloorAngle += 360.0; }
			else if (m_FloorAngle > 360)	{ m_FloorAngle -= 360.0; }*/
			
			//Remove
			Segment.removeFromParentNode();
			
			//Create new segment
			let NewSegment		= createTubeSegment();
			NewSegment.position	= SCNVector3(x:  0, y: 0, z: Segment.position.z - (Float(SEGMENT_MAX) * (TILE_LENGTH + SEGMENT_GAP)));
			m_Tube.addChildNode(NewSegment);
		}
	}
	
	func createTubeSegment() -> SCNNode {
		//Create segment
		let Segment = SCNNode();
		for var angle = 0; angle < 360; angle += 30 {
			//Check if empty or not
			let Chance = Int(arc4random_uniform(6));
			if (Chance > 0) {
				//Create floor
				let Floor		= SCNNode();
				Floor.position	= SCNVector3(x:  2, y: 0, z: 0);
				Floor.geometry	= SCNBox(width: Chance == 1 ? 1.25 : 0.25, height: 1.2, length: TILE_LENGTH, chamferRadius: 0.02);
				
				//Create material for floor
				Floor.geometry.firstMaterial							= SCNMaterial();
				Floor.geometry.firstMaterial.diffuse.contents			= UIColor(red: 1, green: Chance == 1 ? 0.25 : 0, blue: Chance == 1 ? 0.25 : 0, alpha: 1);
				Floor.geometry.firstMaterial.locksAmbientWithDiffuse	= true;
				
				//Create slice
				let Slice		= SCNNode();
				Slice.rotation	= SCNVector4(x: 0, y: 0, z: 1, w: Float(angle) / 180.0 * Float(M_PI));
				Slice.addChildNode(Floor);
				
				//Add to segment
				Segment.addChildNode(Slice);
			}
		}
		
		//Return
		return Segment;
	}
	
	//Constants
	let TILE_LENGTH: Float	= 2;
	let SEGMENT_GAP: Float	= 0.1;
	let SEGMENT_MAX: Int	= 8;
	
	//Data
	var m_Distance: Float			= 0;
	var m_TubeAngle: Float			= 0;
	var m_FloorAngle: Float			= 0;
	var m_FloorTargetAngle: Float	= 0;
	var m_FloorStraight: Float		= 0;
	
	//Scene objects
	var m_Ball:		SCNNode;
	var m_Tube:		SCNNode;
	var m_Camera:	SCNNode;
	var m_Scene:	SCNScene;
}
