//
//  TubeSegment.swift
//  Project Tube
//
//  Created by LegACy on 7/7/14.
//  Copyright (c) 2014 Raka Mahesa. All rights reserved.
//

import SceneKit;

class TubeSegment {
	init(tiles: Int[], startOrbit: SCNVector3, endOrbit: SCNVector3, startY: Float, endY: Float, startX: Float, endX: Float) {
		//Save
		m_EndAngleY		= endY;
		m_EndAngleX		= endX;
		m_StartAngleY	= startY;
		m_StartAngleX	= startX;
		m_StartOrbit	= startOrbit;
		m_EndOrbit		= endOrbit;
		
		//Create nodes
		m_Segment		= SCNNode();
		m_SegmentOrbit	= SCNNode();
		m_SegmentOrbit.addChildNode(m_Segment);
		
		//For each tiles
		let Degree: Float = 360.0 / Float(tiles.count);
		for var i = 0; i < tiles.count; i++ {
			//If not empty
			if (tiles[i] > 0) {
				//Create floor
				let Floor		= SCNNode();
				Floor.position	= SCNVector3(x: 2, y: 0, z: 0);
				Floor.geometry	= SCNBox(width: 0.25, height: 1.2, length: CGFloat(SEGMENT_TILE_LENGTH), chamferRadius: 0.02);
				
				//Create material for floor
				Floor.geometry.firstMaterial							= SCNMaterial();
				Floor.geometry.firstMaterial.diffuse.contents			= UIColor(red: 1, green: 0, blue: 0, alpha: 1);
				Floor.geometry.firstMaterial.locksAmbientWithDiffuse	= true;
				
				//Create slice
				let Slice		= SCNNode();
				Slice.rotation	= SCNVector4(x: 0, y: 0, z: 1, w: Float(i) * Degree / 180.0 * Float(M_PI));
				Slice.addChildNode(Floor);
				
				//Add to segment
				m_Segment.addChildNode(Slice);
			}
		}
		
		//Set angle
		let AngleY				= (m_StartAngleY + m_EndAngleY) / 2.0;
		let AngleX				= (m_StartAngleX + m_EndAngleX) / 2.0;
		m_SegmentOrbit.rotation	= SCNVector4(x: 0, y: 1, z: 0, w: AngleY / 180.0 * Float(M_PI));
		
		//Set position
		var OrbitX				= (m_StartOrbit.x + m_EndOrbit.x) / 2.0;
		var OrbitY				= (m_StartOrbit.y + m_EndOrbit.y) / 2.0;
		var OrbitZ				= (m_StartOrbit.z + m_EndOrbit.z) / 2.0;
		m_SegmentOrbit.position	= SCNVector3(x: OrbitX, y: OrbitY, z: OrbitZ);
		m_Segment.position		= SCNVector3(x: SEGMENT_ORBIT_DISTANCE, y: 0, z: 0);
	}
	
	//More specific class constructors
	class func create(tiles: Int[], orbit: SCNVector3, angleY: Float, startX: Float, endX: Float) -> TubeSegment {
		return TubeSegment(tiles: tiles, startOrbit: orbit, endOrbit: orbit, startY: angleY, endY: angleY, startX: startX, endX: endX); }
	class func create(tiles: Int[], orbit: SCNVector3, angleX: Float, startY: Float, endY: Float) -> TubeSegment {
		return TubeSegment(tiles: tiles, startOrbit: orbit, endOrbit: orbit, startY: startY, endY: endY, startX: angleX, endX: angleX); }
	class func create(tiles: Int[], startOrbit: SCNVector3, endOrbit: SCNVector3, angleY: Float, angleX: Float) -> TubeSegment {
		return TubeSegment(tiles: tiles, startOrbit: startOrbit, endOrbit: endOrbit, startY: angleY, endY: angleY, startX: angleX, endX: angleX); }
	
	//Accessors
	func getNode() -> SCNNode			{ return m_SegmentOrbit;	}
	func getEndOrbit() -> SCNVector3	{ return m_EndOrbit;		}
	func getStartOrbit() -> SCNVector3	{ return m_StartOrbit;		}
	func getStartAngleY() -> Float		{ return m_StartAngleY;		}
	func getStartAngleX() -> Float		{ return m_StartAngleX;		}
	func getEndAngleY() -> Float		{ return m_EndAngleY;		}
	func getEndAngleX() -> Float		{ return m_EndAngleX;		}
	
	func getIntermediateAngle(factor: Float) -> SCNVector3 {
		//Calculate angle
		let AngleY = m_StartAngleY + (factor * (m_EndAngleY - m_StartAngleY));
		let AngleX = m_StartAngleX + (factor * (m_EndAngleX - m_StartAngleX));
		
		//Return
		return SCNVector3(x: AngleX, y: AngleY, z: 0);
	}
	
	func getIntermediatePosition(factor: Float) -> SCNVector3 {
		//Initialize
		var Result	= SCNVector3(x: 0, y: 0, z: 0);
		let Angle	= getIntermediateAngle(factor);
		
		//Based on type
		if (m_StartAngleY != m_EndAngleY) {
			//Calculate position
			let Radian	= Angle.y / 180.0 * Float(M_PI);
			let X		= m_StartOrbit.x + (cosf(Radian) * SEGMENT_ORBIT_DISTANCE);
			let Z		= m_StartOrbit.z + (-sinf(Radian) * SEGMENT_ORBIT_DISTANCE);
			Result		= SCNVector3(x: X, y: 0, z: Z);
		} else if (m_StartAngleX != m_EndAngleX) {
			
		} else {
			//Get intermediate orbit
			let OrbitX = m_StartOrbit.x + ((m_EndOrbit.x - m_StartOrbit.x) * factor);
			let OrbitY = m_StartOrbit.y + ((m_EndOrbit.y - m_StartOrbit.y) * factor);
			let OrbitZ = m_StartOrbit.z + ((m_EndOrbit.z - m_StartOrbit.z) * factor);
			
			//Calculate position
			let Radian	= Angle.y / 180.0 * Float(M_PI);
			let X		= OrbitX + (cosf(Radian) * SEGMENT_ORBIT_DISTANCE);
			let Z		= OrbitZ + (-sinf(Radian) * SEGMENT_ORBIT_DISTANCE);
			Result		= SCNVector3(x: X, y: OrbitY, z: Z);
		}
		
		//Return
		return Result;
	}
	
	func rotate(angle: Float) {
		//Rotate
		m_Segment.rotation = SCNVector4(x: 0, y: 0, z: 1, w: angle);
	}
	
	//Data
	var m_EndAngleY:	Float;
	var m_EndAngleX:	Float;
	var m_StartAngleY:	Float;
	var m_StartAngleX:	Float;
	var m_StartOrbit:	SCNVector3;
	var m_EndOrbit:		SCNVector3;
	
	//Nodes
	var m_Segment:		SCNNode;
	var m_SegmentOrbit: SCNNode;
}

//Public constants
let SEGMENT_TILE_LENGTH: Float		= 2.2;
let SEGMENT_ORBIT_DISTANCE: Float	= 10;

