;
;	$Source$ $Revision$ $Branch$ $Rev$
;	$Author$ $Date$
;
;	Files required:	align_do.il
;					align_utils.il
;					align.form
;					align-bottom.bmp
;					align-centerH.bmp
;					align-centerV.bmp
;					align-left.bmp
;					align-right.bmp
;					align-top.bmp
;					distributeH.bmp
;					distributeV.bmp
;					pickH.bmp
;					pickV.bmp
;	Place form files to %formpath%.
; 	Place bitmap files to %bmppath%.
;
;	skill load "o:/Sripts/align/align.il"
;	skill load "o:/Sripts/align/align_do.il"
;	skill load "o:/Sripts/align/align_utils.il"

axlCmdRegister( "al" 'aln  ?cmdType "interactive" ?doneCmd 'alnDone ?cancelCmd 'alnCancel )
when( (axlVersion('version) >= 16.3 && !axlUIMenuFind(nil "aln")) ; since 16.3
	axlUIMenuRegister( "move" '( ("&Align" "aln") ) ) 
)

;  reload script, only for development purpose
/*axlCmdRegister( "lo" 'lo)
procedure( lo()
	load("o:/Sripts/align/align.il")
	load("o:/Sripts/align/align_do.il")
	load("o:/Sripts/align/align_utils.il")
)*/

procedure( aln()
(prog ()
	when( axlOKToProceed()
		axlDebug(nil)
;		axlDebug(t)
		axlClearSelSet()
		alnInitGlobalVariable()
		alnInitForm()
		alnInitHotKeys()

		popupA = axlUIPopupDefine( nil
				(list
					(list "Done" 'alnDone)
					(list "Oops" 'alnOops)
					(list "Cancel" 'alnCancel)
				))
		axlUIPopupSet( popupA )

		axlSetFindFilter(?enabled '(GROUPS SYMBOLS PINS VIAS TEXT NAMEFORM ) ?onButtons _alnCheckedFilterBoxes) ; setup filter
		axlMsgPut("Select object(s)")
		_alnTransactionMark = axlDBTransactionStart()
		while( _alnFinish == nil
			; get objects from previous iteration
			_alnSelectedObjects = axlGetSelSet()
			if(_alnSelectedObjects then axlMsgPut("Choose action"))
			; remove fixed objects from selection
			_alnSelectedObjects = alnCheckForFixedObjects(_alnSelectedObjects)

			; wait for object selection
			axlSelect(?groupMode nil ?prompt nil)
			; execute operation chosen in form
			if( _alnHandler then
				if( _alnSelectedObjects
					then
						axlDBTransactionMark(_alnTransactionMark)
;						axlDBControl('drcEnable nil)
;						axlDBControl('dynamicFilletsOn nil)
						funcall(_alnHandler)
						; refresh id
						axlDBRefreshId(axlGetSelSet())
						; restore selection
						_alnSelectedObjects = alnRefreshIDs(_alnSelectedObjects)
						axlSingleSelectObject(_alnSelectedObjects)
;						axlDBControl('dynamicFilletsOn t)
;						axlDBControl('drcEnable t)
						;axlDRCUpdate(t)
					else
						axlMsgPut("No object(s) found")
				)
				_alnHandler = nil
			)
		);end-while
	);endwhen
);end-prog
);endprocedure

;----------------- Menu Call--------------------------------
defun( alnDone ()
	axlDBTransactionCommit( _alnTransactionMark )
	alnExit()
);end-fun
defun( alnOops ()
	if(_alnHandler then axlFinishEnterFun()) ;for exit from 'doPickH or 'doPickV
	axlDBTransactionOops(_alnTransactionMark)
	; restore selection
	_alnSelectedObjects = alnRefreshIDs(_alnSelectedObjects)
	axlAddSelectObject(_alnSelectedObjects)
);end-fun
defun( alnCancel ()
	axlDBControl('drcEnable nil)
	axlDBTransactionRollback( _alnTransactionMark )
	alnExit()
);end-fun
defun( alnExit ()
	_alnFinish = t
	axlFormClose(_alnFormPtr)
	axlDehighlightObject(_alnSelectedObjects)
	axlCancelEnterFun()
	axlClearSelSet()
	axlUIPopupSet( nil )
	popupA = nil
	_alnCheckedFilterBoxes = axlGetFindFilter(t)
	alnStoreFilter(_alnCheckedFilterBoxes)
	_alnTransactionMark = nil
	alnRestoreHotKeys()
	axlDBControl('drcEnable t)
	alnStoreFormData()
	
);end-defun

;-------------------Parameter form data ------------------
defun( alnInitForm () ;
let( (units multiplier)
when( (axlIsDebug) axlMsgPut("alnInitForm"))
	_alnFormPtr = axlMiniStatusLoad( (gensym) "align.form" '_parmCallBack)
	;_alnFormPtr = axlFormCreate( (gensym) "align.form" '(ne canvas msglines 0) '_parmCallBack t)
	units = axlDBGetDesignUnits()
	case( car(units)
		("mils" multiplier = 1)
		("inches" multiplier = 0.001)
		("microns" multiplier = 25.4)
		("millimeters" multiplier = 0.0254)
		("centimeters" multiplier = 0.00254)
	)
	when( ( _alnFormData == nil )
		; first script launch in current session, trying restore settings
		_alnFormData = alnRestoreFormData()
	)
	if( ( _alnFormData == nil ) 
		then ; first script launch
			_alnFormData = ncons(t)
			
			_alnFormData->units = units
			axlFormSetField(_alnFormPtr "bxPickH" nil)
			_alnFormData->usePickH = nil
			axlFormSetField(_alnFormPtr "bxStepH" nil)
			_alnFormData->useStepH = nil
			axlFormSetField(_alnFormPtr "bxPickV" nil)
			_alnFormData->usePickV = nil
			axlFormSetField(_alnFormPtr "bxStepV" nil)
			_alnFormData->useStepV = nil
			axlFormSetField(_alnFormPtr "fPickH" 0.0)
			_alnFormData->pickH = 0.0
			axlFormSetField(_alnFormPtr "fStepH" (100.0 * multiplier))
			_alnFormData->stepH = 100.0 * multiplier
			axlFormSetField(_alnFormPtr "fPickV" 0.0)
			_alnFormData->pickV = 0.0
			axlFormSetField(_alnFormPtr "fStepV" (100.0 * multiplier))
			_alnFormData->stepV = 100.0 * multiplier
			axlFormSetField(_alnFormPtr "bxGap" nil)
			_alnFormData->useGap = nil
			axlFormSetField(_alnFormPtr "bxStretch" t)
			_alnFormData->useStretch = t
			axlFormSetField(_alnFormPtr "bxRipup" nil)
			_alnFormData->useRipup = nil
			axlFormSetField(_alnFormPtr "bxSnapToGrid" t)
			_alnFormData->snapToGrid = t
			axlFormSetField(_alnFormPtr "cmbSnapPoint" "center")
			_alnFormData->snapPoint = "center"
			axlFormSetField(_alnFormPtr "sPinNumber" "1")
			_alnFormData->snapPinNumber = "1"
		else ; settings present in session or restored from design
			when( car(_alnFormData->units) != car(units) 
				; units were changed, correct multiplier
				case( car(_alnFormData->units)
	;				("mils" multiplier = multiplier / 1)
					("inches" multiplier = multiplier / 0.001)
					("microns" multiplier = multiplier / 25.4)
					("millimeters" multiplier = multiplier / 0.0254)
					("centimeters" multiplier = multiplier / 0.00254)
				)
				_alnFormData->pickH	= _alnFormData->pickH * multiplier
				_alnFormData->stepH	= _alnFormData->stepH * multiplier
				_alnFormData->pickV = _alnFormData->pickV * multiplier
				_alnFormData->stepV	= _alnFormData->stepV * multiplier
				_alnFormData->units = units
			)
			axlFormSetField(_alnFormPtr "bxPickH" _alnFormData->usePickH)
			axlFormSetField(_alnFormPtr "bxStepH" _alnFormData->useStepH)
			axlFormSetField(_alnFormPtr "bxPickV" _alnFormData->usePickV)
			axlFormSetField(_alnFormPtr "bxStepV" _alnFormData->useStepV)
			axlFormSetDecimal(_alnFormPtr "fPickH" cadr(units))
			axlFormSetDecimal(_alnFormPtr "fStepH" cadr(units))
			axlFormSetDecimal(_alnFormPtr "fPickV" cadr(units))
			axlFormSetDecimal(_alnFormPtr "fStepV" cadr(units))
			axlFormSetField(_alnFormPtr "fPickH" _alnFormData->pickH)
			axlFormSetField(_alnFormPtr "fStepH" _alnFormData->stepH)
			axlFormSetField(_alnFormPtr "fPickV" _alnFormData->pickV)
			axlFormSetField(_alnFormPtr "fStepV" _alnFormData->stepV)
			axlFormSetField(_alnFormPtr "bxGap" _alnFormData->useGap)
			axlFormSetField(_alnFormPtr "bxStretch" _alnFormData->useStretch)
			axlFormSetField(_alnFormPtr "bxRipup" _alnFormData->useRipup)
			axlFormSetField(_alnFormPtr "bxSnapToGrid" _alnFormData->snapToGrid)
			axlFormSetField(_alnFormPtr "cmbSnapPoint" _alnFormData->snapPoint)
			axlFormSetField(_alnFormPtr "sPinNumber" _alnFormData->snapPinNumber)
	)

	if(_alnFormData->usePickH
		then axlFormSetFieldEditable(_alnFormPtr "fPickH" t)
		else axlFormSetFieldEditable(_alnFormPtr "fPickH" nil)
	)
	if(_alnFormData->usePickV
		then axlFormSetFieldEditable(_alnFormPtr "fPickV" t)
		else axlFormSetFieldEditable(_alnFormPtr "fPickV" nil)
	)

	if(_alnFormData->useStepH
		then axlFormSetFieldEditable(_alnFormPtr "fStepH" t)
		else axlFormSetFieldEditable(_alnFormPtr "fStepH" nil)
	)
	if(_alnFormData->useStepV
		then axlFormSetFieldEditable(_alnFormPtr "fStepV" t)
		else axlFormSetFieldEditable(_alnFormPtr "fStepV" nil)
	)

	if(_alnFormData->useStretch
	then
		axlFormSetField(_alnFormPtr "bxRipup" nil)
		_alnFormData->useRipup = nil
	)
	if(_alnFormData->useRipup then
		axlFormSetField(_alnFormPtr "bxStretch" nil)
		_alnFormData->useStretch = nil
	)
	
	if( (_alnFormData->snapPoint == "pin")
		then axlFormSetFieldVisible( _alnFormPtr "sPinNumber" 1)
		else axlFormSetFieldVisible( _alnFormPtr "sPinNumber" 0)
	)
	when( (axlVersion('version) < 15.7) ; since 15.7
		axlFormSetFieldEditable(_alnFormPtr "bxSnapToGrid" nil)
	)
;	axlFormDisplay(_alnFormPtr)
) ;end let
);end-defun

;---------------Form Call Back-----------------------------------------------
defun( _parmCallBack (form)
when( (axlIsDebug) axlMsgPut("_parmCallBack"))
	case( get(form 'curField)
		( "bnTop" alnOnTop() )
		( "bnCenterH" alnOnCenterH() )
		( "bnBottom" alnOnBottom() )
		( "bnLeft" alnOnLeft() )
		( "bnCenterV"  alnOnCenterV() )
		( "bnRight" alnOnRight() )

		( "bxPickH" _alnFormData->usePickH = form->curValue
			if(_alnFormData->usePickH
				then axlFormSetFieldEditable(form "fPickH" t)
				else axlFormSetFieldEditable(form "fPickH" nil)
			)
		)
		( "fPickH" _alnFormData->pickH = form->curValue )
		( "bnPickH" alnOnPickH() )

		( "bxPickV" _alnFormData->usePickV = form->curValue
			if(_alnFormData->usePickV
				then axlFormSetFieldEditable(form "fPickV" t)
				else axlFormSetFieldEditable(form "fPickV" nil)
			)
		)
		( "fPickV" _alnFormData->pickV = form->curValue )
		( "bnPickV" alnOnPickV() )

		( "bxStepH"
			_alnFormData->useStepH = form->curValue
			if(_alnFormData->useStepH
				then axlFormSetFieldEditable(form "fStepH" t)
				else axlFormSetFieldEditable(form "fStepH" nil)
			)
		)
		( "fStepH" _alnFormData->stepH = form->curValue )
		( "bnDistributeH" alnOnDistributeH() )

		( "bxStepV"
			_alnFormData->useStepV = form->curValue
			if(_alnFormData->useStepV
				then axlFormSetFieldEditable(form "fStepV" t)
				else axlFormSetFieldEditable(form "fStepV" nil)
			)
		)
		( "fStepV" _alnFormData->stepV = form->curValue )
		( "bnDistributeV" alnOnDistributeV() )

		( "bxGap" _alnFormData->useGap = form->curValue)
		( "bxStretch"
			_alnFormData->useStretch = form->curValue
			if(_alnFormData->useStretch
			then
				axlFormSetField(form "bxRipup" nil)
				_alnFormData->useRipup = nil
			)
		)
		( "bxRipup"
			_alnFormData->useRipup = form->curValue
			if(_alnFormData->useRipup then
				axlFormSetField(form "bxStretch" nil)
				_alnFormData->useStretch = nil
			)
		)
		( "bxSnapToGrid" _alnFormData->snapToGrid = form->curValue	)
		( "cmbSnapPoint" 
			_alnFormData->snapPoint = form->curValue
			if( (_alnFormData->snapPoint == "pin")
				then axlFormSetFieldVisible( form "sPinNumber" 1)
				else axlFormSetFieldVisible( form "sPinNumber" 0)
			)
		)
		( "sPinNumber" _alnFormData->snapPinNumber = form->curValue)
	);case
);end-defun

defun( alnInitGlobalVariable ()
	_alnFinish = nil
	when( !boundp('_alnFormData) _alnFormData = nil)
	_alnFormPtr = nil
	_alnHandler = nil
	_alnSelectedObjects = nil
	when( !boundp('_alnCheckedFilterBoxes) 
		_alnCheckedFilterBoxes = alnRestoreFilter()
		when( !_alnCheckedFilterBoxes _alnCheckedFilterBoxes = '(SYMBOLS VIAS TEXT)		
		)
	)
);end-defun

defun( alnInitHotKeys ()
	let( (aliases alias aliasFunc funckeys funckey funckeyFunc)
		; store all hotkeys	and find hotkey for oops command	
		; funckeys
		when( (axlVersion('version) >= 16.3) ; since 16.3
			funckeys = axlGetFunckey(nil)
			_alnOriginalFunckeys = nil
			foreach( funckey funckeys
				funckeyFunc = axlGetFunckey(funckey)
				_alnOriginalFunckeys = cons(list(funckey funckeyFunc) _alnOriginalFunckeys)
				when( funckeyFunc == "oops" 
					_oopsAlias = funckey
				)
			)
		)
		; aliases
		aliases = axlGetAlias(nil)
		_alnOriginalAliases = nil
		foreach( alias aliases
			aliasFunc = axlGetAlias(alias)
			_alnOriginalAliases = cons(list(alias aliasFunc) _alnOriginalAliases)
			when( aliasFunc == "oops" 
				_oopsAlias = alias
			)
		)

		; define new actions
		axlCmdRegister( "alnOops" 'alnOops ?cmdType "sub_cmd")
		axlCmdRegister( "alnTop" 'alnOnTop ?cmdType "sub_cmd")
		axlCmdRegister( "alnBottom" 'alnOnBottom ?cmdType "sub_cmd")
		axlCmdRegister( "alnLeft" 'alnOnLeft ?cmdType "sub_cmd")
		axlCmdRegister( "alnRight" 'alnOnRight ?cmdType "sub_cmd")
		axlCmdRegister( "alnCenterH" 'alnOnCenterH ?cmdType "sub_cmd")
		axlCmdRegister( "alnCenterV" 'alnOnCenterV ?cmdType "sub_cmd")
		axlCmdRegister( "alnDistributeH" 'alnOnDistributeH ?cmdType "sub_cmd")
		axlCmdRegister( "alnDistributeV" 'alnOnDistributeV ?cmdType "sub_cmd")
		axlCmdRegister( "alnPickH" 'alnOnPickH ?cmdType "sub_cmd")
		axlCmdRegister( "alnPickV" 'alnOnPickV ?cmdType "sub_cmd")
		; define new hotkeys
		if( boundp('_oopsAlias) && _oopsAlias
			then axlSetAlias( _oopsAlias "alnOops")
			else axlSetAlias( "F3" "alnOops") ; if hotkey for oops command not assigned
		)
		when( (axlVersion('version) >= 16.3) ; since 16.3
			axlSetFunckey( "a" "alnLeft")
			axlSetFunckey( "s" "alnBottom")
			axlSetFunckey( "w" "alnTop")
			axlSetFunckey( "d" "alnRight")
			axlSetFunckey( "q" "alnCenterH")
			axlSetFunckey( "z" "alnCenterV")
			axlSetFunckey( "e" "alnDistributeH")
			axlSetFunckey( "c" "alnDistributeV")
			axlSetFunckey( "r" "alnPickH")
			axlSetFunckey( "v" "alnPickV")
		)
	) ; let
);end-defun

defun( alnRestoreHotKeys ()
	let( (funckey alias)
				
		axlCmdUnregister("alnOops")
		axlCmdUnregister("alnLeft")
		axlCmdUnregister("alnBottom")
		axlCmdUnregister("alnTop")
		axlCmdUnregister("alnRight")
		axlCmdUnregister("alnCenterH")
		axlCmdUnregister("alnCenterV")
		axlCmdUnregister("alnDistributeH")
		axlCmdUnregister("alnDistributeV")
		axlCmdUnregister("alnPickH")
		axlCmdUnregister("alnPickV")
		when( !boundp('_oopsAlias) || !_oopsAlias
			axlSetAlias( "F3" nil)
		)
		when( (axlVersion('version) >= 16.3) ; since 16.3
			axlSetFunckey( "a" nil)
			axlSetFunckey( "s" nil)
			axlSetFunckey( "w" nil)
			axlSetFunckey( "d" nil)
			axlSetFunckey( "q" nil)
			axlSetFunckey( "z" nil)
			axlSetFunckey( "e" nil)
			axlSetFunckey( "c" nil)
			axlSetFunckey( "r" nil)
			axlSetFunckey( "v" nil)
		
			; restore funckeys
			foreach( funckey _alnOriginalFunckeys
				when( !axlIsProtectAlias(car(funckey)) ; skip readonly
					axlSetFunckey(car(funckey) cadr(funckey))
				)
			)
		_alnOriginalFunckeys = nil
		)
		; restore aliases
		foreach( alias _alnOriginalAliases
			when( !axlIsProtectAlias(car(alias)) ; skip readonly
				axlSetAlias(car(alias) cadr(alias))
			)
		)
		_alnOriginalAliases = nil
	) ; let
);end-defun

;
; Store form settings to attachment.
; 
defun( alnStoreFormData ()
	let( (sFormData attachment )
		sFormData = sprintf(nil "%L" _alnFormData)
		attachment = axlGetAttachment("AlignFormData" 'string)
		if( attachment
		then
			attachment->data = sFormData
			axlSetAttachment(attachment "QWE123qwe")
		else
			attachment = axlCreateAttachment("AlignFormData" "QWE123qwe" 0 'string sFormData)
		);if
	) ; let
);end-defun

;
; Restore form settings from attachment.
;
defun( alnRestoreFormData ()
	prog( (formData attachment sFormData )
		formData = nil
		attachment = axlGetAttachment("AlignFormData" 'string)
		sFormData = attachment->data
		when( sFormData
			formData = car(errsetstring(strcat("'" sFormData)))
		)
		return(formData)
	) ; let
);end-defun


;
; Store selected Find filter checkboxes.
; 
defun( alnStoreFilter (checked) 
	let( (attachment sChecked)
		sChecked = sprintf(nil "%L" checked)
		attachment = axlGetAttachment("AlignSelectFilter" 'string)
		if( attachment
		then
			attachment->data = sChecked
			axlSetAttachment(attachment "QWE123qwe")
		else
			attachment = axlCreateAttachment("AlignSelectFilter" "QWE123qwe" 0 'string sChecked)
		);if
	) ; let
);end-defun

;
; Restore selected Find filter checkboxes.
;
defun( alnRestoreFilter ()
	prog( (checked attachment sChecked )
		checked = nil
		attachment = axlGetAttachment("AlignSelectFilter" 'string)
		sChecked = attachment->data
		when( sChecked
			checked = car(errsetstring(strcat("'" sChecked)))
		)
		return(checked)
	) ; let
);end-defun