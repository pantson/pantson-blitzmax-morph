ModuleInfo "Version: 1.00"
ModuleInfo "Author: Richard Hanson"
ModuleInfo "Modserver: pantson"
import brl.blitz
import brl.stream
import brl.pixmap
import brl.max2d
tmorph^brl.blitz.Object{
.w%&
.h%&
.x#&[]&
.y#&[]&
.version%&
-New%()="_pantson_morph_tmorph_New"
-Delete%()="_pantson_morph_tmorph_Delete"
-load%(file$)="_pantson_morph_tmorph_load"
-save%(file$)="_pantson_morph_tmorph_save"
}="pantson_morph_tmorph"
MorphPixmaps:brl.pixmap.TPixmap(p1:brl.pixmap.TPixmap,m1:tmorph,p2:brl.pixmap.TPixmap,m2:tmorph,steps%,index%)="pantson_morph_MorphPixmaps"
MorphImages:brl.max2d.Timage(i1:brl.max2d.Timage,m1:tmorph,i2:brl.max2d.Timage,m2:tmorph,steps%,index%,frame1%=0,frame2%=0)="pantson_morph_MorphImages"
LoadMorph:tmorph(file$)="pantson_morph_LoadMorph"
SaveMorph%(m:tmorph,file$)="pantson_morph_SaveMorph"
CreateMorph:tmorph(w%,h%)="pantson_morph_CreateMorph"
