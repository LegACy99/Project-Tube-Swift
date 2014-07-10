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
		m_TileTime			= 0;
		m_Distance			= 0;
		m_Straight			= 4;
		m_TubeAngle			= 0;
		m_BallAngleY		= 0;
		m_OrbitAngleX		= 0;
		m_OrbitAngleY		= 0;
		m_OrbitPosition		= SCNVector3(x: -ORBIT_RADIUS, y: 0, z: 0);
		m_ExitTile			= INITIAL_EXIT;
		
		//Clear arrays
		for Segment in m_Segments { Segment.getNode().removeFromParentNode(); }
		m_Segments = [];
		
		//Reset object
		m_Ball.position	= SCNVector3(x: m_OrbitPosition.x + ORBIT_RADIUS, y: m_OrbitPosition.y - 1.375, z:m_OrbitPosition.z );
		
		//Set up scene
		for var i = 0; i < SEGMENT_MAX; i++ { generateSegment(m_Tube); }
		updateScene();
	}
	
	func getScene() -> SCNScene {
		//Return the state scene
		return m_Scene;
	}
	
	func update(time: Int, touches: TouchInfo[]) {
		//Update time
		m_TileTime += time;
		let Factor = Float(time) / 1000.0;
		
		/*m_BallAngleY += Factor * 24.0;
		if (m_BallAngleY > 360.0) { m_BallAngleY -= 360; }
		//m_Distance += 3.0 * Factor;*/
		
		//If touched
		if (touches[0].isPressed()) {
			//Change angle
			m_TubeAngle += touches[0].getOffsetX() / 10.0 * Float(M_PI) * Factor;
			for Segment in m_Segments { Segment.getSegment().rotation = SCNVector4(x: 0, y: 0, z: 1, w: m_TubeAngle); }
		}
		
		//Update objects
		updateScene();
	}
	
	func updateScene() {
		//Check time
		if (m_TileTime >= 500) {
			//Reset time
			m_TileTime -= 500;
			
			//Remove 
			m_Segments[0].getNode().removeFromParentNode();
			m_Segments.removeAtIndex(0);
			generateSegment(m_Tube);
		}
		
		//Get angle
		let AngleOffset: Float	= m_Segments[0].getEndAngleY() - m_Segments[0].getStartAngleY();
		m_BallAngleY			= m_Segments[0].getStartAngleY() + (Float(m_TileTime) / 500.0 * AngleOffset);
		
		//Update ball position
		let Orbit		= m_Segments[0].getStartOrbit();
		let Angle		= m_BallAngleY / 180.0 * Float(M_PI);
		m_Ball.position	= SCNVector3(x: Orbit.x + (cosf(Angle) * ORBIT_RADIUS), y: Orbit.y, z: Orbit.z + (-sinf(Angle) * ORBIT_RADIUS));
		
		//Set camera rotation
		let YRotation		= SCNMatrix4MakeRotation(Angle, 0, 1, 0);
		let XRotation		= SCNMatrix4MakeRotation(-15.0 / 180.0 * Float(M_PI), 1, 0, 0);
		m_Camera.transform	= SCNMatrix4Mult(XRotation, YRotation);
		
		//Set camera position
		let CameraDistance:Float	= 2.5;
		let CameraX: Float			= -cosf(Angle + Float(M_PI_2)) * CameraDistance;
		let CameraZ: Float			= sinf(Angle + Float(M_PI_2)) * CameraDistance;
		m_Camera.position			= SCNVector3(x: m_Ball.position.x + CameraX, y: m_Ball.position.y + 1.5, z: m_Ball.position.z + CameraZ);
	}
	
	func generateSegment(tube: SCNNode) {
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
		
		//Set angle
		var End		= m_OrbitAngleY + (SEGMENT_ANGLE / 2);
		var Start	= m_OrbitAngleY - (SEGMENT_ANGLE / 2);
		if (End > 360) {
			//Reset to negative
			Start -= 360;
			End -= 360;
		}
		
		//Create segment
		let Segment2					= TubeSegment.create(Tiles, orbit: m_OrbitPosition, angleX: m_OrbitAngleX, startY: Start, endY: End);
		Segment2.getNode().rotation		= SCNVector4(x: 0, y: 1, z: 0, w: m_OrbitAngleY / 180.0 * Float(M_PI));
		Segment2.getNode().position		= SCNVector3(x: -ORBIT_RADIUS, y: 0, z: 0);
		Segment2.getSegment().position	= SCNVector3(x: -Segment2.getNode().position.x, y: 0, z: 0);
		Segment2.getSegment().rotation	= SCNVector4(x: 0, y: 0, z: 1, w: m_TubeAngle);
		
		//Save
		m_Segments.append(Segment2);
		tube.addChildNode(Segment2.getNode());
		
		//Increase angle
		m_OrbitAngleY += SEGMENT_ANGLE;
		if (m_OrbitAngleY > 360) { m_OrbitAngleY -= 360; }
	}
	
	//Constants
	let ORBIT_RADIUS: Float		= 10;
	let SEGMENT_ANGLE: Float	= 12.0;
	let INITIAL_EXIT: Int		= 9;
	let TUBE_SLICES: Int		= 12;
	let SEGMENT_MAX: Int		= 12;
	
	//Data
	var m_Straight: Int		= 0;
	var m_ExitTile: Int		= 0;
	var m_TileTime: Int		= 0;
	var m_Distance: Float	= 0;
	var m_TubeAngle: Float	= 0;
	var m_BallAngleY: Float	= 0;
	
	//Tube data
	var m_OrbitAngleY: Float		= 0;
	var m_OrbitAngleX: Float		= 0;
	var m_OrbitPosition: SCNVector3	= SCNVector3(x: 0, y: 0, z: 0);
	var m_Segments: TubeSegment[]	= [];
	
	//Scene objects
	var m_Ball:		SCNNode;
	var m_Tube:		SCNNode;
	var m_Camera:	SCNNode;
	var m_Scene:	SCNScene;
}
