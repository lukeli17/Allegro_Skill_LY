;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	skill load "o:\\Sripts\\align\\align_utils.il"

;
; Get the point snapped to the nearest grid (if snapToGrid mode is true).
;
defun( alnGriddedPoint (point grids)
	let( (xOrigin yOrigin xMajor yMajor pointX pointY)
when( (axlIsDebug) printf("alnGriddedPoint\n"))
		pointX = xCoord(point)
		pointY = yCoord(point)
		when( (axlVersion('version) >= 15.7) ; since 15.7
			if( _alnFormData->snapToGrid then
				xMajor = grids->xMajor
				yMajor = grids->yMajor
				xOrigin = grids->xOrigin
				yOrigin = grids->yOrigin

				pointX = round(pointX/xMajor)*xMajor + xOrigin
				pointY = round(pointY/yMajor)*yMajor + yOrigin
			)
		)
		list(pointX pointY) ;return
	)
);defun

;
; Get the current grid.
;
defun( alnGetCurrentGrid (selectedObjects)
	prog( (grids isMirrored)
		when( (axlVersion('version) >= 15.7) ; since 15.7
			case( car(selectedObjects)->objType
				( ("group" "symbol" "pin" "via") ; use etch grid
					isMirrored = car(selectedObjects)->isMirrored
					foreach( item _alnSelectedObjects
						if( isMirrored == item->isMirrored
						then isMirrored = item->isMirrored
						else return(axlDBGridGet(axlConductorTopLayer())) ;both layers, use TOP
						)
					)
					if( isMirrored
					then return(axlDBGridGet(axlConductorBottomLayer())) ; mirrored, use BOT
					else return(axlDBGridGet(axlConductorTopLayer()))	; non mirrores, use TOP
					)
				)
				( "text"	;use non-etch grid
					grids = axlDBGridGet("non-etch")
				)
			)
		)
		return(grids)
	)
);defun

;
; Get maximum X coordinate from list of objects
;
defun( alnMaxX (lObjects)
	let( (obj pointX result)
		result = -1000000.0
		foreach( obj lObjects
			pointX = xCoord(alnGetObjectLocation(obj))
			result = max(pointX result)
		)
		result
	)
);defun

;
; Get minimum X coordinate from list of objects
;
defun( alnMinX (lObjects)
	let( (obj pointX result)
		result = 1000000.0
		foreach( obj lObjects
			pointX = xCoord(alnGetObjectLocation(obj))
			result = min(pointX result)
		)
		result
	)
);defun

;
; Get maximum Y coordinate from list of objects
;
defun( alnMaxY (lObjects)
	let( (obj pointY result)
		result = -1000000.0
		foreach( obj lObjects
			pointY = yCoord(alnGetObjectLocation(obj))
			result = max(pointY result)
		)
		result
	)
);defun

;
; Get minimum Y coordinate from list of objects
;
defun( alnMinY (lObjects)
	let( (obj pointY result)
		result = 1000000.0
		foreach( obj lObjects
			pointY = yCoord(alnGetObjectLocation(obj))
			result = min(pointY result)
		)
		result
	)
);defun

;
; Sort list of objects by X coordinate, ascending order.
;
defun( alnOrderByX (objectList)
	sort( objectList 'alnComparePositionX )
);defun
defun( alnComparePositionX ( obj1 obj2 )
	let( ( pt1x pt2x pt1y pt2y pt1 pt2 result)
		pt1 = alnGetObjectLocation(obj1)
		pt2 = alnGetObjectLocation(obj2)
		pt1x = xCoord( pt1 )
		pt2x = xCoord( pt2 )
		if( (pt1x < pt2x)
			then result = t
			else
				if( (pt1x == pt2x)
					then
						; aditionaly compare by Y
						pt1y = yCoord( pt1 )
						pt2y = yCoord( pt2 )
						if( (pt1y < pt2y)
							then result = t
							else result = nil
						)
					else result = nil
				)
		)
		result
	) ; let
) ; defun

;
; Sort list of objects by Y coordinate, ascending order.
;
defun( alnOrderByY (objectList)
	sort( objectList 'alnComparePositionY )
) ;defun
defun( alnComparePositionY ( obj1 obj2 )
	let( ( pt1x pt2x pt1y pt2y pt1 pt2 result)
		pt1 = alnGetObjectLocation(obj1)
		pt2 = alnGetObjectLocation(obj2)
		pt1y = yCoord( pt1 )
		pt2y = yCoord( pt2 )
		if( (pt1y < pt2y)
			then result = t
			else
				if( (pt1y == pt2y)
					then
						; aditionaly compare by X
						pt1x = xCoord( pt1 )
						pt2x = xCoord( pt2 )
						if( (pt1x < pt2x)
							then result = t
							else result = nil
						)
					else result = nil
				)
		)
		result
	) ; let
) ; defun

;
; Get object location point according to selected mode (Origin, Body Center, Pin)
;
defun( alnGetObjectLocation (object)
	let( (result message)
		case( _alnFormData->snapPoint
			( "origin" result = axlDBAltOrigin('origin object) )
			( "center" result = axlDBAltOrigin('center object) )
			( "pin" 
				result = alnGetPinLocation(object _alnFormData->snapPinNumber)
				when( !result 
					message = strcat("WARNING: Pin '", _alnFormData->snapPinNumber, "' not found")
					if( object->refdes 
						then message = strcat(message, " for symbol '", object->refdes, "', got body center.")
						else message = strcat(message, ", got body center.")
					)
					axlMsgPut(message)
					result = axlDBAltOrigin('center object)
				)
			)
		);case
		result
	) ; let
) ; defun+

;
; Get location for given object's pin
; Return nil if pin not found.
defun( alnGetPinLocation (object pinNumber)
	let( (result number)
		pinNumber = upperCase(pinNumber)
		pinList = object->pins
		foreach( pin pinList
			number = pin->number
			number = upperCase(number)
			when( pinNumber == number result = pin->xy)			
		)
		result
	) ; let
) ; defun

;
; Get object boundary box.
; First trying get Dfa_Bound_Top(Bottom)
; if Dfa not present trying Place_Bound_Top(Bottom)
; if Place not present get bBox property.
;
defun( alnGetObjectBBox (object)
	let( ( objectChildren child dfaLayer placeLayer result)
		if(object->isMirrored
			then dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_BOTTOM" placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"
			else dfaLayer = "PACKAGE GEOMETRY/DFA_BOUND_TOP" placeLayer = "PACKAGE GEOMETRY/PLACE_BOUND_TOP"
		)
		objectChildren = object->children
		; only Symbols have objectChildren
		if(objectChildren then
			; find Dfa_Bound_ shape
			foreach( child objectChildren
				if((child->objType == "shape" && child->layer == dfaLayer) then
					result = child->bBox
				)
			)
			; find Place_Bound_ shape
			if(!result then
				foreach( child objectChildren
					if((child->objType == "shape" && child->layer == placeLayer) then
						result = child->bBox
					)
				)
			)
		)
		if(!result then result = object->bBox)
		result
	) ; let
) ; defun

;
; Get objects boundary boxes.
; Return list of boxes.
;
defun( alnGetBBoxes (objectList)
	let( ( object result)
		foreach( object objectList
			result = tconc(result alnGetObjectBBox(object))
		)
		car(result) ; get list from "tconc" list
	) ; let
) ; defun

;
; Get minimal X boundary box coordinate for given BBoxes.
;
defun( alnGetMinBBoxX (boxList)
	let( ( pointX box result)
		result = 1000000.0
		foreach( box boxList
			pointX = xCoord(car(box))
			result = min(pointX result)
		)
		result
	) ; let
) ; defun

;
; Get maximal X boundary box coordinate for given BBoxes.
;
defun( alnGetMaxBBoxX (boxList)
	let( ( pointX box result)
		result = -1000000.0
		foreach( box boxList
			pointX = xCoord(cadr(box))
			result = max(pointX result)
		)
		result
	) ; let
) ; defun

;
; Get minimal Y boundary box coordinate for given BBoxes.
;
defun( alnGetMinBBoxY (boxList)
	let( ( pointY box result)
		result = 1000000.0
		foreach( box boxList
			pointY = yCoord(car(box))
			result = min(pointY result)
		)
		result
	) ; let
) ; defun

;
; Get maximal Y boundary box coordinate for given BBoxes.
;
defun( alnGetMaxBBoxY (boxList)
	let( ( pointY box result)
		result = -1000000.0
		foreach( box boxList
			pointY = yCoord(cadr(box))
			result = max(pointY result)
		)
		result
	) ; let
) ; defun

defun( alnRefreshIDs (objectList)
	let( ( object resultList)
		foreach( object objectList
			resultList = tconc(resultList axlDBRefreshId(object))
		)
		car(resultList) ; get list from "tconc" list
	) ; let
) ; defun

;
; Check for object have "Fixed" property. If it's true, remove this object from selection.
; Return list without fixed objects.
;
defun( alnCheckForFixedObjects (objectList)
	let( ( x prop object resultList)
		foreach( object objectList
			if( axlDBIsFixed(object nil)
				; remove from selection
				then axlSubSelectObject(object)
				; place to returned list
				else resultList = tconc(resultList object)
			)
		)
		car(resultList) ; get list from "tconc" list
	) ; let
) ; defun

;
; Move object to provided distance.
; Analise useStretch and useRipup settings and respectively move/ripup connected to object CLines.
;
defun( alnMoveObject (object deltaPoint) ; object = car(_alnSelectedObjects) deltaPoint = list(10.0 -10.0) alnMoveObject(object deltaPoint)
	let( (segmentsToCreate segmentsToRemove pinList pin pinXY paths isVia
			path segments segment startEnd newStartEnd segmentToCreate x1 y1 x2 y2 net)
		if( (car(deltaPoint) != 0.0 || cadr(deltaPoint) != 0.0) then
			if( (_alnFormData->useStretch || _alnFormData->useRipup) then
				;get list of pins
				pinList = object->pins
				if( object->objType == "via" then 
					isVia = t
					pinList = list(object) ; hack for vias
				) 
				; get CLines for each pin
				foreach( pin pinList
					pinXY = pin->xy
					; get paths connected to pin
					paths = axlDBGetConnect(pin nil)
					; get segments for each path
					foreach( path paths
						segments = path->segments
						; find segment which connected to pin (points are equal)
						foreach( segment segments
							startEnd = segment->startEnd
							newStartEnd = nil
							if( car(startEnd) == pinXY
							then
								; calculate new segment points
								x1 = xCoord(car(startEnd)) + xCoord(deltaPoint)
								y1 = yCoord(car(startEnd)) + yCoord(deltaPoint)
								x2 = xCoord(cadr(startEnd))
								y2 = yCoord(cadr(startEnd))
								newStartEnd = list( x1:y1 x2:y2 )
							else
								if( cadr(startEnd) == pinXY
								then
									; calculate new segment points
									x1 = xCoord(car(startEnd))
									y1 = yCoord(car(startEnd))
									x2 = xCoord(cadr(startEnd)) + xCoord(deltaPoint)
									y2 = yCoord(cadr(startEnd)) + yCoord(deltaPoint)
									newStartEnd = list( x1:y1 x2:y2 )
								)
							);if
							if(newStartEnd then
								segmentsToRemove = cons(segment segmentsToRemove)
								segmentToCreate = ncons(t)
								segmentToCreate->startEnd = newStartEnd
								segmentToCreate->width = segment->width
								segmentToCreate->layer = segment->layer
								segmentToCreate->netname = (segment->net)->name
								segmentsToCreate = cons(segmentToCreate segmentsToCreate)
							);if(newStartEnd
						);foreach( segment segments
					);foreach( path paths
				);foreach( pin pinList
				; remove old segments
				if( segmentsToRemove then
					foreach(segment segmentsToRemove
						axlDeleteObject(segment)
					)
				)
			);if(_alnFormData->useStretch
			;move object
			axlTransformObject( object ?move deltaPoint )
			when( isVia
				; restore net
				net = car(segmentsToCreate)->netname
				when( net axlDBAssignNet(object net) )
				
			)
			; create new segments
			if( (segmentsToCreate && _alnFormData->useStretch) then
				foreach(segment segmentsToCreate
					startEnd = segment->startEnd
					width = segment->width
					layer = segment->layer
					netname = segment->netname
					axlDBCreateLine( startEnd width layer netname nil)
				)
			)
		);if( (car(deltaPoint)
		t ;return
	) ; let
) ; defun


