//
//  GameViewController.swift
//  Project Tube
//
//  Created by LegACy on 6/22/14.
//  Copyright (c) 2014 Raka Mahesa. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    override func viewDidLoad() {
		//Super
        super.viewDidLoad()
		
		//Initialize
		m_State		= StateGame();
		let GameView	= self.view as SCNView;
		
		//Configure scene view
		GameView.scene					= m_State!.getScene();
		GameView.backgroundColor		= UIColor.cyanColor();
		GameView.showsStatistics		= true;
		GameView.allowsCameraControl	= true;
		GameView.delegate				= self;
        
        //Add touch handler
		let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:");
		let gestureRecognizers = NSMutableArray();
		gestureRecognizers.addObject(tapGesture);
		gestureRecognizers.addObjectsFromArray(GameView.gestureRecognizers);
		GameView.gestureRecognizers = gestureRecognizers;
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.locationInView(scnView)
        let hitResults = scnView.hitTest(p, options: nil)
        
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject! = hitResults[0]
            
            // get its material
            let material = result.node!.geometry.firstMaterial
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
	
	func renderer(renderer:SCNSceneRenderer, updateAtTime current:NSTimeInterval) {
		//If there's a previous frame
		if (m_LastTime >= 0) {
			//Update with delta
			let Delta = (Int)((current - m_LastTime) * 1000.0);
			m_State!.update(Delta);
			
		}
		
		//Save time
		m_LastTime = current;
	}
    
    override func shouldAutorotate() -> Bool {
        return true
    }
	
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
	
	//Class member
	var m_State: StateGame?			= nil;
	var m_LastTime: NSTimeInterval	= -1;
}
