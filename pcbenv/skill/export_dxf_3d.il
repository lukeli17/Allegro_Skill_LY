axlCmdRegister("exportcurrent" 'export_current ?cmdType "general")	;导出当前显示DXF 命令
axlCmdRegister("exporttopbotdxf" 'export_topbotdxf ?cmdType "general")	;导出正反丝印DXF 命令
axlCmdRegister("exportjiegou" 'export_jiegou ?cmdType "general")	;导出结构确认文件 2D+3D 命令


;############## 导出当前显示的DXF ##############
defun( export_current ()
	export_dxf(axlCurrentDesign())	;传输当前PCB文件名给 导出DXF程序
)

;############## 导出正反丝印DXF ##############
defun( export_topbotdxf ()
	vis_list = axlVisibleGet()	;储存当前显示层面信息
	;显示正面丝印层
	axlVisibleDesign( nil)
	axlVisibleLayer( "PIN/SOLDERMASK_TOP", t)
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
	axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_TOP", t)
	axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_TOP", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_TOP", t)
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP", t)
	axlVisibleUpdate( t)
	export_dxf(strcat(axlCurrentDesign(), "_TOP"))	;传输DXF文件名
	;显示背面丝印层
	axlVisibleDesign( nil)
	axlVisibleLayer( "PIN/SOLDERMASK_BOTTOM", t)
	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE", t)
	axlVisibleLayer( "BOARD GEOMETRY/SILKSCREEN_BOTTOM", t)
	axlVisibleLayer( "BOARD GEOMETRY/SOLDERMASK_BOTTOM", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM", t)
	axlVisibleLayer( "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM", t)
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM", t)
	axlVisibleUpdate( t)
	export_dxf(strcat(axlCurrentDesign(), "_BOT"))	;传输DXF文件名
	axlVisibleSet(vis_list)
	axlVisibleUpdate(t)
)

;############## 导出结构确认文件 2D+3D ##############
defun( export_jiegou ()
	vis_list = axlVisibleGet()	;储存当前显示层面信息
	export_topbotdxf()	;调用导出正反丝印DXF程序
	export_3d()	;调用导出3D程序
	jiegoufile_move(axlCurrentDesign())	
	axlVisibleSet(vis_list)
	axlVisibleUpdate(t)
)


;#############################################
;#############################################
;--------------底下为子程序-------------------
;#############################################
;#############################################


;-------------- 文件整理程序 -----------
defun(	jiegoufile_move (design_name)
	filename = strcat(axlCurrentDesign(), "_\275\341\271\271")	;filename：要新建的文件夹名字
	;创建文件整理的批处理脚本：filemove.bat
	p = outfile("filemove.bat\n")
		fprintf(p "md %s\n" filename)		;建立文件夹
		fprintf(p "md %s\\2D\n" filename)	;文件夹下再建立2D
		fprintf(p "md %s\\3D\n" filename)	;文件夹下再建立3D
		fprintf(p "md LAJI\n" filename)	;文件夹下再建立3D
		;移动DXF文件
		fprintf(p "move	%s_TOP.dxf	%s\\2D\n" design_name filename)
		fprintf(p "move	%s_BOT.dxf	%s\\2D\n" design_name filename)
		;移动3D文件
		fprintf(p "move	%s.emn	%s\\3D\n" design_name filename)
		fprintf(p "move	%s.emp	%s\\3D\n" design_name filename)
		fprintf(p "move	*.cnv	LAJI\n")	;删除导出过程产生的cnv文件
		fprintf(p "move	*.log	LAJI\n")	;删除导出过程产生的log文件
		fprintf(p "move	*.scr	LAJI\n")	;删除导出过程产生的脚本文件
		fprintf(p "move	*.config	LAJI\n")	;删除导出过程产生的脚本文件
		;fprintf(p "pause\n")
		fprintf(p "del	filemove.bat\n")	;文件整理的脚本运行后自动删除
		close(p)
	axlShell("system filemove.bat")
)

;--------- 导出DXF文件程序 ---------
defun(	export_dxf (filename)
	;创建导出DXF的脚本文件：exportdxf.scr
	p = outfile("exportdxf.scr\n")
		fprintf(p "setwindow pcb\n")
		fprintf(p "dxf out \n")
		fprintf(p "setwindow form.dxf_out\n")
		fprintf(p "FORM dxf_out browsedxf\n")
		fprintf(p "fillin \"%s.dxf\"\n" filename)
		fprintf(p "FORM dxf_out browselayer \n")
		fprintf(p "fillin \"%s_l.cnv\"\n" filename)
		fprintf(p "FORM dxf_out edit \n")
		fprintf(p "setwindow form.dxfOutMapping\n")
		fprintf(p "FORM dxfOutMapping selectall YES\n")
		fprintf(p "FORM dxfOutMapping usedefaultlayernames YES \n")
		fprintf(p "FORM dxfOutMapping map \n")
		fprintf(p "FORM dxfOutMapping done\n")
		fprintf(p "setwindow form.dxf_out\n")
		fprintf(p "FORM dxf_out execute \n")
		fprintf(p "FORM dxf_out close\n")
		fprintf(p "setwindow pcb\n")
		close(p)
	axlShell("replay exportdxf.scr")
	deleteFile("exportdxf.scr")	;运行后删除产生的脚本文件
	deleteFile(strcat(filename, "_l.cnv"))	;删除导出DXF的层文件
)

;---------- 导出emn,emp文件程序 -------------
defun(	export_3d ()
	axlVisibleDesign( nil)
	;打开正背面丝印层显示，及PLACE_BOUND层
	axlVisibleLayer( "PIN/TOP", t)
	axlVisibleLayer( "PIN/BOTTOM", t)
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
	;创建导出3D的脚本文件：export3d.scr
	p = outfile("export3d.scr\n")
		fprintf(p "setwindow pcb\n")
		fprintf(p "idf out \n")
		fprintf(p "setwindow form.idf_out\n")
		fprintf(p "FORM idf_out formatfield PTC \n")
		fprintf(p "FORM idf_out heightfield 1 \n")	;没有高度的器件，默认高度设为1MM
		fprintf(p "FORM idf_out use_filter YES \n")
		fprintf(p "FORM idf_out filter\n")
		fprintf(p "setwindow form.idfout_filter\n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Route Keepout' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Route Keepout' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' Pins \n")
		fprintf(p "FORM idfout_filter filter_tree  Pins \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Via Keepout' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Via Keepout' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' Vias \n")
		fprintf(p "FORM idfout_filter filter_tree  Vias \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Panel Outline' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Panel Outline' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Route Outline' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Route Outline' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Package Keepin' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Package Keepin' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Package Keepout'\n")
		fprintf(p "FORM idfout_filter filter_tree  'Package Keepout' \n")
		fprintf(p "FORM idfout_filter filter_tree 'MULTISEL YES' 'Unplaced Components' \n")
		fprintf(p "FORM idfout_filter filter_tree  'Unplaced Components' \n")
		fprintf(p "FORM idfout_filter filter_ok  \n")
		fprintf(p "setwindow form.idf_out\n")
		fprintf(p "FORM idf_out execute  \n")
		fprintf(p "fillin \"iDfFilterOut.config\"\n")
		fprintf(p "FORM idf_out cancel  \n")
		fprintf(p "setwindow pcb\n")
		
		close(p)
	axlShell("replay export3d.scr")
	deleteFile("export3d.scr") ;运行后删除产生的脚本文件
)
