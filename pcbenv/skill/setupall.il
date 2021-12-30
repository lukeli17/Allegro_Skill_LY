axlCmdRegister("setupall" 'setupall ?cmdType "general")


procedure(setupall()
let( ()
                axlShell("replay setupall.scr")
        )
)


axlSetAlias( "~0" "setupall")	;设置快捷键 Ctrl键+0