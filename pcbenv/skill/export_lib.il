;支持多选、Find面板过滤功能。导出器件保存在当前工作目录下。


axlCmdRegister( "libbypick" '_ExportLibByPick)

defun( _ExportLibByPick ()
prog(( l_ok, l_sym, l_fg, def)

  axlSetFindFilter( ?enabled list( "NOALL" "SYMBOLS" "NAMEFORM")
                    ?onButtons list( "NOALL" "SYMBOLS"))
  axlSelect()
  l_ok = nil
  l_sym = axlGetSelSet()
  while( l_sym
         l_ok = append1( l_ok, car( l_sym))
         def = car( l_sym) -> definition
         l_fg = nil
         foreach( symbol l_sym
                  if( symbol -> definition != def then
                      l_fg = append1( l_fg, symbol)
                    );end-if
                );end-foreach
         if( l_fg then
             l_sym = l_fg
           else
             l_sym = nil
           );end-if     
       );end-while
  foreach( symbol l_ok
           axlWritePackageFile( symbol -> definition)
           if( symbol -> component then
               axlWriteDeviceFile( symbol -> component -> compdef)
             );end-if           
         );end-foreach
  axlClearSelSet()       
);end-prog
);end-defun

