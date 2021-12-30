axlCmdRegister("funckey_silkscreentop" 'funckey_silkscreentop ?cmdType "general")			;快捷键5：正面丝印
axlCmdRegister("funckey_silkscreenbot" 'funckey_silkscreenbot ?cmdType "general")			;快捷键6：背面丝印
axlCmdRegister("funckey_silkscreenclean" 'funckey_silkscreenclean ?cmdType "general")		;快捷键7：关闭丝印
axlCmdRegister("funckey_via" 'funckey_via ?cmdType "general")								;快捷键8：开关过孔
axlCmdRegister("funckey_placement" 'funckey_placement ?cmdType "general")					;快捷键9：器件布局+3D
axlCmdRegister("funckey_all" 'funckey_all ?cmdType "general")								;快捷键0：ALL
axlCmdRegister("z+27" 'turnonassemblytop ?cmdType "general")								;快捷键z+27
axlCmdRegister("z +27" 'turnonassemblytop ?cmdType "general")								;快捷键z +27
axlCmdRegister("z+30" 'turnonassemblybot ?cmdType "general")								;快捷键z+30
axlCmdRegister("z +30" 'turnonassemblybot ?cmdType "general")								;快捷键z +30
axlCmdRegister("z+31" 'turnondisplaytop ?cmdType "general")									;快捷键z+31
axlCmdRegister("z +31" 'turnondisplaytop ?cmdType "general")								;快捷键z +31
axlCmdRegister("z+32" 'turnondisplaybot ?cmdType "general")									;快捷键z+32
axlCmdRegister("z +32" 'turnondisplaybot ?cmdType "general")								;快捷键z +32



/*
###########################################################
#                 设置Funckey快捷键                       #
###########################################################
*/
axlSetFunckey( "5" "funckey_silkscreentop")		;设置快捷键5
axlSetFunckey( "6" "funckey_silkscreenbot")		;设置快捷键6
axlSetFunckey( "7" "funckey_silkscreenclean")	;设置快捷键6
axlSetFunckey( "8" "funckey_via")				;设置快捷键8
axlSetFunckey( "9" "funckey_placement")			;设置快捷键9
axlSetFunckey( "0" "funckey_all")				;设置快捷键0



;###########################################################
;#                 	快捷键Z+??:开始    	  	              #
;###########################################################


defun(	turnonassemblytop ()	;Z+27
		if(axlIsVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP")	then
			axlVisibleLayer( "PACKAGE GEOMETRY/ASSEMBLY_TOP", nil)
			else
			axlVisibleLayer( "PACKAGE GEOMETRY/ASSEMBLY_TOP", t)
		)
		axlVisibleUpdate( t)
)




defun(	turnonassemblybot ()	;Z+30
		if(axlIsVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM")	then
			axlVisibleLayer( "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM", nil)
			else
			axlVisibleLayer( "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM", t)
		)
		axlVisibleUpdate( t)
)



defun(	turnondisplaytop ()		;Z+31
		if(axlIsVisibleLayer("PACKAGE GEOMETRY/DISPLAY_TOP")	then
			axlVisibleLayer( "PACKAGE GEOMETRY/DISPLAY_TOP", nil)
			else
			axlVisibleLayer( "PACKAGE GEOMETRY/DISPLAY_TOP", t)
		)
		axlVisibleUpdate( t)
)



defun(	turnondisplaybot ()		;Z+32
		if(axlIsVisibleLayer("PACKAGE GEOMETRY/DISPLAY_BOTTOM")	then
			axlVisibleLayer( "PACKAGE GEOMETRY/DISPLAY_BOTTOM", nil)
			else
			axlVisibleLayer( "PACKAGE GEOMETRY/DISPLAY_BOTTOM", t)
		)
		axlVisibleUpdate( t)
)



;###########################################################
;#           	      快捷键Z+??：结束	                  #
;###########################################################




;###########################################################
;#                 	快捷键5：正面丝印    	               #
;###########################################################

defun(	funckey_silkscreentop ()
	if(!axlIsVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP") && axlIsVisibleLayer("PIN/SOLDERMASK_TOP") && axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP") && axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP") && axlIsVisibleLayer("REF DES/SILKSCREEN_TOP") &&	!axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM") &&	!axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM") && !axlIsVisibleLayer("REF DES/SILKSCREEN_BOTTOM")	then
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_TOP", t)
		axlVisibleLayer( "DRC ERROR CLASS/PACKAGE_TOP", t)
		axlVisibleUpdate( t)
		else
			axlVisibleDesign( nil)
			axlVisibleLayer( "PIN/SOLDERMASK_TOP", t)
			
			axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
			axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t)
			axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_TOP", t)
			
			axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
			axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_TOP", t)
			axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
			axlVisibleUpdate( t)
			)
);defun_end



;###########################################################
;#                 	快捷键6：背面丝印    	               #
;###########################################################

defun(	funckey_silkscreenbot ()
	if(!axlIsVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") && axlIsVisibleLayer("PIN/SOLDERMASK_BOTTOM") && axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM") && axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM") && axlIsVisibleLayer("REF DES/SILKSCREEN_BOTTOM") &&	!axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP") &&	!axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP") && !axlIsVisibleLayer("REF DES/SILKSCREEN_TOP")	then
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM", t)
		axlVisibleLayer( "DRC ERROR CLASS/PACKAGE_BOTTOM", t)
		axlVisibleUpdate( t)
		else
			axlVisibleDesign( nil)
			axlVisibleLayer( "PIN/SOLDERMASK_BOTTOM", t)
			
			axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
			axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t)
			axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_BOTTOM", t)
			
			axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
			axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM", t)
			axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)
			axlVisibleUpdate( t)
			)
);defun_end






;###########################################################
;#                 	快捷键7：关闭丝印    	               #
;###########################################################

defun(	funckey_silkscreenclean ()
	if(axlIsVisibleLayer("REF DES/SILKSCREEN_TOP")	||	axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP") 	then
		if(axlIsVisibleLayer("REF DES/SILKSCREEN_TOP")	&&	axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP") && axlIsVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP")	then
			axlVisibleLayer( "REF DES/SILKSCREEN_TOP" nil )
			else
				axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", nil)
				axlVisibleLayer( "B5OARD GEOMETRY/SILKSCREEN_TOP", nil)		
			)
		else
			when(axlIsVisibleLayer("PIN/SOLDERMASK_TOP") || axlIsVisibleLayer("PIN/TOP")
					axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t)
					axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_TOP", t)
					
					axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
					axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_TOP", t)
					axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
				)
		)	
	if(axlIsVisibleLayer("REF DES/SILKSCREEN_BOTTOM") || axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM") 	then
		if(axlIsVisibleLayer("REF DES/SILKSCREEN_BOTTOM")	&&	axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM") && axlIsVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM")	then
			axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" nil )
			else
				axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", nil)
				axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", nil)
			)
		else
			when(axlIsVisibleLayer("PIN/SOLDERMASK_BOTTOM") || axlIsVisibleLayer("PIN/BOTTOM")
				axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t)
				axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_BOTTOM", t)
				
				axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
				axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM", t)
				axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)
			)
		)
	axlVisibleUpdate( t)	
);defun_end




;###########################################################
;#                 	快捷键8：开关过孔    	               #
;###########################################################

defun(	funckey_via ()
	if(axlIsVisibleLayer("VIA CLASS/TOP")	||	axlIsVisibleLayer("VIA CLASS/BOTTOM")	then
		axlVisibleLayer( "VIA CLASS/TOP" nil )
		axlVisibleLayer( "VIA CLASS/BOTTOM" nil )
		else
			when(axlIsVisibleLayer("PIN/TOP")	||	axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP") ||	axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP")
				axlVisibleLayer( "VIA CLASS/TOP" t )
				)
			when(axlIsVisibleLayer("PIN/BOTTOM")	||	axlIsVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM") ||	axlIsVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM")
				axlVisibleLayer( "VIA CLASS/BOTTOM" t )
				)
	)		
	axlVisibleUpdate( t)	
);defun_end




;###########################################################
;#                 快捷键9：器件布局+3D    	               #
;###########################################################

defun(	funckey_placement ()
	if(axlIsVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP") && axlIsVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") 	then
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_TOP", nil)
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM", nil)
		axlVisibleUpdate( t)
		else
		axlVisibleDesign( nil)	
		axlVisibleLayer( "PIN/TOP", t)
		axlVisibleLayer( "PIN/BOTTOM", t)
		;axlVisibleLayer( "PIN/SOLDERMASK_TOP", t)
		;axlVisibleLayer( "PIN/SOLDERMASK_BOTTOM", t)
		
		axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
		axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t)
		axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t)
		axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_TOP", t)
		axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_BOTTOM", t)
		
		axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
		axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
		axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_TOP", t)
		axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM", t)
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_TOP", t)
		axlVisibleLayer( "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM", t)
		
		axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
		axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)		
		axlVisibleUpdate( t)
			)
);defun_end



;###########################################################
;#                 		快捷键0:ALL 	                   #
;###########################################################

defun(	funckey_all ()
	axlVisibleDesign( nil)	
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
	axlVisibleLayer( "PIN/TOP", t)
	axlVisibleLayer( "PIN/BOTTOM", t)
	axlVisibleLayer( "ETCH/TOP", t)
	axlVisibleLayer( "ETCH/BOTTOM", t)
	axlVisibleLayer( "VIA CLASS/TOP", t)
	axlVisibleLayer( "VIA CLASS/BOTTOM", t)
	
	axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t)
	axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t)
	axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_TOP", t)
	axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_BOTTOM", t)
	
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_TOP", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM", t)
	
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)

	axlVisibleLayer( "DRAWING FORMAT/DRAWING_ORIGIN", t)
	axlVisibleLayer( "DRC ERROR CLASS/TOP", t)
	axlVisibleLayer( "DRC ERROR CLASS/BOTTOM", t)
	axlVisibleUpdate( t)
);defun_end
