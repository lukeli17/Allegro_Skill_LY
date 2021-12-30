/*
###########################################################
#              		垃圾文件自动清理程序                  #
del /?		删除一个或数个文件
rd  /？		删除一个目录
md	/？		新建一个目录
move	/？	移动
/P 删除每一个文件之前提示确认。
/F 强制删除只读文件。
/S 从所有子目录删除指定文件。
/Q 安静模式。删除全局通配符时，不要求确认。
		##原论坛代码，在此基础上修改##
		p = axlDMOpenFile("TEMP" "./temp.bat" "w")
		fprintf(p "del /f /s /q ".\\*.art"\n")  ;向temp.bat中写入删除语句：del /f /s /q ".\*.art"，删除当前目录下后缀为.art的文件
		fprintf(p "del /f /s /q ".\\*.log"\n")  ;删除当前目录下后缀为.lon的文件
		fprintf(p "del /f /s /q ".\\*.tag"\n")  ;删除当前目录下后缀为.tag的文件
		fprintf(p "del /f /s /q ".\\*.drl"\n")  ;删除当前目录下后缀为.drl的文件
		fprintf(p "del /f /s /q ".\\*.dxf"\n")  ;删除当前目录下后缀为.dxf的文件
		fprintf(p "del /f /s /q ".\\*.ipc"\n")  ;删除当前目录下后缀为.ipc的文件
		fprintf(p "del /f /s /q ".\\*.jrl,1"\n") ;删除当前目录下后缀为.jrl,1的文件
		fprintf(p "del /f /s /q ".\\art_aper.txt"\n") ;删除当前目录下的art_aper.txt
		fprintf(p "del /f /s /q ".\\art_param.txt"\n") ;删除当前目录下的art_param.txt
		fprintf(p "del /f /s /q ".\\nc_param.txt"\n")  ;删除当前目录下的nc_param.txt
		fprintf(p "rd /s /q signoise.run\n") ;删除当前目录下的signoise.run文件夹
		fprintf(p "del /s /q temp.bat\n")
		fprintf(p "echo\n")	
###########################################################
*/


axlCmdRegister("file_autoclear" 'fileautoclear ?cmdType "general")
;注册allegro命令"File_autoclear",调用函数"File_autoclear"，命令类型为"general",当调用命令时会立即执行命令，立即停止allegro当前正在执行的命令。
defun( fileautoclear ()
		;在当前目录创建打开一个批处理文件"temp.bat"
		p = outfile("temp.bat")	;在当前目录新建一个批处理文件temp.bat，并写入内容
			fprintf(p "md LAJI\n")	;新建文件夹LAJI，已存在则忽略
			;移动相应后缀的文件至LAJI文件夹
			fprintf(p "move	*.log	LAJI\n")
			fprintf(p "move	*.dbk	LAJI\n")
			fprintf(p "move	*.bak	LAJI\n")
			fprintf(p "move	*.jrl	LAJI\n")
			fprintf(p "move	*.cnv	LAJI\n")
			fprintf(p "move	*.config	LAJI\n")
			fprintf(p "move *.scr	LAJI\n")
			fprintf(p "move *.xml	LAJI\n")
			fprintf(p "move *.dml	LAJI\n")
			fprintf(p "move *.iml	LAJI\n")
			fprintf(p "move *.did	LAJI\n")
			fprintf(p "move *.lst	LAJI\n")
			fprintf(p "move *.rep	LAJI\n")
			fprintf(p "move *.rpt	LAJI\n")
			fprintf(p "move *.sts	LAJI\n")
			fprintf(p "move *.tag	LAJI\n")
			fprintf(p "move *.form	LAJI\n")
			;移动导出geber生成的几个txt文件
			fprintf(p "move	eco.txt		LAJI\n")
			fprintf(p "move art_param.txt	LAJI\n")
			fprintf(p "move nc_param.txt	LAJI\n")
			fprintf(p "move	nc_tools_auto.txt	LAJI\n")
			fprintf(p "move	ncroutebits_auto.txt	LAJI\n")
			fprintf(p "move \"*.txt,?\"	LAJI\n")	;移动后缀为txt,?的文件，？可为任意数字
			fprintf(p "move signoise.run	LAJI\n")
			;fprintf(p "pause\n")		;暂停
			fprintf(p "del /s /q temp.bat\n")	;所有命令执行结束后，删除生成的批处理文件temp.bat
		close(p)	;关闭temp.bat文件
		axlShell("system temp.bat")	;运行生成的temp.bat文件
);endof_defun



/*原程序----只删除，删除后无法恢复		
		md LAJI
		move	*.log  	LAJI
		move	*.dbk	LAJI
		move	*.jrl	LAJI
		move	*.cnv	LAJI
		move 	*.scr	LAJI
		move 	*.xml	LAJI
		move 	*.dml	LAJI
		move 	*.tag	LAJI
		move 	*.form	LAJI

procedure( CleanUselessfile()
	shell("
			del /f /s /q  *.log
			del /f /s /q  *.dbk
			del /f /s /q  *.jrl
			del /f /s /q  *.cnv
			del /f /s /q  *.scr
			del /f /s /q  *.xml
			del /f /s /q  *.dml
			del /f /s /q  *.tag
			del /f /s /q  *.form
			rd /s /q signoise.run
	")
)
*/
