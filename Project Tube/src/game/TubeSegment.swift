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
				Floor.geometry	= SCNBox(width: 0.25, height: 1.2, length: CGFloat(TILE_LENGTH), chamferRadius: 0.02);
				
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
		
		//Create orbit
		//m_SegmentOrbit.position		= SCNVector3(x: -ORBIT_RADIUS, y: 0, z: 0);
		//m_SegmentOrbit.rotation		= SCNVector4(x: 0, y: 1, z: 0, w: m_OrbitAngleY / 180.0 * Float(M_PI));
		
		//Add segment to its orbit
		//m_Segment.position	= SCNVector3(x: -m_SegmentOrbit.position.x, y: 0, z: 0);
		//m_Segment.rotation	= SCNVector4(x: 0, y: 0, z: 1, w: m_TubeAngle);
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
	func getSegment() -> SCNNode		{ return m_Segment;			}
	func getEndOrbit() -> SCNVector3	{ return m_EndOrbit;		}
	func getStartOrbit() -> SCNVector3	{ return m_StartOrbit;		}
	func getStartAngleY() -> Float		{ return m_StartAngleY;		}
	func getStartAngleX() -> Float		{ return m_StartAngleX;		}
	func getEndAngleY() -> Float		{ return m_EndAngleY;		}
	func getEndAngleX() -> Float		{ return m_EndAngleX;		}
	
	//Constants
	let TILE_LENGTH: Float = 2.2;
	
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