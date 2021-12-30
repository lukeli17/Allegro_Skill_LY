;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	files required:  align_utils.il
;
;	skill load "o:\\Sripts\\align\\align_do.il"

defun( alnOnTop ()
	axlMsgPut("Align by TOP boundary")
	_alnHandler = 'alnDoTop
	axlCancelEnterFun()
);end-fun
defun( alnDoTop ()
		axlDBCloak( 'alnDoMoveTop() 'shape )
);end-fun
defun( alnDoMoveTop ()
	let( (lBBoxes maxY i objectItem boxItem boxY objectY griddedY deltaY deltaPoint grids)
		lBBoxes = alnGetBBoxes(_alnSelectedObjects)
		maxY = alnGetMaxBBoxY(lBBoxes)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		; move objects
		for( i 1 length(_alnSelectedObjects)
			objectItem = nthelem(i _alnSelectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(cadr(boxItem))
			deltaY = maxY - boxY

			objectY = yCoord(alnGetObjectLocation(objectItem))	; irginal point
			griddedY = yCoord(alnGriddedPoint(list( 0 (objectY + deltaY) ) grids)) ; moved and snapped point

			deltaY = griddedY - objectY
			deltaPoint = list( 0 deltaY)
			alnMoveObject( objectItem deltaPoint)

		)
	);end-let
);end-fun

defun( alnOnBottom ()
	axlMsgPut("Align by BOTTOM boundary")
	axlFinishEnterFun()
	_alnHandler = 'alnDoBottom
);end-fun
defun( alnDoBottom ()
	axlDBCloak( 'alnDoMoveBottom() 'shape )
);end-fun
defun( alnDoMoveBottom ()
	let( (lBBoxes minY i objectItem boxItem boxY objectY griddedY deltaY deltaPoint grids)
		lBBoxes = alnGetBBoxes(_alnSelectedObjects)
		minY = alnGetMinBBoxY(lBBoxes)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		; move objects
		for( i 1 length(_alnSelectedObjects)
			objectItem = nthelem(i _alnSelectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxY = yCoord(car(boxItem))
			deltaY = minY - boxY

			objectY = yCoord(alnGetObjectLocation(objectItem))
			griddedY = yCoord(alnGriddedPoint(list( 0 (objectY + deltaY) ) grids))

			deltaY = griddedY - objectY
			deltaPoint = list( 0 deltaY )
			alnMoveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( alnOnLeft ()
	axlMsgPut("Align by LEFT boundary")
	axlFinishEnterFun()
	_alnHandler = 'alnDoLeft
);end-fun
defun( alnDoLeft ()
	axlDBCloak( 'alnDoMoveLeft() 'shape )
);end-fun
defun( alnDoMoveLeft ()
	let( (lBBoxes minX i objectItem boxItem boxX objectX griddedX deltaX deltaPoint grids)
		lBBoxes = alnGetBBoxes(_alnSelectedObjects)
		minX = alnGetMinBBoxX(lBBoxes)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		; move objects
		for( i 1 length(_alnSelectedObjects)
			objectItem = nthelem(i _alnSelectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(car(boxItem))
			deltaX = minX - boxX

			objectX = xCoord(alnGetObjectLocation(objectItem))
			griddedX = xCoord(alnGriddedPoint(list( (objectX + deltaX) 0 ) grids))

			deltaX = griddedX - objectX
			deltaPoint = list( deltaX 0 )
			alnMoveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( alnOnRight ()
	axlMsgPut("Align by RIGHT boundary")
	axlFinishEnterFun()
	_alnHandler = 'alnDoRight
);end-fun
defun( alnDoRight ()
	axlDBCloak( 'alnDoMoveRight() 'shape )
);end-fun
defun( alnDoMoveRight ()
	let( (lBBoxes maxX i objectItem boxItem boxX objectX griddedX gridCorrection deltaX deltaPoint grids)
		lBBoxes = alnGetBBoxes(_alnSelectedObjects)
		maxX = alnGetMaxBBoxX(lBBoxes)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		; move objects
		for( i 1 length(_alnSelectedObjects)
			objectItem = nthelem(i _alnSelectedObjects)
			boxItem = nthelem(i lBBoxes)
			boxX = xCoord(cadr(boxItem))
			deltaX = maxX - boxX

			objectX = xCoord(alnGetObjectLocation(objectItem))
			griddedX = xCoord( alnGriddedPoint( list( (objectX + deltaX) 0 ) grids ) )

			deltaX = griddedX - objectX
			deltaPoint = list( deltaX 0 )
			alnMoveObject( objectItem deltaPoint)
		)
	);end-let
);end-fun

defun( alnOnCenterH ()
	axlMsgPut("Align horizontally")
	; assign handler function
	; call handler after exit from axlSelect()
	; otherwise snap to grid not properly work in axlEnterPoint() function
	_alnHandler = 'alnDoCenterH
	; exite from axlSelect()
	axlFinishEnterFun()
);end-fun
defun( alnDoCenterH ()
	let( (maxY minY fixedPointY pointY)
		maxY = alnMaxY(_alnSelectedObjects)
		minY = alnMinY(_alnSelectedObjects)
		fixedPointY = (maxY-minY)/2 + minY ; зафиксировать Y координату
		; move objects
		axlDBCloak( 'alnMoveToHorizontal(fixedPointY) 'shape )
	);end-let
);end-fun
defun( alnMoveToHorizontal (fixedPointY)
	let( (deltaY deltaPoint pointY grids)
		; snap to grid (depend on _alnFormData->snapToGrid)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		fixedPointY = yCoord(alnGriddedPoint( list( 0 fixedPointY) grids))
		foreach( oItem _alnSelectedObjects
			pointY = yCoord(alnGetObjectLocation(oItem))
			deltaY = fixedPointY - pointY
			deltaPoint = list( 0 deltaY)
			alnMoveObject( oItem deltaPoint)
		)
	);end-let
);end-fun

defun( alnOnCenterV ()
	axlMsgPut("Align vertically")
	axlFinishEnterFun()
	_alnHandler = 'alnDoCenterV
);end-fun
defun( alnDoCenterV ()
	let( (maxX minX fixedPointX)
		maxX = alnMaxX(_alnSelectedObjects)
		minX = alnMinX(_alnSelectedObjects)
		fixedPointX = (maxX-minX)/2 + minX
		axlDBCloak( 'alnMoveToVertical(fixedPointX) 'shape )
	);end-let
);end-fun
defun( alnMoveToVertical (fixedPointX)
	let( (deltaX deltaPoint pointX grids)
		; snap to grid (depend on _alnFormData->snapToGrid)
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		fixedPointX = xCoord(alnGriddedPoint( list( fixedPointX 0) grids))
		foreach( oItem _alnSelectedObjects
			pointX = xCoord(alnGetObjectLocation(oItem))
			deltaX = fixedPointX - pointX
			deltaPoint = list( deltaX 0 )
			alnMoveObject( oItem deltaPoint)
		)
	);end-let
);end-fun

; -------------------- Distribute -------------------------------------
defun( alnOnDistributeH ()
	axlMsgPut("Distribute horizontally")
	; get propely ordered list of selected ojects
	_alnSelectedObjects = alnOrderByX(_alnSelectedObjects)
	; check mode
	if( _alnFormData->useGap
		then _alnHandler = 'alnDoCalcStepBetweenBoundaryH
		else _alnHandler = 'alnDoCalcStepH
	)
	axlFinishEnterFun()
);end-fun
defun( alnDoCalcStepH ()
	let( (leftX rightX step grids)
when( (axlIsDebug) axlMsgPut("alnDoCalcStepH"))
		; check for step provided in form
		if( !_alnFormData->useStepH then
			; calculate step
			leftX = xCoord(alnGetObjectLocation(car(_alnSelectedObjects)))
			rightX = xCoord(alnGetObjectLocation(car(last(_alnSelectedObjects))))
			step = (rightX-leftX)/(length(_alnSelectedObjects)-1)
			; snap step to grid (depending from _alnFormData->snapToGrid)
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			step = xCoord(alnGriddedPoint( list( step 0) grids))
			; update form
			_alnFormData->stepH = step
			(axlFormSetField _alnFormPtr "fStepH" step)
		)
;		axlShell("cputime start")
;		axlShell("cputime reset")
		axlDBCloak( 'alnDoDistributeH() 'shape )
;		alnDoDistributeH()
;		axlShell("cputime stop")
	);end-let
);end-fun
defun( alnDoDistributeH ()
	let( (i step pointX deltaX deltaPoint grids)
when( (axlIsDebug) axlMsgPut("alnDoDistributeH"))
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		i = xCoord(alnGriddedPoint(alnGetObjectLocation(car(_alnSelectedObjects)) grids))
		step = _alnFormData->stepH
		foreach( oItem _alnSelectedObjects
			pointX = xCoord(alnGetObjectLocation(oItem))
			deltaX = i - pointX
			deltaPoint = list( deltaX 0 )
			alnMoveObject( oItem deltaPoint)
			i = i + step
		)
	);end-let
);end-fun

defun( alnDoCalcStepBetweenBoundaryH ()
	let( (leftX prevX box lBox gap step grids)
when( (axlIsDebug) axlMsgPut("alnDoCalcStepBetweenBoundaryH"))
		; check for step provided in form
		if( !_alnFormData->useStepH then
			gap = 0.0
			; get left boundary for first object
			prevX = xCoord(car(alnGetObjectBBox(car(_alnSelectedObjects))))
			; calculate common gap
			lBox = alnGetBBoxes(_alnSelectedObjects)
			foreach( box lBox
				; get left boundary
				leftX = xCoord(car(box))
				gap = gap + leftX - prevX
				; get right boundary for next iteration
				prevX = xCoord(cadr(box))
			)
			; calculate step
			step = gap/(length(_alnSelectedObjects)-1)
			; snap step to grid
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			step = xCoord(alnGriddedPoint( list( step 0 ) grids))
			_alnFormData->stepH = step
			; update form
			axlFormSetField(_alnFormPtr "fStepH" step)
		)
;		axlShell("cputime start")
;		axlShell("cputime reset")
		axlDBCloak( 'alnDoDistributeGapBetweenBoundaryH() 'shape )
;		alnDoDistributeGapBetweenBoundaryH()
;		axlShell("cputime stop")
	);end-let
);end-fun
defun( alnDoDistributeGapBetweenBoundaryH ()
	let( (step prevX oItem box leftX rightX deltaX currX destX deltaPoint grids)
when( (axlIsDebug) axlMsgPut("alnDoDistributeGapBetweenBoundaryH"))
		step = _alnFormData->stepH
		; get left boundary for first object
		prevX = xCoord(car(alnGetObjectBBox(car(_alnSelectedObjects)))) - step
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		foreach( oItem _alnSelectedObjects
			; current boundary
			box = alnGetObjectBBox(oItem)
			leftX = xCoord(car(box))
			rightX = xCoord(cadr(box))
			deltaX = leftX - prevX - step

			; curent location
			currX = xCoord(oItem->xy)
			; destination location (grided)
			destX = xCoord(alnGriddedPoint(list( (currX - deltaX) 0 ) grids))
			deltaPoint = list( (destX - currX) 0 )
			alnMoveObject(oItem deltaPoint)
			prevX = prevX + step + (rightX - leftX)
		)
	);end-let
);end-fun

defun( alnOnDistributeV ()
	axlMsgPut("Distribute vertically")
	_alnSelectedObjects = alnOrderByY(_alnSelectedObjects)
	if( _alnFormData->useGap
		then _alnHandler = 'alnDoCalcStepBetweenBoundaryV
		else _alnHandler = 'alnDoCalcStepV
	)
	axlFinishEnterFun()
);end-fun
defun( alnDoCalcStepV ()
	let( (botY topY step grids)
when( (axlIsDebug) axlMsgPut("alnDoCalcStepV"))
		if( !_alnFormData->useStepV then
			; calculate step
			botY = yCoord(alnGetObjectLocation(car(_alnSelectedObjects)))
			topY = yCoord(alnGetObjectLocation(car(last(_alnSelectedObjects))))
			step = (topY-botY)/(length(_alnSelectedObjects)-1)
			; snap step to grid (depending from _alnFormData->snapToGrid)
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			step = yCoord(alnGriddedPoint( list( 0 step) grids))
			; update form
			_alnFormData->stepV = step
			(axlFormSetField _alnFormPtr "fStepV" step)
		)
		axlDBCloak( 'alnDoDistributeV() 'shape )
	);end-let
);end-fun
defun( alnDoDistributeV ()
	let( (i step pointY deltaY deltaPoint grids)
when( (axlIsDebug) axlMsgPut("alnDoDistributeV"))
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		i = yCoord(alnGriddedPoint(alnGetObjectLocation(car(_alnSelectedObjects)) grids))
		step = _alnFormData->stepV
		foreach( oItem _alnSelectedObjects
			pointY = yCoord(alnGetObjectLocation(oItem))
			deltaY = i - pointY
			deltaPoint = list( 0 deltaY )
			alnMoveObject( oItem deltaPoint)
			i = i + step
		)
	);end-let
);end-fun

defun( alnDoCalcStepBetweenBoundaryV ()
	let( (bottomY prevY box lBox gap step grids)
when( (axlIsDebug) axlMsgPut("alnDoCalcStepBetweenBoundaryV"))
		if( !_alnFormData->useStepV then
			gap = 0.0
			; get left boundary for first object
			prevY = yCoord(car(alnGetObjectBBox(car(_alnSelectedObjects))))
			; calculate common gap
			lBox = alnGetBBoxes(_alnSelectedObjects)
			foreach( box lBox
				; get left boundary
				bottomY = yCoord(car(box))
				gap = gap + bottomY - prevY
				; get right boundary for next iteration
				prevY = yCoord(cadr(box))
			)
			; calculate step
			step = gap/(length(_alnSelectedObjects)-1)
			; snap step to grid
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			step = yCoord(alnGriddedPoint( list( 0 step) grids))
			_alnFormData->stepV = step
			; update form
			(axlFormSetField _alnFormPtr "fStepV" step)
		)
		axlDBCloak( 'alnDoDistributeGapBetweenBoundaryV() 'shape )
	);end-let
);end-fun
defun( alnDoDistributeGapBetweenBoundaryV ()
	let( (step prevY oItem box bottomY topY deltaY currY destY deltaPoint grids)
when( (axlIsDebug) axlMsgPut("alnDoDistributeGapBetweenBoundaryH"))
		step = _alnFormData->stepV
		; get bottom boundary for first object
		prevY = yCoord(car(alnGetObjectBBox(car(_alnSelectedObjects)))) - step
		grids = alnGetCurrentGrid(_alnSelectedObjects)
		foreach( oItem _alnSelectedObjects
			; current boundary
			box = alnGetObjectBBox(oItem)
			bottomY = yCoord(car(box))
			topY = yCoord(cadr(box))
			deltaY = bottomY - prevY - step

			; curent location
			currY = yCoord(oItem->xy)
			; destination location (grided)
			destY = yCoord(alnGriddedPoint(list( 0 (currY - deltaY) ) grids))
			deltaPoint = list( 0 (destY - currY) )
			alnMoveObject( oItem deltaPoint )
			prevY = prevY + step + (topY - bottomY)
		)
	);end-let
);end-fun

; -------------------- Pick -------------------------------------
defun( alnOnPickH ()
	axlMsgPut("Pick horizontally")
	axlFinishEnterFun()
	_alnHandler = 'alnDoPickH
);end-fun
defun( alnDoPickH ()
	let( (fixedObject fixedPoint fixedPointY grids)
		fixedPoint = nil
		if( _alnFormData->usePickH
		then
			fixedPointY = _alnFormData->pickH
		else
			fixedPoint = axlEnterPoint(?prompts "Select an object or point")
			if( fixedPoint then ;nil if pressed Oops
				axlSingleSelectPoint(fixedPoint)
				fixedObject = axlGetSelSet()
				if( fixedObject
				then
					fixedPointY = yCoord(alnGetObjectLocation(car(fixedObject)))
				else
					fixedPointY = yCoord(fixedPoint)
				)
			)
		)
		if( fixedPointY then ; nil if pressed Oops
			; snap to grid (depend on _alnFormData->snapToGrid)
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			fixedPointY = yCoord(alnGriddedPoint( list( 0 fixedPointY) grids))
			_alnFormData->pickH = fixedPointY
			axlFormSetField(_alnFormPtr "fPickH" fixedPointY)
			; move objects
			axlDBCloak( 'alnMoveToHorizontal(fixedPointY) 'shape )
		)
	);end-let
);end-fun

defun( alnOnPickV ()
	axlMsgPut("Pick horizontally")
	axlFinishEnterFun()
	_alnHandler = 'alnDoPickV
);end-fun
defun( alnDoPickV ()
	let( (fixedObject fixedPoint fixedPointX grids)
		fixedPoint = nil
		if( _alnFormData->usePickV
		then
			fixedPointX = _alnFormData->pickV
		else
			fixedPoint = axlEnterPoint(?prompts "Select an object or point")
			if( fixedPoint then ;nil if pressed Oops
				axlSingleSelectPoint(fixedPoint)
				fixedObject = axlGetSelSet()
				if( fixedObject
				then
					fixedPointX = xCoord(alnGetObjectLocation(car(fixedObject)))
				else
					fixedPointX = xCoord(fixedPoint)
				)
			)
		)
		if( fixedPointX then ; nil if pressed Oops
			grids = alnGetCurrentGrid(_alnSelectedObjects)
			fixedPointX = xCoord(alnGriddedPoint( list( fixedPointX 0) grids))
			_alnFormData->pickV = fixedPointX
			axlFormSetField(_alnFormPtr "fPickV" fixedPointX)
			axlDBCloak( 'alnMoveToVertical(fixedPointX) 'shape )
		)
	);end-let
);end-fun

