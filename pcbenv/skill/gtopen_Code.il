;--------创建焊盘--------
;	2019-05-15：首板

;---------------

procedure( gtopen_create_pad()
let((form)

	form = gtopen_create_pad_createform()
	gtopen_create_pad_int_var(form)
	gtopen_create_pad_update_form(form)

)
)


procedure( gtopen_create_pad_createform()
let((file form)
	file = "gtopen_create_pad.form"
	when(boundp('createpad_form)
		when(axlIsFormType(eval('createpad_form))
			axlFormClose(eval('createpad_form))
		)
	)
	form = axlFormCreate('createpad_form file nil 'gtopen_create_pad_CB t)
	form
	
)
)

procedure( gtopen_create_pad_int_var(form)
let(()
	
	form->pop = ncons(nil)
	form->pop->padtype = list(
		list("\261\355\314\371" "padtype_smd")
		list("\315\250\277\327" "padtype_hole")
		list("\271\375\277\327" "padtype_via")
	)
	form->var = ncons(nil)
	form->var->padtype = cadar(form->pop->padtype)
	
	form->var->rec_pad = t
	form->var->unitsel = "mil"
	form->var->pad_name = "smd100_80"
	form->var->value_W = 100.
	form->var->value_H = 80.
	form->var->value_D1 = 40.
	form->var->value_D2 = 60.
	form->var->sold_val = 4.
	
	form->var->cir_cir_hole = t
	
	form->vis = ncons(nil)
	form->vis->rec_pad = 1
	form->vis->cir_pad = 1
	form->vis->obl_pad = 1
	form->vis->cir_cir_hole = 0
	form->vis->cir_Rec_hole = 0
	form->vis->cir_oval_hole = 0
	form->vis->oval_oval_hole = 0
	form->vis->nth_hole = 0
	
	form->vis->W_name = 1
	form->vis->value_W = 1
	form->vis->H_name = 1
	form->vis->value_H = 1
	form->vis->D1_name = 0
	form->vis->value_D1 = 0
	form->vis->D2_name = 0
	form->vis->value_D2 = 0
t
)
)


procedure( gtopen_create_pad_CB(form)
let((SavePath tt)
	case(form->curField
		("pad_name" | "value_W" | "value_H" | "value_D1" | "value_D2" | "sold_val"
			evalstring(sprintf(nil "form->var->%s = %L" form->curField form->curValue))
			when(form->curField == "pad_name"
				form->var->pad_name = lowerCase(form->curValue)
			)
		)
		("unitsel"
			form->var->value_W = axlMKSConvert(form->var->value_W form->var->unitsel form->curValue)
			form->var->value_H = axlMKSConvert(form->var->value_H form->var->unitsel form->curValue)
			form->var->value_D1 = axlMKSConvert(form->var->value_D1 form->var->unitsel form->curValue)
			form->var->value_D2 = axlMKSConvert(form->var->value_D2 form->var->unitsel form->curValue)
			form->var->sold_val = axlMKSConvert(form->var->sold_val form->var->unitsel form->curValue)
			form->var->unitsel = form->curValue
		)
		("rec_pad" | "cir_pad" | "obl_pad"
			foreach(n0 list("rec_pad" "cir_pad" "obl_pad")
				evalstring(sprintf(nil "form->var->%s = axlFormGetField(form %L)" n0 n0))
			)
		)
		("cir_cir_hole" | "cir_Rec_hole" | "cir_oval_hole" | "oval_oval_hole" | "nth_hole"
			foreach(n0 list("cir_cir_hole" "cir_Rec_hole" "cir_oval_hole" "oval_oval_hole" "nth_hole")
				evalstring(sprintf(nil "form->var->%s = axlFormGetField(form %L)" n0 n0))
			)
		)
		("cpad"
			SavePath = axlDMDirectoryBrowse("." t ?title "Pick a directory")
			when(SavePath
				tt = gtopen_create_pad_CreateAction(form)
				when(tt
					axlOSFileMove(tt strcat(SavePath "/" tt))
				)
			)
		)
		("padtype"
			form->var->padtype = form->curValue
			form->var->sold_val = 4.
			form->var->rec_pad = t
			form->var->cir_pad = nil
			form->var->obl_pad = nil
			form->var->cir_cir_hole = t
			form->var->cir_Rec_hole = nil
			form->var->cir_oval_hole = nil
			form->var->oval_oval_hole = nil
			form->var->nth_hole = nil
			
			case(form->curValue
				("padtype_smd"
					form->vis->rec_pad = 1
					form->vis->cir_pad = 1
					form->vis->obl_pad = 1
					form->vis->cir_cir_hole = 0
					form->vis->cir_Rec_hole = 0
					form->vis->cir_oval_hole = 0
					form->vis->oval_oval_hole = 0
					form->vis->nth_hole = 0
				)
				("padtype_hole"
					form->vis->rec_pad = 0
					form->vis->cir_pad = 0
					form->vis->obl_pad = 0
					form->vis->cir_cir_hole = 1
					form->vis->cir_Rec_hole = 1
					form->vis->cir_oval_hole = 1
					form->vis->oval_oval_hole = 1
					form->vis->nth_hole = 1
				)
				("padtype_via"
					form->vis->rec_pad = 0
					form->vis->cir_pad = 0
					form->vis->obl_pad = 0
					form->vis->cir_cir_hole = 0
					form->vis->cir_Rec_hole = 0
					form->vis->cir_oval_hole = 0
					form->vis->oval_oval_hole = 0
					form->vis->nth_hole = 0
					form->var->sold_val = 0.
				)
			)
		)
	)
	unless(form->curField == ""
		gtopen_create_pad_update_form(form)
	)
t
)
)


procedure( gtopen_create_pad_update_form(form)
let((tt)
	
	form->var->W_name = "W"
	form->var->H_name = "H"
	case(form->var->padtype
		("padtype_smd"
			form->vis->D1_name = 0
			form->vis->value_D1 = 0
			form->vis->D2_name = 0
			form->vis->value_D2 = 0
			if(form->var->cir_pad then
				form->vis->H_name = 0
				form->vis->value_H = 0
			else
				form->vis->H_name = 1
				form->vis->value_H = 1
			)
		)
		("padtype_hole"
			form->vis->W_name = 1
			form->vis->value_W = 1
			form->vis->H_name = 1
			form->vis->value_H = 1
			form->vis->D1_name = 0
			form->vis->value_D1 = 0
			form->vis->D2_name = 0
			form->vis->value_D2 = 0
			cond(
				(form->var->cir_cir_hole
					form->var->W_name = "D0"
					form->vis->H_name = 0
					form->vis->value_H = 0
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->cir_Rec_hole
					form->vis->H_name = 0
					form->vis->value_H = 0
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->cir_oval_hole
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
				)
				(form->var->oval_oval_hole
					form->vis->D1_name = 1
					form->vis->value_D1 = 1
					form->vis->D2_name = 1
					form->vis->value_D2 = 1
				)
				(form->var->nth_hole
					form->vis->W_name = 0
					form->vis->value_W = 0
					form->var->H_name = "D1"
				)
			)
		)
		("padtype_via"
			form->var->W_name = "D0"
			form->var->H_name = "D1"
		)
	)
	
	gtopen_create_pad_RenamePad(form)
	foreach(n0 form->vis->?
		tt = member(n0 form->vis)
		axlFormSetFieldVisible(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->pop->?
		tt = member(n0 form->pop)
		axlFormBuildPopup(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	handle = axlGRPDrwInit(form "pad_view" 'gtopen_create_pad_GrawView)
	handle->form = form
	unless(member(form->curField list("pad_name" "unitsel" "value_W" "value_H" "value_D1" "value_D2" "sold_val" "cpad"))
		axlGRPDrwUpdate(handle)
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)

)
)


procedure( gtopen_create_pad_GrawView(handle)
let((form s_xy xy_l xy_r)
	form = handle->form
	cond(
		(form->var->padtype == "padtype_smd"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle '(0 0) '(200 200))
			cond(
				(form->var->rec_pad
					putprop(handle "red" 'color)
					axlGRPDrwRectangle(handle 40:60 160:140)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(40:50 40:30))
					axlGRPDrwLine(handle list(160:50 160:30))
					axlGRPDrwText(handle 90:30 "W")
					axlGRPDrwLine(handle list(170:60 190:60))
					axlGRPDrwLine(handle list(170:140 190:140))
					axlGRPDrwText(handle 175:90 "H")
				)
				(form->var->cir_pad
			    putprop(handle "red" 'color)
			    axlGRPDrwCircle(handle 100:100 65)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(35:70 35:10))
					axlGRPDrwLine(handle list(165:70 165:10))
					axlGRPDrwText(handle 90:10 "W")
				)
				(form->var->obl_pad
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 70:100 30)
					axlGRPDrwRectangle(handle 70:70 130:130)
					axlGRPDrwCircle(handle 130:100 30)
					putprop(handle "black" 'color)
					axlGRPDrwLine(handle list(40:60 40:30))
					axlGRPDrwLine(handle list(160:60 160:30))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(170:70 190:70))
					axlGRPDrwLine(handle list(170:130 190:130))
					axlGRPDrwText(handle 175:90 "H")
				)
			)
		)
		(form->var->padtype == "padtype_hole"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle 0:0 200:200)
			cond(
				(form->var->cir_cir_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 100:100 60)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(40:60 40:10))
					axlGRPDrwLine(handle list(160:60 160:10))
					axlGRPDrwText(handle 90:10 "D0")
					axlGRPDrwLine(handle list(80:170 80:190))
					axlGRPDrwLine(handle list(120:170 120:190))
					axlGRPDrwText(handle 90:170 "D1")
				)
				(form->var->cir_Rec_hole
					putprop(handle "red" 'color)
					axlGRPDrwRectangle(handle 40:40 160:160)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(40:30 40:10))
					axlGRPDrwLine(handle list(160:30 160:10))
					axlGRPDrwText(handle 90:10 "W")
					axlGRPDrwLine(handle list(80:170 80:190))
					axlGRPDrwLine(handle list(120:170 120:190))
					axlGRPDrwText(handle 90:170 "D1")
				)
				(form->var->cir_oval_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 60:100 30)
					axlGRPDrwCircle(handle 140:100 30)
					axlGRPDrwRectangle(handle 60:70 140:130)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 20)
					axlGRPDrwLine(handle list(30:60 30:40))
					axlGRPDrwLine(handle list(170:60 170:40))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(180:70 200:70))
					axlGRPDrwLine(handle list(180:130 200:130))
					axlGRPDrwText(handle 180:90 "H")
					axlGRPDrwLine(handle list(80:140 80:160))
					axlGRPDrwLine(handle list(120:140 120:160))
					axlGRPDrwText(handle 90:140 "D1")
				)
				(form->var->oval_oval_hole
					putprop(handle "red" 'color)
					axlGRPDrwCircle(handle 60:100 30)
					axlGRPDrwCircle(handle 140:100 30)
					axlGRPDrwRectangle(handle 60:70 140:130)
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 80:100 20)
					axlGRPDrwCircle(handle 120:100 20)
					axlGRPDrwRectangle(handle 80:80 120:120)
					axlGRPDrwLine(handle list(30:60 30:40))
					axlGRPDrwLine(handle list(170:60 170:40))
					axlGRPDrwText(handle 90:40 "W")
					axlGRPDrwLine(handle list(180:70 200:70))
					axlGRPDrwLine(handle list(180:130 200:130))
					axlGRPDrwText(handle 180:90 "H")
					axlGRPDrwLine(handle list(20:80 0:80))
					axlGRPDrwLine(handle list(20:120 0:120))
					axlGRPDrwText(handle 0:90 "D1")
					axlGRPDrwLine(handle list(60:140 60:160))
					axlGRPDrwLine(handle list(140:140 140:160))
					axlGRPDrwText(handle 90:140 "D2")
				)
				(form->var->nth_hole
					putprop(handle "black" 'color)
					axlGRPDrwCircle(handle 100:100 30)
					axlGRPDrwLine(handle list(140:70 160:70))
					axlGRPDrwLine(handle list(140:130 160:130))
					axlGRPDrwText(handle 140:90 "D1")
				)
			)
		)
		(form->var->padtype == "padtype_via"
			axlGRPDrwMapWindow(handle 200 200)
			putprop(handle "white" 'color)
			putprop(handle "filled" 'fill)
			axlGRPDrwRectangle(handle 0:0 200:200)
			putprop(handle "blue" 'color)
			axlGRPDrwCircle(handle 100:100 60)
			putprop(handle "black" 'color)
			axlGRPDrwCircle(handle 100:100 30)
			axlGRPDrwLine(handle list(40:60 40:10))
			axlGRPDrwLine(handle list(160:60 160:10))
			axlGRPDrwText(handle 90:10 "D0")
			axlGRPDrwLine(handle list(170:70 190:70))
			axlGRPDrwLine(handle list(170:130 190:130))
			axlGRPDrwText(handle 170:90 "D1")
		)
		
	)
)
)


procedure( gtopen_create_pad_RenamePad(form)
let((ttW ttH ttD1 ttD2)
	case(form->var->padtype
		("padtype_smd"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
			)
			cond(
				(form->var->rec_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "smd%sm%s_%sm%s" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "smd%s_%s" car(ttW) car(ttH))
					)
				)
				(form->var->cir_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "ball%sm%s" car(ttW) cadr(ttW))
					else
						form->var->pad_name = sprintf(nil "ball%s" car(ttW))
					)
				)
				(form->var->obl_pad
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "smd%sm%s_%sm%sob" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "smd%s_%sob" car(ttW) car(ttH))
					)
				)
			)
		)
		("padtype_hole"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
				ttD1 = parseString(sprintf(nil "%.2f" form->var->value_D1) ".")
				ttD2 = parseString(sprintf(nil "%.2f" form->var->value_D2) ".")
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
				ttD1 = parseString(sprintf(nil "%.2f" form->var->value_D1) ".")
				ttD2 = parseString(sprintf(nil "%.2f" form->var->value_D2) ".")
			)
			cond(
				(form->var->cir_cir_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%scir%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "pad%scir%sd" car(ttW) car(ttH))
					)
				)
				(form->var->cir_Rec_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%ssq%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "pad%ssq%sd" car(ttW) car(ttH))
					)
				)
				(form->var->cir_oval_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%sx%sm%sob%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH) car(ttD1) cadr(ttD1))
					else
						form->var->pad_name = sprintf(nil "pad%sx%sob%sd" car(ttW) car(ttH) car(ttD1))
					)
				)
				(form->var->oval_oval_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "pad%sm%sx%sm%sob%sm%sx%sm%sd" car(ttW) cadr(ttW) car(ttH) cadr(ttH) car(ttD1) cadr(ttD1) car(ttD2) cadr(ttD2))
					else
						form->var->pad_name = sprintf(nil "pad%sx%sob%sx%sd" car(ttW) car(ttH) car(ttD1) car(ttD2))
					)
				)
				(form->var->nth_hole
					if(form->var->unitsel == "mm" then
						form->var->pad_name = sprintf(nil "npad%sm%scir" car(ttH) cadr(ttH))
					else
						form->var->pad_name = sprintf(nil "npad%scir" car(ttH))
					)
				)
			)
		)
		("padtype_via"
			if(form->var->unitsel == "mm" then
				ttW = parseString(sprintf(nil "%.2f" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%.2f" form->var->value_H) ".")
				form->var->pad_name = sprintf(nil "via%sm%s_%sm%s" car(ttW) cadr(ttW) car(ttH) cadr(ttH))
			else
				ttW = parseString(sprintf(nil "%L" form->var->value_W) ".")
				ttH = parseString(sprintf(nil "%L" form->var->value_H) ".")
				form->var->pad_name = sprintf(nil "via%s_%s" car(ttW) car(ttH))
			)
		)
	)
)
)

procedure( gtopen_create_pad_CreateAction(form)
let((ttW ttH ttD1 ttD2 ttS figure file)
	file = nil
	case(form->var->padtype
		("padtype_smd"
			if(form->var->unitsel == "mm" then
				ttW = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_H))
				ttS = axlMKS2UU(sprintf(nil "%.2f mm" form->var->sold_val))
			else
				ttW = axlMKS2UU(sprintf(nil "%L mil" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%L mil" form->var->value_H))
				ttS = axlMKS2UU(sprintf(nil "%L mil" form->var->sold_val))
			)
			cond(
				(form->var->rec_pad
					figure = 'RECTANGLE
					when(ttH == ttW
						figure = 'SQUARE
					)
				)
				(form->var->cir_pad
					figure = 'CIRCLE
					ttH = ttW
				)
				(form->var->obl_pad
					figure = 'OBLONG_X
				)
			)
	    pad_list = cons(make_axlPadStackPad(?layer "TOP" ?type 'REGULAR	
	    	?figure figure ?figureSize (ttW:ttH)) nil
	    )
	    pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR 
	    	?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
	    )
	    pad_list = cons(make_axlPadStackPad(?layer "PASTEMASK_TOP" ?type 'REGULAR	
	    	?figure figure ?figureSize (ttW:ttH)) pad_list
	    )
	    axlDBCreatePadStack(form->var->pad_name nil pad_list t)
			when(axlPadstackToDisk(form->var->pad_name)
				file = strcat(form->var->pad_name ".pad")
			)
		)
		("padtype_hole" | "padtype_via"
			if(form->var->unitsel == "mm" then
				ttW = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_H))
				ttD1 = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_D1))
				ttD2 = axlMKS2UU(sprintf(nil "%.2f mm" form->var->value_D2))
				ttS = axlMKS2UU(sprintf(nil "%.2f mm" form->var->sold_val))
			else
				ttW = axlMKS2UU(sprintf(nil "%L mil" form->var->value_W))
				ttH = axlMKS2UU(sprintf(nil "%L mil" form->var->value_H))
				ttD1 = axlMKS2UU(sprintf(nil "%L mil" form->var->value_D1))
				ttD2 = axlMKS2UU(sprintf(nil "%L mil" form->var->value_D2))
				ttS = axlMKS2UU(sprintf(nil "%L mil" form->var->sold_val))
			)
			drill_data = make_axlPadStackDrill(?drillDiameter ttD1 ?figure 'CIRCLE 
				?drillChar sprintf(nil "%L" ttD1) ?figureSize ttD1:ttD1 ?plating 'PLATED
			)
			cond(
				(form->var->cir_cir_hole || form->var->padtype == "padtype_via"
					figure = 'CIRCLE
					ttH = ttW
				)
				(form->var->cir_Rec_hole
					figure = 'SQUARE
					ttH = ttW
				)
				(form->var->cir_oval_hole
					figure = 'OBLONG_X
				)
				(form->var->oval_oval_hole
					figure = 'OBLONG_X
			    drill_data = make_axlPadStackDrill(?holeType 'OVAL_SLOT ?slotSize ttD2:ttD1
				    ?figure 'OBLONG_X ?drillChar sprintf(nil "%L" ttD1) ?plating 'PLATED
				  )
				)
				(form->var->nth_hole
					drill_data = make_axlPadStackDrill(?drillDiameter ttD1 ?figure 'CIRCLE 
						?drillChar sprintf(nil "%L" ttD1) ?figureSize ttD1:ttD1 ?plating 'NON_PLATED
					)
					figure = 'CIRCLE
					ttD1 = ttH
					ttW = ttH
				)
			)
			pad_list = cons(make_axlPadStackPad(?layer "TOP" ?type 'REGULAR	
				?figure figure ?figureSize ttW:ttH) nil
			)
			pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL" ?type 'REGULAR 
				?figure figure ?figureSize ttW:ttH) pad_list
			)
			pad_list = cons(make_axlPadStackPad(?layer "BOTTOM" ?type 'REGULAR 
				?figure figure ?figureSize ttW:ttH) pad_list
			)
			unless(ttS == 0
				pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR 
					?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
				)
				pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM" ?type 'REGULAR	
					?figure figure ?figureSize (ttW+ttS):(ttH+ttS)) pad_list
				)
			)
			axlDBCreatePadStack(form->var->pad_name drill_data pad_list t)
			when(axlPadstackToDisk(form->var->pad_name)
				file = strcat(form->var->pad_name ".pad")
			)
		)
	)
	file
)
)

;--------导入LOGO--------
;
;---------------

axlCmdRegister("gtopen_Logo" 'gtopen_Logo ?cmdType "interactive")
procedure( gtopen_Logo()
let((form)
	
	axlShell("noappmode")
	form = gtopen_Logo_Createform()
	gtopen_Logo_Int_Var(form)
	gtopen_Logo_Update_form(form)
)
)




procedure( gtopen_Logo_Createform()
let((file form)
	file = "gtopen_Logo.form"
	when('gtopen_Logoform && boundp('gtopen_Logoform)
		when(axlIsFormType(eval('gtopen_Logoform))
			axlFormClose(eval('gtopen_Logoform))
		)
	)
	
	form = axlFormCreate('gtopen_Logoform file nil 'gtopen_Logo_CB t)
	
	form
)
)


procedure( gtopen_Logo_Int_Var(form)
let((_getFontList)
	form->pop = ncons(nil)
	form->pop->layerclass = list("BOARD GEOMETRY" "PACKAGE GEOMETRY" "MANUFACTURING" "ETCH" "DRAWING FORMAT")

	
	form->var = ncons(nil)
	form->var->layerclass = "PACKAGE GEOMETRY"
	form->var->layersubclass = "SILKSCREEN_TOP"
	form->var->pic_size = 1
	form->var->neg = nil
)
)


procedure( gtopen_Logo_CB(form)
prog((tt bmp_show Blockw Blockh width height pixel_size box pick)
	case(form->curField
		("layerclass"
			form->var->layerclass = form->curValue
			form->var->layersubclass = car(axlSubclasses(form->var->layerclass))
		)
		("layersubclass" | "neg" | "pic_size"
			evalstring(sprintf(nil "form->var->%s = form->curValue" form->curField))
		)
		("vis"
			if(form->curValue then
				axlVisibleLayer(strcat(form->var->layerclass "/" form->var->layersubclass) t)
			else
				axlVisibleLayer(strcat(form->var->layerclass "/" form->var->layersubclass) nil)
			)
			axlVisibleUpdate(t)
		)
		("load"
			tt = axlDMFileBrowse("\321\241\324\361\315\274\306\254" nil ?optFilters "BMP Files(*.bmp)|*.bmp")
			when(tt
				if(isFile(tt) && member(upperCase(lastelem(axlDMFileParts(tt))) list("BMP")) then
					form->var->bmpinput = tt
				else
					printf(">>\262\273\326\247\263\326\315\274\306\254\270\361\312\275\n")
				)
			)
		)
		("place"
			when(form->bmpdate
				tt = axlGetParam(sprintf(nil "paramTextBlock:%d" form->var->pic_size))
				Blockw = tt->width
				Blockh = tt->height
				width = (form->bmpdate[21] << 24) + (form->bmpdate[20] << 16) + (form->bmpdate[19] << 8) + form->bmpdate[18]
				height = (form->bmpdate[25] << 24) + (form->bmpdate[24] << 16) + (form->bmpdate[23] << 8) + form->bmpdate[22]
				pixel_size = max(Blockw/width Blockh/height)
				box = list(list(0 0) list(width*pixel_size height*pixel_size))
				axlClearDynamics()
				axlAddSimpleMoveDynamics(0:0 axlPathStart(box) "box" ?ref_point 0:0)
				pick = axlEnterPoint()
				axlClearDynamics()
				when(pick
					axlDBCloak(gtopen_Logo_addshape(form pick) 'shape)
				)
			)
		)
		("textset"
			axlShell("define text")
		)
		(t
			return(t)
		)
	)
	gtopen_Logo_Update_form(form)
)
)

procedure( gtopen_Logo_Update_form(form)
let((tt port bmpdate)

	form->pop->layersubclass = nil
	foreach(n0 axlSubclasses(form->var->layerclass)
		when(axlIsLayer(buildString(list(form->var->layerclass n0) "/"))
			form->pop->layersubclass = cons(list(n0 n0 axlLayerGet(buildString(list(form->var->layerclass n0) "/"))->color) form->pop->layersubclass)
		)
	)
	tt = axlLayerGet(strcat(form->var->layerclass "/" form->var->layersubclass))
	if(tt->visible then
		form->var->vis = tt->color
		axlFormSetField(form "vis" t)
	else
		form->var->vis = 0
		axlFormSetField(form "vis" nil)
	)
	
	foreach(n0 form->pop->?
		tt = member(n0 form->pop)
		axlFormBuildPopup(form symbolToString(car(tt)) cadr(tt))
	)
	foreach(n0 form->var->?
		tt = member(n0 form->var)
		axlFormSetField(form symbolToString(car(tt)) cadr(tt))
	)
	when(form->curField == "load" && form->var->bmpinput
		form->bmpsize = fileLength(form->var->bmpinput)
		axlFormSetField(form "bmp_show" form->var->bmpinput)
		port = infile(form->var->bmpinput)
		declare(bmpdate[form->bmpsize])
		for(i 0 form->bmpsize-1
			bmpdate[i] = charToInt(getc(port))
		)
		close(port)
		form->bmpdate = bmpdate
	)
	if(form->var->bmpinput then
		axlFormSetFieldEditable(form "place" t)
	else
		axlFormSetFieldEditable(form "place" nil)
	)
	axlFormAutoResize(form)
	axlFormDisplay(form)
)
)

procedure( gtopen_Logo_addshape(form pickxy)
prog((tt Blockw Blockh number num row max_column column max_w bit x y offset width height Grid imagesize path polys symbolid)
	tt = axlGetParam(sprintf(nil "paramTextBlock:%d" form->var->pic_size))
	Blockw = tt->width
	Blockh = tt->height
	
	offset = (form->bmpdate[13] << 24) + (form->bmpdate[12] << 16) + (form->bmpdate[11] << 8) + form->bmpdate[10]
	width = (form->bmpdate[21] << 24) + (form->bmpdate[20] << 16) + (form->bmpdate[19] << 8) + form->bmpdate[18]
	height = (form->bmpdate[25] << 24) + (form->bmpdate[24] << 16) + (form->bmpdate[23] << 8) + form->bmpdate[22]
	imagesize = form->bmpsize - offset
	
	max_column = (imagesize / height) << 3
	max_w = (imagesize / width) << 3
	number = offset + imagesize - 1
	Grid = 1/min(width/Blockw height/Blockh)
	column = 0
	polys = '()
	if(!axlSelectByName("SYMTYPE" "GTLogo") then
    axlDBCreateSymDefSkeleton(list("GTLogo" "mechanical") list(list(0 0) list(width height)))
	else
	  axlClearSelSet()
	)
	symbolid = car(axlDBCreateSymbolSkeleton(list("GTLogo" "mechanical") pickxy nil 0.0 nil))
	axlMeterCreate("\275\370\263\314\326\320" "" t)
	for(i offset number
		tt = fix((50*i) / (imagesize-1))
		when(tt == 12 || tt == 25 || tt == 37 || tt == 50
			axlMeterUpdate(tt sprintf(nil "\315\352\263\311\266\310 :%d / %d" (i-offset) (imagesize-1)))
		)
		
		y = Grid * fix((i - offset) / (max_column >> 3)) + cadr(pickxy)
		for(j 0 7
	    bit = bitfield1(form->bmpdate[i] (7 - j))
	    when(form->var->neg
	    	bit = abs(bit-1)
	    )
	    x = Grid * column + car(pickxy)
			when(zerop(bit) && (column < width)
				path = axlPathStart(list(x:y))
				axlPathLine(path 0.0 x:(y+1.1*Grid))
				axlPathLine(path 0.0 (x+1.1*Grid):(y+1.1*Grid))
				axlPathLine(path 0.0 (x+1.1*Grid):y)
				axlPathLine(path 0.0 x:y)
				polys = append(axlPolyFromDB(path) polys)
			)
	    column++
		)
		when(column == max_column
	    column = 0
		)
	)
	polys = axlPolyOperation(car(polys) cdr(polys) 'OR)
	num = 1
	foreach(n0 polys
		tt = fix((50*num) / length(polys)) + 50
		when(tt == 62 || tt == 75 || tt == 87 || tt == 100
			axlMeterUpdate(tt sprintf(nil "\315\352\263\311\266\310 :%d / %d" num length(polys)))
		)
		tt = axlDBCreateShape(n0 t strcat(form->var->layerclass "/" form->var->layersubclass) nil symbolid)
		axlCustomColorObject(car(tt) 0)
		num++
	)
	axlMeterDestroy()
	axlVisibleUpdate(t)
	
)
)


/* 
axlCmdRegister("gtopen_Logo" 'gtopen_Cline2Shape ?cmdType "interactive")
procedure( gtopen_Cline2Shape()
let((form)
	
;	axlShell("noappmode")
	form = gtopen_Cline2Shape_Createform()
	gtopen_Cline2Shape_Int_Var(form)
	gtopen_Cline2Shape_Update_form(form)
)
)

procedure( gtopen_Cline2Shape_Createform()
let((file form)
	file = "gtopen_Cline2Shape.form"
	when('gtopen_Logoform && boundp('gtopen_Cline2Shapeform)
		when(axlIsFormType(eval('gtopen_Cline2Shapeform))
			axlFormClose(eval('gtopen_Cline2Shapeform))
		)
	)
	
	form = axlFormCreate('gtopen_Cline2Shapeform file nil 'gtopen_Cline2Shape_CB t)
	
)
)

procedure( gtopen_Cline2Shape_CB(form)
let(()
	println(form->curField)
	case(form->curField
		(
		
		)
	)

)
)

 */