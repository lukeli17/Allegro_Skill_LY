; rename this file as "fig_align.il"
; in allegro, input "skill getSkillPath",to get several skill path
; copy this file to one of those path
; in allegro,input "skill load "fig_align.il" "
; in allegro, input "a" to run this skill tool
;
; by   LWQ
; email:
;
; 2011-09-17
; -----------------------------------------------------------------------------
axlCmdRegister( "ali_pin" 'pin_fig_align ?cmdType "interactive" ?doneCmd  'fig_align_stop ?cancelCmd 'fig_align_stop)
defvar(flag_fa)

defun( _alpMakeForm ()

	frmfle = outfile("alp.form" "w")
	fprintf( frmfle "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\n")
	fprintf( frmfle "PORT 30 10\nHEADER \"PIN\266\324\306\353\"\n")
    fprintf( frmfle "TILE\n")
    fprintf( frmfle "TEXT \"\321\241\324\361PIN\266\324\306\353\304\243\312\275:\"\n")
    fprintf( frmfle "TLOC 3 1\n")
    fprintf( frmfle "ENDTEXT\n")
    fprintf( frmfle "FIELD align_x\nFLOC 3 3\nCHECKLIST\"Align-X    [X\327\370\261\352\266\324\306\353]\" \"Mode1\"\n ENDFIELD\n\n")
	fprintf( frmfle "FIELD align_y\nFLOC 3 5\nCHECKLIST \"Align-Y    [Y\327\370\261\352\266\324\306\353]\" \"Mode1\"\nENDFIELD\n\n")
	fprintf( frmfle "FIELD align_o\nFLOC 3 7\nCHECKLIST \"Align-O    [PIN\326\330\265\376]\" \"Mode1\"\nENDFIELD\n\n")
	;fprintf( frmfle "FIELD done\nFLOC 2 10\nMENUBUTTON \"Done\" 7 3\nENDFIELD\n\n")
	;fprintf( frmfle "FIELD done\nFLOC 4 10\nMENUBUTTON \"Exit\" 7 3\nENDFIELD\n\n")
    fprintf( frmfle "ENDTILE\n")
    fprintf( frmfle "ENDFORM\n")	
    close(frmfle)
);enddefun    


defun( _alpform (Skill_Programs_Form)
       (case Skill_Programs_Form->curField
           ( "align_x"                 
				amode=0)                          
           ( "align_y" 
				amode=1)
		   ( "align_o" 
				amode=2)
           ; ( "done" 	
				; fig_align_stop()
				; )
        );endcase
)

procedure( pin_fig_align()
	popupA = axlUIPopupDefine( nil
				(list
					(list "Done" 'fig_align_stop)
					(list "Oops" 'fig_align_oops)
					(list "Cancel" 'fig_align_stop)
				))
	axlUIPopupSet( popupA )
    
	_alpMakeForm()
	form = axlMiniStatusLoad( (gensym) "alp.form" `_alpform)
	;form = axlFormCreate( (gensym) "alp.form" '(e outer) `_alpform t)
	;axlEnterPoint()
	Skill_Programs_Form=form
	
	(axlFormSetField form "align_x" t)
	amode=0
    putprop( Skill_Programs_Form t `align_x)
	axlMsgPut( "\304\254\310\317X\327\370\261\352\266\324\306\353\304\243\312\275!")
	calc_move()
    ;axlFormDisplay(form)
	 ;axlFormTest("alp.form")
		          
) ;end proc        


procedure( calc_move()
	flag_fa = t
	while( flag_fa       
		flag_fa_int = t 
		axlClearSelSet()   
		while( flag_fa_int&&flag_fa
			axlMsgPut( "-----------------------------------" )
			axlMsgPut( "\321\241\324\361\262\316\277\274\327\370\261\352 Pin1!" )
			;axlUIWBeep()
		
			axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins")) 
			if( axlSingleSelectPoint() then
			  oops_status=0
			  fig_a  = axlGetSelSet()
			  fig_a  = car(fig_a)              
			  fig_a_type = fig_a->objType  
			  
			  axlDBRefreshId(fig_a)
			  
			  fig_a_xy = fig_a->xy
												 
			  axlHighlightObject(fig_a  t)  
			  flag_fa_int = nil    
				else
				flag_fa_int = t
			)
      )          
		axlClearSelSet()
		flag_fa_int = t
		while(flag_fa_int&&flag_fa
		axlMsgPut( "\321\241\324\361\322\306\266\257\306\367\274\376 Pin2!" )
		axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins"))          
		if( axlSingleSelectPoint() then
			fig_b = axlGetSelSet()
			fig_b = car(fig_b)
			fig_b_type = fig_b->objType
		 
			axlDBRefreshId(fig_b)
		 
			fig_b_xy = fig_b->xy
					 
			if( fig_a != fig_b then                                                                                                   
				if(amode < 3 then                       
					ix_a = nth(0 fig_a_xy) - nth(0 fig_b_xy)
					iy_a = nth(1 fig_a_xy) - nth(1 fig_b_xy)
					when(fig_b_type == "pin"
						fig_b = fig_b->parent) 
					case(amode
						(0
							axlTransformObject(fig_b, ?move ix_a:0)
							;axlMsgPut( "%L X_mode!" amode)
							)
						(1
							axlTransformObject(fig_b, ?move 0:iy_a)
							;axlMsgPut( "%L Y_mode!" amode)
							)
						(2
							axlTransformObject(fig_b, ?move ix_a:iy_a)
							;axlMsgPut( "%L O_mode!" amode)
							)
					 )
				axlDehighlightObject(fig_a t)                            
					else
					 axlMsgPut( "TOO BAD" )
					 axlDehighlightObject(fig_a t)
					)              
				flag_fa_int = nil
			  else           
				axlMsgPut( "Pin1\323\353Pin2\317\340\315\254" )
				axlUIWBeep()
				axlDehighlightObject(fig_a t)
				flag_fa_int = nil
			  )          
		else
		 flag_fa_int = t
		)
		  );end 3nd fig while
      
    
    );end main while 
);end procedure


procedure(fig_align_oops()
	if(oops_status==0 then
		case(amode
				(0
					axlTransformObject(fig_b, ?move -ix_a:0)
					oops_status=1
					)
				(1
					axlTransformObject(fig_b, ?move 0:-iy_a)
					oops_status=1
					)
				(2
					axlTransformObject(fig_b, ?move -ix_a:-iy_a)
					oops_status=1
					)
			 )
		axlMsgPut( "\322\321\263\267\317\372!" )
		else
		axlMsgPut( "\322\321\316\336\267\250\263\267\317\372!" )
		);end if
);end oops     
 
procedure(fig_align_stop()
	axlDehighlightObject(axlGetSelSet())
	axlDehighlightObject(fig_a t)
	;axlCancelEnterFun()
	flag_fa = nil 
	;axlClearSelSet()
	axlFormClose(Skill_Programs_Form)
	axlCancelEnterFun()
	axlClearSelSet()
	axlCloseFindFilter()
	deleteFile("alp.form")
  
);end stoped

