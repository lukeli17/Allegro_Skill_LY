;
;FileName:        
;Load:                load("fCS.il")
;Command:        cs
;
;功能:比較兩個PCB的Symbols差異
;使用方法:
;        1.開起一個新的brd
;        2.執行cs
;        3.會提示讀取一個舊的brd
;        4.選擇檔案後,再選擇開啟之後就開始比較,直到輸出結果
;
;; 程式特色:
;        1.源代碼分享,讓所有人都可以依照自己的方式加入其他功能,
;                例如加入輸出檔案為excel檔
;                或是其他功能,自己想像.
axlCmdRegister("cs" 'fnCompareSymbol ?cmdType "general")

procedure(fnCompareSymbol()
        prog((tBrdPathNew tBrdOld tBrdPathOld pPort tCmd tNewFile tOldFile lNewList lOldList)
               
                ;取新舊brd檔案名稱
                axlMsgPut("M-Please select a brd file:")
                tBrdPathOld = axlDMFileBrowse("allegro_BRD" nil ?title "Compare Symbol" ?optFilters "Board file(*.brd)|*.brd|") ;瀏覽舊的brd
                unless(tBrdPathOld
                        return(nil)
                )
                tBrdNew = axlCurrentDesign() ;目前所開啟的brd
                tBrdPathNew = strcat(simplifyFilename(tBrdNew) ".brd")
                ;要導出比較的資料
                fnCSExtractaData(tBrdPathNew tBrdPathOld)
               
                ;讀取新brd所導出的資料Comp
                tNewFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathNew)) "_comp.txt")
                lNewCompList = fnCSReadFile(tNewFile)
                deleteFile(tNewFile)
                                
                ;讀取舊brd所導出的資料Comp
                tOldFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathOld)) "_comp.txt")
                lOldCompList = fnCSReadFile(tOldFile)
                deleteFile(tOldFile)
               
                ;讀取新brd所導出的資料Sym
                tNewFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathNew)) "_sym.txt")
                lNewSymList = fnCSReadFile(tNewFile)
                deleteFile(tNewFile)
                                
                ;讀取舊brd所導出的資料Sym
                tOldFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathOld)) "_sym.txt")
                lOldSymList = fnCSReadFile(tOldFile)
                deleteFile(tOldFile)
               
                ;比較新舊brd差異並輸出到檔案
                fnCSCompareData(tBrdPathNew tBrdPathOld lNewCompList lOldCompList lNewSymList lOldSymList)
        )
)
procedure(fnCSReadFile(tFile)
        let((pPort tLine lLines)
                if(tFile && isFile(tFile) then
                        pPort = infile(tFile)
                        rexCompile(".$")
                        for(x 1 2 ;讀取前面兩行,這兩行不會處理
                                gets(tLine pPort)
                        )
                        while(gets(tLine pPort)
                                unless(blankstrp(tLine)
                                        lLines = cons(rexReplace(tLine "" 0) lLines)
                                )
                        )
                        close(pPort)
                        sort(lLines nil) ;排序所有資料
                else
                        axlUIConfirm("E- Misssing file.")
                )
        )
)
procedure(fnCSCompareData(tBrdPathNew tBrdPathOld lNewCompList lOldCompList lNewSymList lOldSymList)
        let((oNewComp oOldComp oNewSym oOldSym lLines tRefDes tPartNum tValue tTol tDeviceType tXY tIsMirrored
                tRotation tMode tSymName)
                ;將Comp的Data存放到Table
                for(x 0 1
                        if(zerop(x) then
                                oNewComp = makeTable("NEWCOMPDATA" nil)
                        else
                                oOldComp = makeTable("OLDCOMPDATA" nil)
                        )
                        rexCompile("!!")
                        foreach(tLine nth(x list(lNewCompList lOldCompList))
                                tLine = rexReplace(tLine "! !" 0)
                                lLines = parseString(tLine "!")
                                
                                tRefDes = cadr(lLines)
                                tPartNum = caddr(lLines)
                                tValue = nth(3 lLines)
                                tTol = nth(4 lLines)
                                tDeviceType = nth(6 lLines)
                                                               
                                if(zerop(x) then
                                        oNewComp[tRefDes] = list(tPartNum tValue tTol tDeviceType)
                                else
                                        oOldComp[tRefDes] = list(tPartNum tValue tTol tDeviceType)
                                )
                        )
                )
               
                ;將Sym的Data存放到Table
                for(x 0 1
                        if(zerop(x) then
                                oNewSym = makeTable("NEWSYMDATA" nil)
                        else
                                oOldSym = makeTable("OLDSYMDATA" nil)
                        )
                        rexCompile("!!")
                        foreach(tLine nth(x list(lNewSymList lOldSymList))
                                tLine = rexReplace(tLine "! !" 0)
                                lLines = parseString(tLine "!")
                                
                                tRefDes = cadr(lLines)
                                tXY = strcat("(" caddr(lLines) "," nth(3 lLines) ")")
                                tIsMirrored = nth(4 lLines)
                                if(tIsMirrored == "YES" then
                                        tIsMirrored = "B"
                                else
                                        tIsMirrored = "T"
                                )
                                tRotation = sprintf(nil "%.2f" readstring(nth(5 lLines)))
                                tMode = nth(6 lLines)
                                tSymName = nth(7 lLines)
                                
                                if(zerop(x) then
                                        tPartNum = car(oNewComp[tRefDes])
                                        unless(tPartNum
                                                tPartNum = ""
                                        )
                                        oNewSym[tRefDes] = list(tXY tIsMirrored tRotation tMode tSymName tPartNum)
                                else
                                        tPartNum = car(oOldComp[tRefDes])
                                        unless(tPartNum
                                                tPartNum = ""
                                        )
                                        oOldSym[tRefDes] = list(tXY tIsMirrored tRotation tMode tSymName tPartNum)
                                )
                        )
                )
                fnCSOutputData(tBrdPathNew tBrdPathOld oNewComp oOldComp oNewSym oOldSym)
        )
)
procedure(fnCSOutputData(tBrdPathNew tBrdPathOld oNewComp oOldComp oNewSym oOldSym)
        let((lAdded lDeleted lChanged tFile pPort xItem tOne)
                ;判斷是否有新增資料
                foreach(tRefdes oNewSym
                        unless(oOldSym[tRefdes]
                                lAdded = cons(tRefdes lAdded)
                        )
                )
                lAdded = sort(lAdded nil)
               
                ;判斷是否有減少資料
                foreach(tRefdes oOldSym
                        unless(oNewSym[tRefdes]
                                lDeleted = cons(tRefdes lDeleted)
                        )
                )
                lDeleted = sort(lDeleted nil)
               
                ;判斷是否有改變資料
                foreach(tRefdes oNewSym
                        when(oOldSym[tRefdes]
                                unless(oNewSym[tRefdes] == oOldSym[tRefdes]
                                        lChanged = cons(tRefdes lChanged)
                                )
                        )
                )
                lChanged = sort(lChanged nil)
               
                ;輸出資料到檔案
                drain()
                tFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathNew)) "_OldNew.rpt")
                pPort = outfile(tFile)
                ;檔案顯示的標題
                fprintf(pPort "Compare Symbol report\n")
                fprintf(pPort "Date: %s\n" getCurrentTime())
                fprintf(pPort "%s.brd [Old]\n" cadr(axlDMFileParts(tBrdPathOld)))
                fprintf(pPort "%s.brd [New]\n\n" cadr(axlDMFileParts(tBrdPathNew)))
                                                               
                fprintf(pPort "%s\n" "===============================================================================================================================")
                fprintf(pPort "%4s %-5s %-8s %20s %-20s %-4s %6s %-25s %-17s %-40s\n"  "#" "Brd" "Type" "Refdes" strcat("XY(" car(axlDBGetDesignUnits()) ")") "Side" "Rot" "Symtype" "Part number" "Device type")
                fprintf(pPort "%s\n" "===============================================================================================================================")
                xItem = 1
                ;輸出新增的資料到檔案
                foreach(tOne lAdded
                        fprintf(pPort "%4d %-5s %-8s %20s %-20s %-4s %6s %-25s %-17s %-40s\n" xItem "[New]" "Added:" tOne car(oNewSym[tOne]) cadr(oNewSym[tOne]) caddr(oNewSym[tOne]) nth(4 oNewSym[tOne]) nth(5 oNewSym[tOne]) _ssfnEnsureNonNilValue(nth(3 oNewComp[tOne])))
                        xItem++
                )
                fprintf(pPort "\n")
                ;輸出減少的資料到檔案
                xItem = 1
                foreach(tOne lDeleted
                        fprintf(pPort "%4d %-5s %-8s %20s %-20s %-4s %6s %-25s %-17s %-40s\n" xItem "[Old]" "Deleted:" tOne car(oOldSym[tOne]) cadr(oOldSym[tOne]) caddr(oOldSym[tOne]) nth(4 oOldSym[tOne]) nth(5 oOldSym[tOne]) _ssfnEnsureNonNilValue(nth(3 oOldComp[tOne])))
                        xItem++
                )
                fprintf(pPort "\n")
                ;輸出變更的資料到檔案
                xItem = 1
                foreach(tOne lChanged
                        fprintf(pPort "%4d %-5s %-8s %20s %-20s %-4s %6s %-25s %-17s %-40s\n" xItem "[New]" "Changed:" tOne car(oNewSym[tOne]) cadr(oNewSym[tOne]) caddr(oNewSym[tOne]) nth(4 oNewSym[tOne]) nth(5 oNewSym[tOne]) _ssfnEnsureNonNilValue(nth(3 oNewComp[tOne])))
                        fprintf(pPort "%4d %-5s %-8s %20s %-20s %-4s %6s %-25s %-17s %-40s\n" xItem "[Old]" "Changed:" tOne car(oOldSym[tOne]) cadr(oOldSym[tOne]) caddr(oOldSym[tOne]) nth(4 oOldSym[tOne]) nth(5 oOldSym[tOne]) _ssfnEnsureNonNilValue(nth(3 oOldComp[tOne])))
                        fprintf(pPort "\n")
                        xItem++
                )
                ;輸出總數量的訊息
                fprintf(pPort "\n\nTotal: %5d\n\n" length(lAdded)+length(lDeleted)+length(lChanged))
                fprintf(pPort "Summary:\n")
                fprintf(pPort "  %d Added symbols\n" length(lAdded))
                fprintf(pPort "  %d Deleted symbols\n" length(lDeleted))
                fprintf(pPort "  %d Changed symbols\n\n" length(lChanged))
                close(pPort)
               
                axlUIViewFileCreate(tFile "Report Window" t (120:60)) ;觀看輸出結果
        )
)
procedure(_ssfnEnsureNonNilValue(val)
        unless(val
                val = ""
        )
        val
)
procedure(fnCSExtractaData(tBrdPathNew tBrdPathOld)
        let((tFile pPort tBrdName tCmd)
                ;要導出比較的資料
                tFile = strcat(getWorkingDir() "/symbol.view")
                pPort = outfile(tFile)
                fprintf(pPort "SYMBOL\n\n")
                fprintf(pPort "REFDES\n")
                fprintf(pPort "SYM_X\n")
                fprintf(pPort "SYM_Y\n")
                fprintf(pPort "SYM_MIRROR\n")
                fprintf(pPort "SYM_ROTATE\n")
                fprintf(pPort "SYM_TYPE\n")
                fprintf(pPort "SYM_NAME\n")
                fprintf(pPort "END\n")
                fprintf(pPort "COMPONENT\n")
                fprintf(pPort "REFDES\n")
                fprintf(pPort "COMP_PART_NUMBER\n")
                fprintf(pPort "COMP_VALUE\n")
                fprintf(pPort "COMP_TOL\n")
                fprintf(pPort "COMP_PACKAGE\n")
                fprintf(pPort "COMP_DEVICE_TYPE\n")
                fprintf(pPort "COMP_CLASS\n")
                fprintf(pPort "COMP_DEVICE_LABEL\n")
                fprintf(pPort "END\n")
                close(pPort)
               
                ;導出新舊brd的資料,使用axlRunBatchDBProgram()就不會開啟cmd視窗
                foreach(tBrdPath list(tBrdPathNew tBrdPathOld)
                        tBrdName = cadr(axlDMFileParts(tBrdPath))
                        sprintf(tCmd "extracta %L %s %s_sym.txt %s_comp.txt" tBrdPath tFile tBrdName tBrdName)
                        axlRunBatchDBProgram("extracta" tCmd ?silent t ?noUnload t ?reloadDB nil)
                        deleteFile(strcat(getWorkingDir() "/extract.log"))
                )
                deleteFile(tFile)
        )
)