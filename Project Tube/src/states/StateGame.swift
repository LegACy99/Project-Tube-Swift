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
		m_Tiles				= 0;
		m_TileTime			= 0;
		m_Distance			= 0;
		m_Straight			= 4;
		m_Direction			= -1;
		m_TubeAngle			= 0;
		m_OrbitAngleX		= 0;
		m_OrbitAngleY		= 0;
		m_OrbitPosition		= SCNVector3(x: 0, y: 0, z: 0);
		m_ExitTile			= INITIAL_EXIT;
		
		m_Ball.position	= SCNVector3(x: m_OrbitPosition.x + SEGMENT_ORBIT_DISTANCE, y: m_OrbitPosition.y - 1.5, z:m_OrbitPosition.z );
		
		//Clear arrays
		for Segment in m_Segments { Segment.getNode().removeFromParentNode(); }
		m_Segments = [];
		
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
			for Segment in m_Segments { Segment.rotate(m_TubeAngle); }
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
		
		//Set ball position
		let Node		= m_Segments[1];
		let Factor		= Float(m_TileTime) / 500.0;
		let Position	= Node.getIntermediatePosition(Factor);
		m_Ball.position	= SCNVector3(x: Position.x, y: m_Ball.position.y, z: Position.z);
		
		//Set camera rotation
		let Angle			= Node.getIntermediateAngle(Factor).y / 180.0 * Float(M_PI);
		let XRotation		= SCNMatrix4MakeRotation(-15.0 / 180.0 * Float(M_PI), 1, 0, 0);
		let YRotation		= SCNMatrix4MakeRotation(Angle, 0, 1, 0);
		m_Camera.transform	= SCNMatrix4Mult(XRotation, YRotation);
		
		//Set camera position
		let CameraDistance:Float	= 2.5;
		let CameraX: Float			= -cosf(Angle + Float(M_PI_2)) * CameraDistance;
		let CameraZ: Float			= sinf(Angle + Float(M_PI_2)) * CameraDistance;
		m_Camera.position			= SCNVector3(x: m_Ball.position.x + CameraX, y: m_Ball.position.y + 1.5, z: m_Ball.position.z + CameraZ);
	}
	
	func prepareDirection() {
		//Set direction
		m_Direction = Int(arc4random_uniform(2));
		m_Tiles		= 4 + Int(arc4random_uniform(3) * 2);
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
		
		//If tiles been used up, set new direction
		if (m_Tiles <= 0) { prepareDirection(); }
		m_Tiles--;
		
		//Check direction
		var Segment: TubeSegment? = nil;
		if (m_Direction == DIRECTION_STRAIGHT) {
			//Save current orbit
			let Previous = m_OrbitPosition;
			
			//Increase orbit
			let Angle			= (m_OrbitAngleY + 90.0) / 180.0 * Float(M_PI);
			let OffsetX: CFloat	= cosf(Angle) * SEGMENT_TILE_LENGTH;
			let OffsetY: CFloat	= 0;
			let OffsetZ: CFloat	= -sinf(Angle) * SEGMENT_TILE_LENGTH;
			m_OrbitPosition		= SCNVector3(x: m_OrbitPosition.x + OffsetX, y: m_OrbitPosition.y + OffsetY, z: m_OrbitPosition.z + OffsetZ);
			
			//Create segment
			Segment	= TubeSegment.create(Tiles, startOrbit: Previous, endOrbit: m_OrbitPosition, angleY: m_OrbitAngleY, angleX: m_OrbitAngleX);
		} else if (m_Direction == DIRECTION_LEFT || m_Direction == DIRECTION_RIGHT) {
			//Increase angle
			var Previous	 = m_OrbitAngleY;
			m_OrbitAngleY	+= SEGMENT_ANGLE;
			if (m_OrbitAngleY > 360) {
				//Reset
				Previous		-= 360;
				m_OrbitAngleY	-= 360;
			}
			
			//Create segment
			Segment	= TubeSegment.create(Tiles, orbit: m_OrbitPosition, angleX: m_OrbitAngleX, startY: Previous, endY: m_OrbitAngleY);
		}
		
		//If segment is created
		if (Segment != nil) {
			//Rotate
			Segment!.rotate(m_TubeAngle);
			
			//Attach
			tube.addChildNode(Segment!.getNode());
			m_Segments.append(Segment!);
		}
	}
	
	//Constants
	let DIRECTION_UP: Int		= 3;
	let DIRECTION_DOWN: Int		= 4
	let DIRECTION_LEFT: Int		= 1;
	let DIRECTION_RIGHT: Int	= 2;
	let DIRECTION_STRAIGHT: Int	= 0;
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
	
	//Tube data
	var m_Tiles: Int				= 0;
	var m_Direction: Int			= 0;
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
