SuperStrict
Rem
bbdoc: morph
EndRem
Module pantson.morph

ModuleInfo "Version: 1.00"
ModuleInfo "Author: Richard Hanson"
ModuleInfo "Modserver: pantson"

Import BRL.Stream
Import BRL.Pixmap
Import brl.max2d

' const
Private
Const VERSION:Int = 0

Public
' type Tmoprh
Rem
bbdoc: The Morph type
End Rem
Type tmorph
	Rem
	bbdoc: Width of morph grid
	End Rem
	Field w:Int

	Rem
	bbdoc: Height of morph grid
	End Rem
	Field h:Int

	Rem
	bbdoc: Array of x co-ords for grid
	End Rem
	Field x:Float[]

	Rem
	bbdoc: Array of y co-ords for grid
	End Rem
	Field y:Float[]

	Rem
	bbdoc: version of morph file
	End Rem
	Field version:Int
	
	Rem
	bbdoc: Load a morph file
	End Rem
	Method load:Int(file:String)
		Local i:Int
		Local fl:TStream
		
		fl = ReadStream(file)
		If fl= Null Then Return False
		
		version = Int(ReadLine(fl))
		w = Int(ReadLine(fl))
		h = Int(ReadLine(fl))
		
		x = New Float[w*h]
		y = New Float[w*h]
		
		i = 0
		While i<(w*h)
			x[i] = Float(ReadLine(fl))
			y[i] = Float(ReadLine(fl))
			i:+1
		Wend
		
		CloseStream fl
		
		' end
		Return True
	End Method


	Rem
	bbdoc: save a morph file
	End Rem
	Method save:Int(file:String)
		Local i:Int
		Local fl:TStream
		
		fl = WriteStream(file)
		If fl = Null Then Return False
		
		WriteLine fl,version
		WriteLine fl,w
		WriteLine fl,h
		
		i = 0
		While i<(w*h)
			WriteLine fl,x[i]
			WriteLine fl,y[i]
			i:+1
		Wend
		
		CloseStream fl
		
		' end
		Return True
	End Method

End Type


Rem
bbdoc: Generates a pixmap that is [index] steps into the morph of 2 pixmaps.
End Rem
Function MorphPixmaps:TPixmap(p1:TPixmap,m1:tmorph,p2:TPixmap,m2:tmorph,steps:Int,index:Int)
	' make sure grids are the same
	If m1.w <> m2.w Or m1.h<>m2.h Then Return Null
	
	Local px:Byte Ptr
	Local pixel:Byte Ptr
	Local p:TPixmap
	Local w:Int, h:Int
	Local i:Int,j:Int
	Local c:Int
	Local x:Float[m1.w*m1.h],y:Float[m1.w*m1.h]
	Local x1:Float,y1:Float
	Local x2:Float,y2:Float
	Local x3:Int,y3:Int
	Local x4:Float,y4:Float
	Local tmp:Int
	
	Local mw:Float,mh:Float
	Local s:Int,t:Int
	
	Local sx1:Float,sy1:Float
	Local sx2:Float,sy2:Float
	Local sx3:Int,sy3:Int

	Local dx1:Float,dy1:Float
	Local dx2:Float,dy2:Float
	Local dx3:Int,dy3:Int
	
	Local sc:Int,dc:Int
	Local a:Int,r:Int,g:Int,b:Int
	
	Local limit:Int[3]
	
	Local step_factor:Float
	Local y_factor:Float
	Local x_factor:Float
	
	step_factor = Float(index) / steps
	
	w = p1.width + Float(p2.width-p1.width) * step_factor
	h = p1.height + Float(p2.height-p1.height) * step_factor
	
	p = CreatePixmap(w,h,PF_RGBA8888,4)
	ClearPixels p

	' get limits	
	limit[0] = p.height*p.pitch+p.width*4 - 4 'p.width - 1 
'	mhp[0] = p.height - 1 
	limit[1] = p1.height*p1.pitch+p1.width*BytesPerPixel[p1.format] - 4 'p1.width - 1 
'	mhp[1] = p1.height - 1 
	limit[2] = p2.height*p2.pitch+p2.width*BytesPerPixel[p2.format] - 4 'p2.width - 1 
'	mhp[2] = p2.height - 1 
	
	i = 0
	While i<m1.w
		j = 0
		While j<m1.h
			c = j*m1.w + i
			
			x[c] = m1.x[c] + (m2.x[c]-m1.x[c]) * step_factor
			y[c] = m1.y[c] + (m2.y[c]-m1.y[c]) * step_factor
			
'			WritePixel p,x[c],y[c],$ffffff00		
			j:+1
		Wend
		i:+1
	Wend
	
	s = 0
	While s < (m1.w-1)
		t = 0
		While t < (m1.h-1)

			c = t*m1.w + s
		
			mw = Float(Max(x[c+1]-x[c]+1,x[c+1+m1.w]+1-x[c+m1.w])) * 1
			mh = Float(Max(y[c+m1.w]-y[c]+1,y[c+1+m1.w]-y[c+1]+1)) * 1
			
			j = 0
			While j < mh
				y_factor = Float(j) / (mh-1)
				
				' output
				x1 = x[c] + (x[c+m1.w]-x[c]) * y_factor
				y1 = y[c] + (y[c+m1.w]-y[c]) * y_factor
		
				x2 = x[c+1] + (x[c+1+m1.w]-x[c+1]) * y_factor
				y2 = y[c+1] + (y[c+1+m1.w]-y[c+1]) * y_factor
		
				' source picture
				sx1 = m1.x[c] + (m1.x[c+m1.w]-m1.x[c]) * y_factor
				sy1 = m1.y[c] + (m1.y[c+m1.w]-m1.y[c]) * y_factor
		
				sx2 = m1.x[c+1] + (m1.x[c+1+m1.w]-m1.x[c+1]) * y_factor
				sy2 = m1.y[c+1] + (m1.y[c+1+m1.w]-m1.y[c+1]) * y_factor
				
				' dest picture
				dx1 = m2.x[c] + (m2.x[c+m1.w]-m2.x[c]) * y_factor
				dy1 = m2.y[c] + (m2.y[c+m1.w]-m2.y[c]) * y_factor
		
				dx2 = m2.x[c+1] + (m2.x[c+1+m1.w]-m2.x[c+1]) * y_factor
				dy2 = m2.y[c+1] + (m2.y[c+1+m1.w]-m2.y[c+1]) * y_factor

				' the slow bit now is all the min and max'ing
				i = 0
				While i < mw
					' excuse the name of this variable!!?!?!
					x_factor = Float(i) / (mw-1)
					
					' output
					x3 = x1 + (x2-x1) * x_factor
					y3 = y1 + (y2-y1) * x_factor
					
'					pixel = p.pixels + Max(0,Min(y3*p.pitch+x3 Shl 2,mwp[0]))
					a = y3*p.pitch+x3 Shl 2
					If a > limit[0] Then a = limit[0]
					If a < 0 Then a = 0
					pixel = a+p.pixels
					
					If pixel[3] = 0
						' source
						sx3 = sx1 + (sx2-sx1) * x_factor
						sy3 = sy1 + (sy2-sy1) * x_factor
					
						' read source pixel
'						px = p1.pixels + Max(0,Min(sy3*p1.pitch+sx3*BytesPerPixel[p1.format],mwp[1]))
						tmp = sy3*p1.pitch+sx3*BytesPerPixel[p1.format]
						If tmp > limit[1] Then tmp = limit[1]
						If tmp < 0 Then tmp = 0
						px = tmp+p1.pixels
						
						a = px[3]
						r = px[2]
						g = px[1]
						b = px[0]
						
						' destination
						dx3 = dx1 + (dx2-dx1) * x_factor
						dy3 = dy1 + (dy2-dy1) * x_factor

						' read destination pixel					
'						px = p2.pixels + Max(0,Min(dy3*p2.pitch+dx3*BytesPerPixel[p2.format],mwp[2]))
						tmp = dy3*p2.pitch+dx3*BytesPerPixel[p2.format]
						If tmp < 0 Then tmp = 0
						If tmp > limit[2] Then tmp = limit[2]
						px = tmp + p2.pixels
						
						a = a + ((px[3]) - a) * step_factor
						r = r + ((px[2]) - r) * step_factor
						g = g + ((px[1]) - g) * step_factor
						b = b + ((px[0]) - b) * step_factor

						' write pixel
						pixel[3] = a
						pixel[2] = r
						pixel[1] = g
						pixel[0] = b

						' fill in previous square
						If pixel[-1] = 0 And s>0
						pixel[-1] = a
							pixel[-2] = r
							pixel[-3] = g
							pixel[-4] = b
						EndIf

						' fill in above sqaure
						tmp = (p.pitch)
'						If p1.pixels + tmp > pixel
						If t > 0
						If pixel[3 - tmp] = 0
							pixel[3 - tmp] = a
							pixel[2 - tmp] = r
							pixel[1 - tmp] = g
							pixel[-tmp] = b
						EndIf
						EndIf
					EndIf
					
					
					i:+1
				Wend
					
				j:+1
			Wend

			t:+1
		Wend
		s:+1
	Wend
	
	Return p
End Function

Rem
bbdoc: Generates an image that is [index] steps into the morph from 2 images. Handle moves with image.
End Rem
Function MorphImages:Timage(i1:Timage,m1:tmorph,i2:Timage,m2:tmorph,steps:Int,index:Int,frame1:Int=0,frame2:Int=0)
	' make sure grids are the same
	If m1.w <> m2.w Or m1.h<>m2.h Then Return Null

	Local p:TPixmap
	Local p1:TPixmap
	Local p2:TPixmap
	Local i3:Timage

	p1 = LockImage(i1,frame1,True,False)
	p2 = LockImage(i2,frame2,True,False)
	
	Local w:Int, h:Int
	Local i:Int,j:Int
	Local c:Int
	Local x:Int[16],y:Int[16]
	Local x1:Int,y1:Int
	Local x2:Int,y2:Int
	Local x3:Int,y3:Int
	Local x4:Int,y4:Int
	
	Local mw:Int,mh:Int
	Local s:Int,t:Int
	
	Local sx1:Int,sy1:Int
	Local sx2:Int,sy2:Int
	Local sx3:Int,sy3:Int

	Local dx1:Int,dy1:Int
	Local dx2:Int,dy2:Int
	Local dx3:Int,dy3:Int
	
	Local sc:Int,dc:Int
	Local a:Int,r:Int,g:Int,b:Int
	
	Local mwp:Int[3],mhp:Int[3]

	w = p1.width + ((p2.width-p1.width) * index) / steps
	h = p1.height + ((p2.height-p1.height) * index) / steps
	
	' get limits	
	mwp[0] = p.width - 1 
	mhp[0] = p.height - 1 
	mwp[1] = p1.width - 1 
	mhp[1] = p1.height - 1 
	mwp[2] = p2.width - 1 
	mhp[2] = p2.height - 1 

	i3 = CreateImage(w,h)
	p = LockImage(i3)
	ClearPixels p
	
	i = 0
	While i<m1.w
		j = 0
		While j<m1.h
			c = j*m1.w + i
			
			x[c] = m1.x[c] + ((m2.x[c]-m1.x[c]) * index) / steps
			y[c] = m1.y[c] + ((m2.y[c]-m1.y[c]) * index) / steps
			
'			WritePixel p,x[c],y[c],$ffff0000		
			j:+1
		Wend
		i:+1
	Wend
	
	s = 0
	While s < (m1.w-1)
		t = 0
		While t < (m1.h-1)

			c = t*m1.w + s
		
			mw = Max(x[c+1]-x[c],x[c+1+m1.w]-x[c+m1.w])
			mh = Max(y[c+m1.w]-y[c],y[c+1+m1.w]-y[c+1])
			
		'	mw = 10
		'	mh = 10
			
			j = 0
			While j < mh+1
				' output
				x1 = x[c] + ((x[c+m1.w]-x[c]) * j) / (mh-1)
				y1 = y[c] + ((y[c+m1.w]-y[c]) * j) / (mh-1)
		
				x2 = x[c+1] + ((x[c+1+m1.w]-x[c+1]) * j) / (mh-1)
				y2 = y[c+1] + ((y[c+1+m1.w]-y[c+1]) * j) / (mh-1)
		
				' source picture
				sx1 = m1.x[c] + ((m1.x[c+m1.w]-m1.x[c]) * j) / (mh-1)
				sy1 = m1.y[c] + ((m1.y[c+m1.w]-m1.y[c]) * j) / (mh-1)
		
				sx2 = m1.x[c+1] + ((m1.x[c+1+m1.w]-m1.x[c+1]) * j) / (mh-1)
				sy2 = m1.y[c+1] + ((m1.y[c+1+m1.w]-m1.y[c+1]) * j) / (mh-1)
				
				' dest picture
				dx1 = m2.x[c] + ((m2.x[c+m1.w]-m2.x[c]) * j) / (mh-1)
				dy1 = m2.y[c] + ((m2.y[c+m1.w]-m2.y[c]) * j) / (mh-1)
		
				dx2 = m2.x[c+1] + ((m2.x[c+1+m1.w]-m2.x[c+1]) * j) / (mh-1)
				dy2 = m2.y[c+1] + ((m2.y[c+1+m1.w]-m2.y[c+1]) * j) / (mh-1)

				' all non error checked values rem'd out
								
				i = 0
				While i < mw+1
					' output
'					x3 = x1 + ((x2-x1) * i) / (mw-1)
'					y3 = y1 + ((y2-y1) * i) / (mw-1)
					x3 = Max(0,Min(x1 + ((x2-x1) * i) / (mw-1),mwp[0]))
					y3 = Max(0,Min(y1 + ((y2-y1) * i) / (mw-1),mhp[0]))
					
					If (ReadPixel(p,x3,y3) Shr 24) = 0
						' source
'						sx3 = sx1 + ((sx2-sx1) * i) / (mw-1)
'						sy3 = sy1 + ((sy2-sy1) * i) / (mw-1)
						sx3 = Max(0,Min(sx1 + ((sx2-sx1) * i) / (mw-1),mwp[1]))
						sy3 = Max(0,Min(sy1 + ((sy2-sy1) * i) / (mw-1),mhp[1]))
						sc = ReadPixel(p1,sx3,sy3)
						
						a = (sc Shr 24) & 255
						r = (sc Shr 16) & 255
						g = (sc Shr 8) & 255
						b = (sc Shr 0) & 255
						
						' source
'						dx3 = dx1 + ((dx2-dx1) * i) / (mw-1)
'						dy3 = dy1 + ((dy2-dy1) * i) / (mw-1)
						dx3 = Max(0,Min(dx1 + ((dx2-dx1) * i) / (mw-1),mwp[2]))
						dy3 = Max(0,Min(dy1 + ((dy2-dy1) * i) / (mw-1),mhp[2]))

						dc = ReadPixel(p2,dx3,dy3)

						a = a + ((((dc Shr 24) & 255) - a) * index) / steps
						r = r + ((((dc Shr 16) & 255) - r) * index) / steps
						g = g + ((((dc Shr 8) & 255) - g) * index) / steps
						b = b + ((((dc Shr 0) & 255) - b) * index) / steps

						WritePixel p,x3,y3,(a Shl 24) + (r Shl 16) + (g Shl 8) + b
						
					EndIf
					
					i:+1
				Wend
					
				j:+1
			Wend

			t:+1
		Wend
		s:+1
	Wend
	
	UnlockImage(i3)
	UnlockImage(i1)
	UnlockImage(i2)
	
	' move handle opf image
	x1 = i1.handle_x + ((i2.handle_x - i1.handle_x) * index) /steps
	y1 = i1.handle_y + ((i2.handle_y - i1.handle_y) * index) /steps
	SetImageHandle(i3,x1,y1)
		
	' return new image
	Return i3
End Function

Rem
bbdoc: Load a morph file
End Rem
Function LoadMorph:tmorph(file:String)
	Local m:tmorph
	
	m = New tmorph
	m.load(file)
	
	Return m
End Function

Rem
bbdoc: Save a morph file
End Rem
Function SaveMorph:Int(m:tmorph,file:String)
	Return m.save(file)
End Function

Rem
bbdoc: Create a new morph type
End Rem
Function CreateMorph:tmorph(w:Int,h:Int)
	Local m:tmorph
	
	m = New tmorph
	m.version = VERSION
	m.w = w
	m.h = h
	
	m.x = New Float[w*h]
	m.y = New Float[w*h]
	
	Return m
End Function
