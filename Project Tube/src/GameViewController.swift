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
		m_State			= StateGame();
		m_Touches		= [ TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo(), TouchInfo() ];
		let GameView	= self.view as SCNView;
		
		//Configure scene view
		GameView.scene					= m_State!.getScene();
		GameView.backgroundColor		= UIColor.cyanColor();
		GameView.multipleTouchEnabled	= true;
		GameView.showsStatistics		= true;
		GameView.delegate				= self;
        
        //Add touch handler
		/*let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:");
		let gestureRecognizers = NSMutableArray();
		gestureRecognizers.addObject(tapGesture);
		gestureRecognizers.addObjectsFromArray(GameView.gestureRecognizers);
		GameView.gestureRecognizers = gestureRecognizers;*/
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
	
	func findTouchInfo(touch:UITouch, save:Bool = false) -> TouchInfo? {
		//Initialize
		var Result: TouchInfo? = nil;
		
		//If exist
		if (touch != nil) {
			//Get touch info
			Result = m_UITouches[touch];
			if (Result == nil) {
				//For all info
				for Info in m_Touches {
					//If no result
					if (Result == nil) {
						//Check if current info is recording other touch
						var Found = false;
						for Saved in m_UITouches.values {
							//If the same, than current info is already used
							if (Found == false && Info === Saved) { Found = true; }
						}
						
						//If not found
						if (!Found) {
							//Save
							Result = Info;
							if (save) { m_UITouches[touch] = Result; }
						}
					}
				}
			}
		}
		
		//Return
		return Result;
	}
	
	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
		//For each touch
		let Touches: AnyObject[] = touches.allObjects;
		for Touch in Touches as UITouch[] {
			//Get touch info
			let Info = findTouchInfo(Touch, save: true);
			if (Info != nil) {
				//Press
				let Location = Touch.locationInView(self.view);
				Info!.pressed(Location.x, y: Location.y);
			}
		}
	}
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		//For each touch
		let Touches: AnyObject[] = touches.allObjects;
		for Touch in Touches as UITouch[] {
			//Get touch info
			let Info = findTouchInfo(Touch);
			if (Info != nil) {
				//Move
				let Location = Touch.locationInView(self.view);
				Info!.dragged(Location.x, y: Location.y);
			}
		}
	}
	
	override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
		//For each touch
		let Touches: AnyObject[] = touches.allObjects;
		for Touch in Touches as UITouch[] {
			//Get touch info
			let Info = findTouchInfo(Touch);
			if (Info != nil) {
				//Release
				let Location = Touch.locationInView(self.view);
				Info!.released(Location.x, y: Location.y);
				
				//Remove
				m_UITouches.removeValueForKey(Touch);
			}
		}
	}
	
	override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
		//End
		touchesEnded(touches, withEvent: event);
	}
	
	func renderer(renderer:SCNSceneRenderer, updateAtTime current:NSTimeInterval) {
		//If there's a previous frame
		if (m_LastTime >= 0) {
			//Update with delta
			let Delta = (Int)((current - m_LastTime) * 1000.0);
			m_State!.update(Delta, touches: m_Touches);
		}
		
		//For all touch
		for Touch in m_Touches {
			//Manage touches
			if (!Touch.isPressed() && Touch.wasPressed())		{ Touch.removed();											}
			else if (Touch.isPressed() && !Touch.wasPressed())	{ Touch.dragged(Touch.getStartX(), y: Touch.getStartY());	}
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
	var m_State: StateGame?							= nil;
	var m_Touches: TouchInfo[]						= [];
	var m_UITouches: Dictionary<UITouch, TouchInfo>	= [:];
	var m_LastTime: NSTimeInterval					= -1;
}
