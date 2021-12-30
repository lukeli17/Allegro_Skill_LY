/*****************************************************/
/*	Title :  Check_No_Refdes		*/
/*	Execute Command :  Ch_NoRef	*/
/*	Creation Date :  2021-08-01		*/
/*****************************************************/

axlCmdRegister( "Ch_NoRef" 'Check_No_Refdes)

defun( Check_No_Refdes ()

        axlVisibleDesign(nil)
 	axlVisibleLayer( "BOARD GEOMETRY/OUTLINE" t )
	axlVisibleLayer( "PIN/TOP" t )
	axlVisibleLayer( "PIN/BOTTOM" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer( "REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer( "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )

	logfile="./no_refdes.log"
	rep_file=outfile(logfile)
	fprintf(rep_file "\tCheck the component without refdes . \n\n")
	fprintf(rep_file "REF_DES  COORDIRATION\n")

	setq(allsym axlDBGetDesign()->symbols)
	axlDehighlightObject(allsym)
	noref = nil
	norefcnt = 0
	foreach(symbol allsym 
		text= axlDBGetAttachedText(symbol)
		txt = nil
		foreach(find text
			if(find->layer == "REF DES/SILKSCREEN_TOP" || 
			find->layer == "REF DES/SILKSCREEN_BOTTOM" then 									
				txt = find			
			)								
		)
		if(txt == nil && symbol->refdes != nil then 
			axlHighlightObject(symbol)
			fprintf(rep_file "%-8s %L\n" symbol->refdes symbol->xy)
			;noref = cons(symbol->refdes noref)
			++norefcnt
		)
	);foreach-end
	fprintf(rep_file "\nTotal of no refdes: %d\n" norefcnt)
	close(rep_file)
	axlMsgPut("Total component without refdes: %d\n" norefcnt)
	axlMsgPut("Components missing refdes , please view logfile.")  
	axlUIViewFileCreate(logfile "Components without refdes" nil)
	
 

);defun_end


