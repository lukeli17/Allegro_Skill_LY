;
;FileName:        
;Load:                load("fCN.il")
;Command:        cn
;
;功能:比較兩個PCB的Netlist差異
;使用方法:
;        1.開起一個新的brd
;        2.執行cn
;        3.會提示讀取一個舊的brd
;        4.選擇檔案後,再選擇開啟之後就開始比較,直到輸出結果
;
;; 程式特色:
;        1.源代碼分享,讓所有人都可以依照自己的方式加入其他功能,
;                例如加入輸出檔案為excel檔
;                或是其他功能,自己想像.
axlCmdRegister("cn" 'fnCompareNetlist ?cmdType "general")

procedure(fnCompareNetlist()
        prog((tBrdPathNew tBrdOld tBrdPathOld pPort tCmd tNewFile tOldFile lNewList lOldList)
               
                ;取新舊brd檔案名稱
                axlMsgPut("M-Please select a brd file:")
                tBrdPathOld = axlDMFileBrowse("allegro_BRD" nil ?title "Compare Netlist" ?optFilters "Board file(*.brd)|*.brd|") ;瀏覽舊的brd
                unless(tBrdPathOld
                        return(nil)
                )
                tBrdNew = axlCurrentDesign() ;目前所開啟的brd
                tBrdPathNew = strcat(simplifyFilename(tBrdNew) ".brd")
                ;要導出比較的資料
                tFile = strcat(getWorkingDir() "/netlist.view")
                pPort = outfile(tFile)
                fprintf(pPort "LOGICAL_PIN\n")
                fprintf(pPort "  REFDES\n")
                fprintf(pPort "  PIN_NUMBER\n")
                fprintf(pPort "  NET_NAME\n")
                fprintf(pPort "END\n")
                close(pPort)
                ;
                ;導出新舊brd的資料,使用axlRunBatchDBProgram()就不會開啟cmd視窗
                foreach(tBrdPath list(tBrdPathNew tBrdPathOld)
                        tBrdName = cadr(axlDMFileParts(tBrdPath))
                        sprintf(tCmd "extracta %L %s %s_pin.txt" tBrdPath tFile tBrdName)
                        axlRunBatchDBProgram("extracta" tCmd ?silent t ?noUnload t ?reloadDB nil)
                        deleteFile(strcat(getWorkingDir() "/extract.log"))
                )
                deleteFile(tFile)
               
                ;讀取新brd所導出的資料
                tNewFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathNew)) "_pin.txt")
                lNewList = fnCNReadFile(tNewFile)
                deleteFile(tNewFile)
                                
                ;讀取舊brd所導出的資料
                tOldFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathOld)) "_pin.txt")
                lOldList = fnCNReadFile(tOldFile)
                deleteFile(tOldFile)
               
                ;比較新舊brd差異並輸出到檔案
                fnCNCompareData(tBrdPathNew tBrdPathOld lNewList lOldList)
        )
)
procedure(fnCNReadFile(tFile)
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
procedure(fnCNCompareData(tBrdPathNew tBrdPathOld lNewList lOldList)
        let((oNewPin oOldPin lLines tRefDes tPin tNetName)
                for(x 0 1
                        if(zerop(x) then
                                oNewPin = makeTable("NEWDATA" nil)
                        else
                                oOldPin = makeTable("OLDDATA" nil)
                        )
                        rexCompile("!!")
                        foreach(tLine nth(x list(lNewList lOldList))
                                tLine = rexReplace(tLine "! !" 0)
                                lLines = parseString(tLine "!")
                                
                                tRefDes = cadr(lLines)
                                tPin = strcat(tRefDes "." caddr(lLines))
                                tNetName = nth(3 lLines)
                                
                                if(zerop(x) then
                                        oNewPin[tPin] = list(tNetName)
                                else
                                        oOldPin[tPin] = list(tNetName)
                                )
                        )
                )
                fnCNOutputData(tBrdPathNew tBrdPathOld oNewPin oOldPin)
        )
)
procedure(fnCNOutputData(tBrdPathNew tBrdPathOld oNewPin oOldPin)
        let((lAdded lDeleted lChanged tFile pPort xItem tOne)
                ;判斷是否有新增資料
                foreach(tPin oNewPin
                        unless(oOldPin[tPin]
                                lAdded = cons(tPin lAdded)
                        )
                )
                lAdded = sort(lAdded nil)
               
                ;判斷是否有減少資料
                foreach(tPin oOldPin
                        unless(oNewPin[tPin]
                                lDeleted = cons(tPin lDeleted)
                        )
                )
                lDeleted = sort(lDeleted nil)
               
                ;判斷是否有改變資料
                foreach(tPin oNewPin
                        when(oOldPin[tPin]
                                unless(oNewPin[tPin] == oOldPin[tPin]
                                        lChanged = cons(tPin lChanged)
                                )
                        )
                )
                lChanged = sort(lChanged nil)
               
                ;輸出資料到檔案
                drain()
                tFile = strcat(getWorkingDir() "/" cadr(axlDMFileParts(tBrdPathNew)) "_OldNew.rpt")
                pPort = outfile(tFile)
                ;檔案顯示的標題
                fprintf(pPort "Compare NetList report\n")
                fprintf(pPort "Date: %s\n" getCurrentTime())
                fprintf(pPort "%s.brd [Old]\n" cadr(axlDMFileParts(tBrdPathOld)))
                fprintf(pPort "%s.brd [New]\n\n" cadr(axlDMFileParts(tBrdPathNew)))
                                                               
                fprintf(pPort "%s\n" "===================================================================================================================")
                fprintf(pPort "%-4s | %-20s | %-40s | %-40s |\n" "Item" "Pin Name" "Current(New) Design" "Old Design")
                fprintf(pPort "%s\n" "===================================================================================================================")
                xItem = 1
                ;輸出新增的資料到檔案
                foreach(tOne lAdded
                        fprintf(pPort "%-4d | %-20s | %-40s | %-40s |\n" xItem tOne car(oNewPin[tOne]) "(***)")
                        fprintf(pPort "%s\n" "-------------------------------------------------------------------------------------------------------------------")
                        xItem++
                )
                ;輸出減少的資料到檔案
                foreach(tOne lDeleted
                        fprintf(pPort "%-4d | %-20s | %-40s | %-40s |\n" xItem tOne "(***)" car(oOldPin[tOne]))
                        fprintf(pPort "%s\n" "-------------------------------------------------------------------------------------------------------------------")
                        xItem++
                )
                ;輸出變更的資料到檔案
                foreach(tOne lChanged
                        fprintf(pPort "%-4d | %-20s | %-40s | %-40s |\n" xItem tOne car(oNewPin[tOne]) car(oOldPin[tOne]))
                        fprintf(pPort "%s\n" "-------------------------------------------------------------------------------------------------------------------")
                        xItem++
                )
                ;輸出總數量的訊息
                fprintf(pPort "Total: %5d\n\n" length(lAdded)+length(lDeleted)+length(lChanged))
                fprintf(pPort "Summary:\n")
                fprintf(pPort "  %d Added pins\n" length(lAdded))
                fprintf(pPort "  %d Deleted pins\n" length(lDeleted))
                fprintf(pPort "  %d Changed pins\n\n" length(lChanged))
                fprintf(pPort "%s\n" "Remark: (***) = Pin not exist in the design.")
                close(pPort)
               
                axlUIViewFileCreate(tFile "Report Window" t (120:60)) ;觀看輸出結果
        )
)