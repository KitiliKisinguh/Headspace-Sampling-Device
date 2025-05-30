PULSONIX_LIBRARY_ASCII "SamacSys ECAD Model"
//626184/1383188/2.50/2/3/Zener Diode

(asciiHeader
	(fileUnits MM)
)
(library Library_1
	(padStyleDef "r115_80"
		(holeDiam 0)
		(padShape (layerNumRef 1) (padShapeType Rect)  (shapeWidth 0.8) (shapeHeight 1.15))
		(padShape (layerNumRef 16) (padShapeType Ellipse)  (shapeWidth 0) (shapeHeight 0))
	)
	(textStyleDef "Normal"
		(font
			(fontType Stroke)
			(fontFace "Helvetica")
			(fontHeight 1.27)
			(strokeWidth 0.127)
		)
	)
	(patternDef "SOD3716X135N" (originalName "SOD3716X135N")
		(multiLayer
			(pad (padNum 1) (padStyleRef r115_80) (pt -1.75, 0) (rotation 90))
			(pad (padNum 2) (padStyleRef r115_80) (pt 1.75, 0) (rotation 90))
		)
		(layerContents (layerNumRef 18)
			(attr "RefDes" "RefDes" (pt 0, 0) (textStyleRef "Normal") (isVisible True))
		)
		(layerContents (layerNumRef Courtyard_Top)
			(line (pt -2.575 1.67) (pt 2.575 1.67) (width 0.05))
		)
		(layerContents (layerNumRef Courtyard_Top)
			(line (pt 2.575 1.67) (pt 2.575 -1.67) (width 0.05))
		)
		(layerContents (layerNumRef Courtyard_Top)
			(line (pt 2.575 -1.67) (pt -2.575 -1.67) (width 0.05))
		)
		(layerContents (layerNumRef Courtyard_Top)
			(line (pt -2.575 -1.67) (pt -2.575 1.67) (width 0.05))
		)
		(layerContents (layerNumRef 28)
			(line (pt -1.345 0.8) (pt 1.345 0.8) (width 0.025))
		)
		(layerContents (layerNumRef 28)
			(line (pt 1.345 0.8) (pt 1.345 -0.8) (width 0.025))
		)
		(layerContents (layerNumRef 28)
			(line (pt 1.345 -0.8) (pt -1.345 -0.8) (width 0.025))
		)
		(layerContents (layerNumRef 28)
			(line (pt -1.345 -0.8) (pt -1.345 0.8) (width 0.025))
		)
		(layerContents (layerNumRef 28)
			(line (pt -1.345 0.225) (pt -0.77 0.8) (width 0.025))
		)
		(layerContents (layerNumRef 18)
			(line (pt -2.325 0.8) (pt 1.345 0.8) (width 0.2))
		)
		(layerContents (layerNumRef 18)
			(line (pt -1.345 -0.8) (pt 1.345 -0.8) (width 0.2))
		)
	)
	(symbolDef "SZMMSZ5245BT1G" (originalName "SZMMSZ5245BT1G")

		(pin (pinNum 1) (pt 0 mils 0 mils) (rotation 0) (pinLength 100 mils) (pinDisplay (dispPinName false)) (pinName (text (pt 140 mils -15 mils) (rotation 0]) (justify "Left") (textStyleRef "Normal"))
		))
		(pin (pinNum 2) (pt 600 mils 0 mils) (rotation 180) (pinLength 100 mils) (pinDisplay (dispPinName false)) (pinName (text (pt 460 mils -15 mils) (rotation 0]) (justify "Right") (textStyleRef "Normal"))
		))
		(line (pt 200 mils 80 mils) (pt 200 mils -80 mils) (width 6 mils))
		(line (pt 200 mils 80 mils) (pt 240 mils 100 mils) (width 6 mils))
		(line (pt 160 mils -100 mils) (pt 200 mils -80 mils) (width 6 mils))
		(line (pt 100 mils 0 mils) (pt 200 mils 0 mils) (width 6 mils))
		(line (pt 500 mils 0 mils) (pt 400 mils 0 mils) (width 6 mils))
		(poly (pt 200 mils 0 mils) (pt 400 mils 100 mils) (pt 400 mils -100 mils) (pt 200 mils 0 mils) (width 10  mils))
		(attr "RefDes" "RefDes" (pt 400 mils 350 mils) (justify Left) (isVisible True) (textStyleRef "Normal"))
		(attr "Type" "Type" (pt 400 mils 250 mils) (justify Left) (isVisible True) (textStyleRef "Normal"))

	)
	(compDef "SZMMSZ5245BT1G" (originalName "SZMMSZ5245BT1G") (compHeader (numPins 2) (numParts 1) (refDesPrefix Z)
		)
		(compPin "1" (pinName "K") (partNum 1) (symPinNum 1) (gateEq 0) (pinEq 0) (pinType Bidirectional))
		(compPin "2" (pinName "A") (partNum 1) (symPinNum 2) (gateEq 0) (pinEq 0) (pinType Bidirectional))
		(attachedSymbol (partNum 1) (altType Normal) (symbolName "SZMMSZ5245BT1G"))
		(attachedPattern (patternNum 1) (patternName "SOD3716X135N")
			(numPads 2)
			(padPinMap
				(padNum 1) (compPinRef "1")
				(padNum 2) (compPinRef "2")
			)
		)
		(attr "Manufacturer_Name" "onsemi")
		(attr "Manufacturer_Part_Number" "SZMMSZ5245BT1G")
		(attr "Arrow Part Number" "SZMMSZ5245BT1G")
		(attr "Arrow Price/Stock" "https://www.arrow.com/en/products/szmmsz5245bt1g/on-semiconductor")
		(attr "Description" "Zener Diodes ZEN REG 0.5W 15V")
		(attr "<Hyperlink>" "http://www.onsemi.com/pub/Collateral/MMSZ5221BT1-D.PDF")
		(attr "<Component Height>" "1.35")
		(attr "<STEP Filename>" "SZMMSZ5245BT1G.stp")
		(attr "<STEP Offsets>" "X=0;Y=0;Z=0")
		(attr "<STEP Rotation>" "X=0;Y=0;Z=0")
	)

)
