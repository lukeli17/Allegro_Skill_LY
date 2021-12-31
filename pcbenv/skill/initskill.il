axlCmdRegister("skill_load" 'skill_load)
procedure(skill_load()

load( "setupall.il")
load( "setfunkeyskill.il")
load( "fileclear.il")
load( "export_dxf_3d.il")

loadi("align.il")
loadi("align_do.il")
loadi("align_utils.il")

load("initskill.il")

load("ali_pin.il" "")
load("change_shape_net.il")
load("check_noref.il")
load("cut.il" "www.pcbskill.com")
load("conv.il")
load("export_lib.il")
load("height_check.il")
load("hl_null_pin.il")
load("jfh_refdes_rotate.il")
load("layernumvisible.il")
load("Quick_chinese.il")
load("quick_grids.il")
load("Quick_Savebytime.il")
load("search.il")
load("x_dump_lib.il" "deargds")
load("x_mc_ro_text.il" "www.eda365.com")
load("quick_danglings.il")

);end procedure