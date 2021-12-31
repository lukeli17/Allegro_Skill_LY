axlCmdRegister("funckey_silkscreentop" 'funckey_silkscreentop ?cmdType "general")			;正面丝印 注册命令
axlCmdRegister("funckey_silkscreenbot" 'funckey_silkscreenbot ?cmdType "general")			;背面丝印 注册命令
axlCmdRegister("funckey_silkscreenclean" 'funckey_silkscreenclean ?cmdType "general")		;关闭丝印 注册命令
axlCmdRegister("funckey_via" 'funckey_via ?cmdType "general")								;开关过孔 注册命令
axlCmdRegister("funckey_placement" 'funckey_placement ?cmdType "general")					;器件布局+3D 注册命令
axlCmdRegister("funckey_all" 'funckey_all ?cmdType "general")								;ALL 注册命令


/*
###########################################################
#                 设置Funckey快捷键                       #
###########################################################
*/
axlCmdRegister("z+27" 'turnonassemblytop ?cmdType "general")	;快捷键z+27：开关assemblytop层
axlCmdRegister("z +27" 'turnonassemblytop ?cmdType "general")
axlCmdRegister("z+30" 'turnonassemblybot ?cmdType "general")	;快捷键z+30：开关assemblybot层
axlCmdRegister("z +30" 'turnonassemblybot ?cmdType "general")
axlCmdRegister("z+31" 'turnondisplaytop ?cmdType "general")		;快捷键z+31：开关displaytop层
axlCmdRegister("z +31" 'turnondisplaytop ?cmdType "general")
axlCmdRegister("z+32" 'turnondisplaybot ?cmdType "general")		;快捷键z+32：开关displaybot层
axlCmdRegister("z +32" 'turnondisplaybot ?cmdType "general")
axlSetFunckey( "po" "settoggle no_etch_shape_display;redraw")	;快捷键po：显示/隐藏铜皮
axlSetFunckey( "g" "changeshape")		;快捷键g：赋予铜皮网络
axlSetFunckey( "zz" "Z1 2 3 4 5 6")		;快捷键zz：显示1-6层
axlSetFunckey( "ZZ" "Z1 2 3 4 5 6")		;快捷键ZZ：显示1-6层
axlSetFunckey( "ss" "search")			;快捷键ss：搜索
axlSetFunckey( "SS" "search")			;快捷键ss：搜索

;设置数字Funckey快捷键
axlSetFunckey( "1" "Z1")		;设置快捷键1：显示第1层
axlSetFunckey( "2" "Z2")		;设置快捷键2：显示第2层
axlSetFunckey( "3" "Z3")		;设置快捷键3：显示第3层
axlSetFunckey( "4" "Z4")		;设置快捷键4：显示第4层
axlSetFunckey( "5" "funckey_silkscreentop")		;设置快捷键5：正面丝印
axlSetFunckey( "6" "funckey_silkscreenbot")		;设置快捷键6：背面丝印
axlSetFunckey( "7" "funckey_silkscreenclean")	;设置快捷键7：关闭丝印
axlSetFunckey( "8" "funckey_via")				;设置快捷键8：开关过孔
axlSetFunckey( "9" "funckey_placement")			;设置快捷键9：器件布局+3D
axlSetFunckey( "0" "funckey_all")				;设置快捷键0：ALL




;功能实现程序
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
