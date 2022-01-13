;#################此skill用来编写测试代码#################
;	按F11键重新加载此测试skill
;	按F12键运行test命令

axlCmdRegister( "skilltest" '_skill_test)

defun( _skill_test ()
   
	;axlFormDisplay(Form1)
	axlUIViewFileCreate("test.txt" "TEST" nil)
)
