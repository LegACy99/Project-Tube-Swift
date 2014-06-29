//
//  TouchInfo.swift
//  Project Tube
//
//  Created by LegACy on 6/24/14.
//  Copyright (c) 2014 Raka Mahesa. All rights reserved.
//

class TouchInfo {
	init() {
		//Reset
		reset();
	}
	
	func reset() {
		//Reset data
		m_X			= -1;
		m_Y			= -1;
		m_LastX		= -1;
		m_LastY		= -1;
		m_StartX	= -1;
		m_StartY	= -1;
		
		//Reset state
		m_Pressed		= false;
		m_WasPressed	= false;
	}
	
	//Getters
	func isPressed() -> Bool	{ return m_Pressed;		}
	func wasPressed() -> Bool	{ return m_WasPressed;	}
	func getStartX() -> Float	{ return m_StartX;		}
	func getStartY() -> Float	{ return m_StartY;		}
	func getCurrentX() -> Float { return m_X;			}
	func getCurrentY() -> Float { return m_Y;			}
	
	func getOffsetX() -> Float {
		//Get offset
		var Offset 	= m_X - m_LastX;
		m_LastX		= m_X;
		
		//Return
		return Offset;
	}
	
	func getOffsetY() -> Float {
		//Get offset
		var Offset 	= m_Y - m_LastY;
		m_LastY		= m_Y;
		
		//Return
		return Offset;
	}
	
	func pressed(x:Float, y:Float) {
		//Skip if already pressed
		if (m_Pressed) { return; }
		
		//Set data
		m_X	= x;
		m_Y	= y;
		
		//Set other data
		m_LastX		= m_X;
		m_LastY		= m_Y;
		m_StartX 	= m_X;
		m_StartY 	= m_Y;
		
		//Pressed
		m_Pressed = true;
	}
	
	func dragged(x:Float, y:Float) {
		//Skip if not pressed
		if (!m_Pressed) { return };
		
		//Was pressed
		m_WasPressed = true;
		
		//Set current position
		m_X	= x;
		m_Y	= y;
	}
	
	func released(x:Float, y:Float) {
		//Skip if not pressed
		if (!m_Pressed) { return };
		
		//Set current position
		m_X	= x;
		m_Y	= y;
		
		//Released
		m_Pressed = false;
	}
	
	func removed() {
		//Remove
		if (m_Pressed) { m_Pressed = false; }
		m_WasPressed = false;
	}
	
	//Properties
	var m_X:		Float = 0;
	var m_Y:		Float = 0;
	var m_LastX:	Float = 0;
	var m_LastY:	Float = 0;
	var m_StartX:	Float = 0;
	var m_StartY:	Float = 0;
	
	//State
	var m_Pressed:		Bool = false;
	var m_WasPressed:	Bool = false;
}
