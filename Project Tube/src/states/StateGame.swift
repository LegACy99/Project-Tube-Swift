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
		BallAnimation.duration		= 2.67;
		
		//Create ball
		m_Ball							= SCNNode();
		m_Ball.position					= SCNVector3(x: 0, y: 0.5, z: 0.5);
		m_Ball.geometry					= SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.5);
		m_Ball.geometry.firstMaterial	= BallMaterial;
		m_Ball.addAnimation(BallAnimation, forKey: nil);
		
		//Create camera
		m_Camera			= SCNNode();
		m_Camera.camera		= SCNCamera();
		m_Camera.position	= SCNVector3(x: 0, y: 0.75, z: 5);
		
		//Create floors
		let Floor1		= SCNNode();
		let Floor2		= SCNNode();
		let Floor3		= SCNNode();
		Floor1.position	= SCNVector3(x: 0.05, y: 0, z: -1);
		Floor2.position	= SCNVector3(x: -0.05, y: 0, z: -3.1);
		Floor3.position	= SCNVector3(x: 0, y: 0, z: -5.2);
		Floor1.geometry	= SCNBox(width: 1, height: 0.25, length: 2, chamferRadius: 0.02);
		Floor2.geometry	= Floor1.geometry;
		Floor3.geometry	= Floor1.geometry;
		
		//Create material for floors
		Floor1.geometry.firstMaterial							= SCNMaterial();
		Floor1.geometry.firstMaterial.diffuse.contents			= UIColor.redColor();
		Floor1.geometry.firstMaterial.locksAmbientWithDiffuse	= true;
		
		//Create tube
		m_Tube = SCNNode();
		m_Tube.addChildNode(Floor1);
		m_Tube.addChildNode(Floor2);
		m_Tube.addChildNode(Floor3);
		m_Tube.position = SCNVector3(x: 0, y: -0.125, z: 0);
		
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
		m_Distance = 0;
		
		//Setup scene
		updateScene();
	}
	
	func getScene() -> SCNScene {
		//Return the state scene
		return m_Scene;
	}
	
	func update(time: Int) {
		//Travel
		m_Distance += 1 * Float(time) / 1000.0;
		
		//Update
		updateScene();
	}
	
	func updateScene() {
		//Set objects position
		m_Ball.position		= SCNVector3(x: m_Ball.position.x, y: m_Ball.position.y, z: -0.5 - m_Distance);
		m_Camera.position	= SCNVector3(x: m_Ball.position.x, y: m_Ball.position.y + 1.5, z: m_Ball.position.z + 4);
		
		//Check floor
		let Floor : SCNNode = m_Tube.childNodes[0] as SCNNode;
		if (Floor.position.z - 1 >= -m_Distance) {
			//Set new position
			Floor.position = SCNVector3(x: Floor.position.x, y: Floor.position.y, z: Floor.position.z - 6.3);
			
			//Readd
			Floor.removeFromParentNode();
			m_Tube.addChildNode(Floor);
		}
	}
	
	//Data
	var m_Distance: Float = 0;
	
	//Scene objects
	var m_Ball:		SCNNode;
	var m_Tube:		SCNNode;
	var m_Camera:	SCNNode;
	var m_Scene:	SCNScene;
}
