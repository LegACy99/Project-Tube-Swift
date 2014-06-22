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
		//Initialize
		m_Tube = SCNNode();
		
		//Create material for ball
		let BallMaterial						= SCNMaterial();
		BallMaterial.diffuse.contents			= UIImage(named: "texture");
		BallMaterial.locksAmbientWithDiffuse	= true;
		
		//Create animation for ball
		let BallAnimation			= CABasicAnimation(keyPath: "rotation");
		BallAnimation.toValue		= NSValue(SCNVector4: SCNVector4(x: 1, y: 0, z: 0, w: Float(-M_PI)));
		BallAnimation.repeatCount	= MAXFLOAT;
		BallAnimation.duration		= 3;
		
		//Create ball
		m_Ball							= SCNNode();
		m_Ball.geometry					= SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.5);
		m_Ball.geometry.firstMaterial	= BallMaterial;
		m_Ball.addAnimation(BallAnimation, forKey: nil);
		
		//Create camera
		m_Camera			= SCNNode();
		m_Camera.camera		= SCNCamera();
		m_Camera.position	= SCNVector3(x: 0, y: 0, z: 3)
		
		// create and add a light to the scene
		let Sun			= SCNNode();
		Sun.light		= SCNLight();
		Sun.light.type	= SCNLightTypeOmni;
		Sun.position	= SCNVector3(x: 200, y: 200, z: 200);
		
		// create and add an ambient light to the scene
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
	}
	
	func getScene() -> SCNScene {
		//Return the state scene
		return m_Scene;
	}
	
	func update(time: Int) {
		//Move the ball
		m_Ball.position = SCNVector3(x: m_Ball.position.x, y: m_Ball.position.y, z: m_Ball.position.z + (0.5 * Float(time) / -1000.0));
	}
	
	//Class members
	var m_Ball:		SCNNode;
	var m_Tube:		SCNNode;
	var m_Camera:	SCNNode;
	var m_Scene:	SCNScene;
}
