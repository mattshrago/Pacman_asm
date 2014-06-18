TITLE MASM Template						(PacmanMatthewShragoRobertNordburgJohnBaima.asm)
INCLUDE Irvine32.inc
.data
ROWS = 31										;remember rows counts from the top down: top row is Y=1, bottom row is Y=31
COLUMNS = 28									;HOWEVER, columns start from 0: leftmost column is X=0, rightmost is X=27
ghost0 BYTE "	    ###     ###     ###    ###	          XXXXXX",0
ghost1 BYTE "	   #O#O#   #O#O#   #O#O#  #O#O#          XXXXX      **   **   **",0
ghost2 BYTE "	   #####   #####   #####  #####          XXXXX	    **   **   **",0
ghost3 BYTE "	   # # #   # # #   # # #  # # #           XXXXXX", 0
myMessage BYTE "                PAC-MAN             ",0
startGame BYTE "                  START GAME [PRESS S TO START C FOR CONTROLS]        ", 0
createdBy BYTE "                CREATED BY: Matthew Shrago, Rob Nordberg, John Baima", 0
pac0 BYTE " ***********************************************************************************", 0
pacFill0 BYTE " *                                                                                 *", 0
pac1 BYTE " *  ##########  ##########  ##########       ###    ###   ##########  ###     ##   *", 0
pac2 BYTE " *  ##      ##  ##      ##  ##               ## #  # ##   ##      ##  ## #    ##   *", 0
pac3 BYTE " *  ##########  ##########  ##               ##  ##  ##   ##########  ##  #   ##   *", 0
pac4 BYTE " *  ##          ##      ##  ##         ####  ##      ##   ##      ##  ##   #  ##   *", 0
pac5 BYTE " *  ##          ##      ##  ##               ##      ##   ##      ##  ##    # ##   *", 0
pac6 BYTE " *  ##          ##      ##  ##########       ##      ##   ##      ##  ##     ###   *", 0
pacFill1 BYTE " *                                                                                 *", 0
pac7 BYTE " ***********************************************************************************", 0
pacChar db ?
pacx SBYTE 13
pacy SBYTE 24
pacdir db 2										;1 = north, 2 = east, 3 = south, 4 = west
ghos1x SBYTE 12
ghos1y SBYTE 12
ghos1dir db 1									;1 = north, 2 = east, 3 = south, 4 = west
ghos2x SBYTE 13
ghos2y SBYTE 12
ghos2dir db 1									;1 = north, 2 = east, 3 = south, 4 = west
ghos2targx db 0
ghos2targy db 0
ghos3x SBYTE 14
ghos3y SBYTE 12
ghos3dir db 1									;1 = north, 2 = east, 3 = south, 4 = west
ghos3targx db 0
ghos3targy db 0
ghos4x SBYTE 15
ghos4y SBYTE 12
ghos4dir db 1									;1 = north, 2 = east, 3 = south, 4 = west
ghos4targx db 0
ghos4targy db 0
northlegal db 0									;ofc 0 = false, 1 = true
eastlegal db 0
southlegal db 0
westlegal db 0
northdist db 0									;used for target seeking; calculates the Manhattan distance (L-shaped) between an adjacent tile and the target
eastdist db 0									;the real Pac-Man uses Euclidean distance (straight line), so it's not exactly the same
southdist db 0									;but that would require doing sqrt(abs(ghostx-targetx)^2+abs(ghosty-targety)^2) in assembly and this is almost as good
westdist db 0									;so, you know, close enough.
totalScore dd 0									;when pacman collects pellets the score goes up
totalLives SBYTE 3								;pacman starts with 3 lives
outputScore db "SCORE: ",0
outputLives db "UP",0
thatsAllSheWrote db "GAME OVER!",0
chickenDinner db "YOU WON!",0
result db "Your total score is: ",0
testAgainst db 2
rowCounter db 2
boardArray  db '############################', '#............##............#', '#.####.#####.##.#####.####.#', '#o####.#####.##.#####.####o#','#.####.#####.##.#####.####.#', '#..........................#', '#.####.##.########.##.####.#', '#.####.##.########.##.####.#'	;This is used for collision.
			db '#......##....##....##......#', '######.##### ## #####.######', '######.##### ## #####.######', '######.##          ##.######','######.## ######## ##.######', '######.## #      # ##.######', '      .   #      #   .      ', '######.## #      # ##.######'	;It is a little hard to read but its the 
			db '######.## ######## ##.######', '######.##          ##.######', '######.## ######## ##.######', '######.## ######## ##.######','#............##............#', '#.####.#####.##.#####.####.#', '#.####.#####.##.#####.####.#', '#o..##.......  .......##..o#'	;same as the map below.
			db '###.##.##.########.##.##.###', '###.##.##.########.##.##.###', '#......##..........##......#', '#.##########.##.##########.#','#.##########.##.##########.#', '#..........................#', '############################'
row1  db "# # # # # # # # # # # # # # # # # # # # # # # # # # # #",0
row2  db "# . . . . . . . . . . . . # # . . . . . . . . . . . . #",0  
row3  db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0  
row4  db "# o # # # # . # # # # # . # # . # # # # # . # # # # o #",0  
row5  db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0  
row6  db "# . . . . . . . . . . . . . . . . . . . . . . . . . . #",0  
row7  db "# . # # # # . # # . # # # # # # # # . # # . # # # # . #",0  
row8  db "# . # # # # . # # . # # # # # # # # . # # . # # # # . #",0  
row9  db "# . . . . . . # # . . . . # # . . . . # # . . . . . . #",0  
row10 db "# # # # # # . # # # # #   # #   # # # # # . # # # # # #",0  
row11 db "# # # # # # . # # # # #   # #   # # # # # . # # # # # #",0  
row12 db "# # # # # # . # #                     # # . # # # # # #",0  
row13 db "# # # # # # . # #   # # # - - # # #   # # . # # # # # #",0  
row14 db "# # # # # # . # #   #             #   # # . # # # # # #",0  
row15 db "            .       #             #       .            ",0  
row16 db "# # # # # # . # #   #             #   # # . # # # # # #",0  
row17 db "# # # # # # . # #   # # # # # # # #   # # . # # # # # #",0  
row18 db "# # # # # # . # #                     # # . # # # # # #",0  
row19 db "# # # # # # . # #   # # # # # # # #   # # . # # # # # #",0 
row20 db "# # # # # # . # #   # # # # # # # #   # # . # # # # # #",0  
row21 db "# . . . . . . . . . . . . # # . . . . . . . . . . . . #",0  
row22 db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0  
row23 db "# . # # # # . # # # # # . # # . # # # # # . # # # # . #",0  
row24 db "# o . . # # . . . . . . .     . . . . . . . # # . . o #",0  
row25 db "# # # . # # . # # . # # # # # # # # . # # . # # . # # #",0  
row26 db "# # # . # # . # # . # # # # # # # # . # # . # # . # # #",0  
row27 db "# . . . . . . # # . . . . . . . . . . # # . . . . . . #",0 
row28 db "# . # # # # # # # # # # . # # . # # # # # # # # # # . #",0 
row29 db "# . # # # # # # # # # # . # # . # # # # # # # # # # . #",0 
row30 db "# . . . . . . . . . . . . . . . . . . . . . . . . . . #",0 
row31 db "# # # # # # # # # # # # # # # # # # # # # # # # # # # #",0   
directions1 BYTE "                    Use a,s,d,w to manuover Pacman around the maze.", 0
directions2 BYTE "           'A' will move pacman to the left,'D' will move pacman to the right.",0
directions3 BYTE "           'S' will move the pacman downward, 'W' will move the pacman upward.",0
directions5 BYTE "             complete the level by eating all the dots. Avoid the monsters!!!",0
PRESSS BYTE "                        PRESS S TO START THE GAME, GOOD LUCK!", 0
.code											;-----------------------------------------------;MS
writeStrWithSP proc									;just condensing code a bit
	Call WriteString
	Call crlf
	ret
writeStrWithSP endp

valuesToDrawBoard PROC
	mov dx, 0
	Call gotoxy
	mov eax, 9			
	Call setTextColor
	mov edx, offset row1-56						;So the first line will print out when the loop adds the size of the offset.	
ret
valuesToDrawBoard ENDP

drawStringBoard proc							;less flickery than one char at a time, but a real pain to work with
	Call valuesToDrawBoard
	mov ecx, 31									;The number of rows to print out. 
	printMap:
		add edx, 56								;This will automatically add the offset to go to the next row. (YEAHHHHH!) (Basically going to next string.)
		Call writeStrWithSP							;Printing of the string.
	loop printMap
	doneWithMap:
	ret
drawStringBoard endp

bl2esi proc										;passed value in bl for which char to access in the string
	seekchar:
		inc esi									;looping an inc of esi is the only way I've found to address a specific char of a string
		dec bl									;esi is increased bl number of times
	cmp bl,0
		jne seekchar
	ret
bl2esi endp

lookForSpace PROC
	Call bl2esi									;sets offset the to appropriate char in that string
	cmp BYTE PTR [esi], ' '
ret 
lookForSpace ENDP

xCordOfPacCleanup PROC
	movzx ebx, pacx								;moves Pac-Man's Xpos to bl
	add bl, bl									;doubles it
ret
xCordOfPacCleanup ENDP

addTen PROC
	add totalScore, 10							;each pacdot is worth 10 points
	mov BYTE PTR [esi], ' '						;once it gets there, replace '.' with ' '
ret
addTen ENDP

removePellet proc								;techniCally removes anything on the board at pac-man's position, but the only things he can remove given legal moves is pellets
	testing:
	mov ah, testAgainst
	cmp pacY, ah								;pac man can't be at y value of 1 or 31 so it ignores those
	jne goAgain
	je gameChanger
	goAgain:
		inc testAgainst							;y-value to check for
		inc rowCounter							;which row needs to be edited
		jmp testing
	gameChanger:								;Selects which row will be edited
	Call xCordOfPacCleanup
	cmp rowCounter, 2
	je RowIs2
	cmp rowCounter, 3
	je RowIs3
	cmp rowCounter, 4
	je RowIs4
	cmp rowCounter, 5
	je RowIs5
	cmp rowCounter, 6
	je RowIs6
	cmp rowCounter, 7
	je RowIs7
	cmp rowCounter, 8
	je RowIs8
	cmp rowCounter, 9
	je RowIs9
	cmp rowCounter, 10
	je RowIs10
	cmp rowCounter, 11
	je RowIs11
	cmp rowCounter, 12
	je RowIs12
	cmp rowCounter, 13
	je RowIs13
	cmp rowCounter, 14
	je RowIs14
	cmp rowCounter, 15
	je RowIs15
	cmp rowCounter, 16
	je RowIs16
	cmp rowCounter, 17
	je RowIs17
	cmp rowCounter, 18
	je RowIs18
	cmp rowCounter, 19
	je RowIs19
	cmp rowCounter, 20
	je RowIs20
	cmp rowCounter, 21
	je RowIs21
	cmp rowCounter, 22
	je RowIs22
	cmp rowCounter, 23
	je RowIs23
	cmp rowCounter, 24
	je RowIs24
	cmp rowCounter, 25
	je RowIs25
	cmp rowCounter, 26
	je RowIs26
	cmp rowCounter, 27
	je RowIs27
	cmp rowCounter, 28
	je RowIs28
	cmp rowCounter, 29
	je RowIs29
	cmp rowCounter, 30
	je RowIs30
	rowIs2:										;these procedures check if where pacman is on the map is a pellet or not and gives appropriate points
	mov esi, offset row2						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs3:
	mov esi, offset row3						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs4:
	mov esi, offset row4						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs5:
	mov esi, offset row5						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs6:
	mov esi, offset row6						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs7:
	mov esi, offset row7						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs8:
	mov esi, offset row8						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs9:
	mov esi, offset row9						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs10:
	mov esi, offset row10						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs11:
	mov esi, offset row11						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs12:
	mov esi, offset row12						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs13:
	mov esi, offset row13						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs14:
	mov esi, offset row14						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs15:
	mov esi, offset row15						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs16:
	mov esi, offset row16						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs17:
	mov esi, offset row17						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	RowIs18:
	mov esi, offset row18						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs19:
	mov esi, offset row19						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs20:
	mov esi, offset row20						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs21:
	mov esi, offset row21						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs22:
	mov esi, offset row22						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs23:
	mov esi, offset row23						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs24:
	mov esi, offset row24						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs25:
	mov esi, offset row25						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs26:
	mov esi, offset row26						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs27:
	mov esi, offset row27						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs28:
	mov esi, offset row28						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs29:
	mov esi, offset row29						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	jmp kdone
	RowIs30:
	mov esi, offset row30						;sets offset to the appropriate row's string
	Call lookForSpace
	je kdone
	Call addTen
	kdone:
	ret
removePellet endp

PacPellet proc
	mov eax, 10
	Call setTextColor
	mov dh, 1
	mov dl, 60
	Call gotoxy
	mov eax, 4
	Call setTextColor
	mov dh, 3								;puts score next to the game
	mov dl, 67
	mov eax, totalScore
	Call gotoxy
	mov edx, offset outputScore					;prints the score
	Call writestring
	mov dh, 3
	mov dl, 73
	Call gotoxy
	Call writedec
	ret
PacPellet endp

Lives proc
	Call YellowText
	mov dh, 5
	mov dl, 69
	Call gotoxy
	mov eax, 0
	mov al, totalLives
	Call writedec
	mov edx, offset outputLives
	Call writestring
	ret
Lives endp

moveGhosts proc
	cmp ghos1dir, 1								;if ghost is facing north
	jne ghos1dir2
	dec ghos1y									;move ghost north
	call ghostsvspacman
	jmp ghos2
	ghos1dir2:
	cmp ghos1dir, 2								;if ghost is facing east
	jne ghos1dir3
	inc ghos1x									;move ghost east
	call ghostsvspacman
	jmp ghos2
	ghos1dir3:
	cmp ghos1dir, 3								;if ghost is facing south
	jne ghos1dir4
	inc ghos1y									;move ghost south
	call ghostsvspacman
	jmp ghos2
	ghos1dir4:									;must be dir4 (west) if not 1, 2, or 3
	dec ghos1x									;move ghost west
	call ghostsvspacman
	ghos2:
		cmp ghos2dir, 1								;if ghost is facing north
		jne ghos2dir2
		dec ghos2y									;move ghost north
		call ghostsvspacman
	jmp ghos3
	ghos2dir2:
		cmp ghos2dir, 2							;if ghost is facing east
		jne ghos2dir3
		inc ghos2x								;move ghost east
		call ghostsvspacman
		jmp ghos3
	ghos2dir3:
		cmp ghos2dir, 3							;if ghost is facing south
		jne ghos2dir4
		inc ghos2y								;move ghost south
		call ghostsvspacman
		jmp ghos3
	ghos2dir4:									;must be dir4 (west) if not 1, 2, or 3
		dec ghos2x								;move ghost west
		call ghostsvspacman
	ghos3:
		cmp ghos3dir, 1							;if ghost is facing north
		jne ghos3dir2
		dec ghos3y								;move ghost north
		call ghostsvspacman
		jmp ghos4
	ghos3dir2:
		cmp ghos3dir, 2							;if ghost is facing east
		jne ghos3dir3
		inc ghos3x								;move ghost east
		call ghostsvspacman
		jmp ghos4
	ghos3dir3:
		cmp ghos3dir, 3							;if ghost is facing south
		jne ghos3dir4
		inc ghos3y								;move ghost south
		call ghostsvspacman
		jmp ghos4
	ghos3dir4:									;must be dir4 (west) if not 1, 2, or 3
		dec ghos3x								;move ghost west
		call ghostsvspacman
	ghos4:
	cmp ghos4dir, 1								;if ghost is facing north
	jne ghos4dir2
	dec ghos4y									;move ghost north
	call ghostsvspacman
	jmp endingThis
	ghos4dir2:
	cmp ghos4dir, 2								;if ghost is facing east
	jne ghos4dir3
	inc ghos4x									;move ghost east
	call ghostsvspacman
	jmp endingThis
	ghos4dir3:
	cmp ghos4dir, 3								;if ghost is facing south
	jne ghos4dir4
	inc ghos4y									;move ghost south
	call ghostsvspacman
	jmp endingThis
	ghos4dir4:									;must be dir4 (west) if not 1, 2, or 3
	dec ghos4x									;move ghost west
	call ghostsvspacman
	endingThis:		
	call teleporter						
	ret
moveGhosts endp

teleporter proc
	teleport1west:			
		cmp ghos1x, 0								
		jne teleport1east							
		mov ghos1x, 27								;moves ghost across map
		mov ghos1dir, 4								;ghost moves west
	teleport1east:
		cmp ghos1x, 27
		jne teleport2west
		mov ghos1x, 0								;moves ghost acrossmap
		mov ghos1dir, 2								;ghost moves east
	teleport2west:
		cmp ghos2x, 0
		jne teleport2east
		mov ghos2x, 27								;moves ghost across map
		mov ghos2dir, 4								;ghost moves west
	teleport2east:
		cmp ghos2x, 27
		jne teleport3west
		mov ghos3x, 0								;moves ghost across map
		mov ghos3dir, 2								;ghost moves east
	teleport3west:
		cmp ghos3x, 0
		jne teleport3east
		mov ghos3x, 27								;moves ghost across map
		mov ghos3dir, 4								;ghost moves west
	teleport3east:
		cmp ghos3x, 27
		jne teleport4west
		mov ghos3x, 0								;moves ghost across map
		mov ghos3dir, 2								;ghost moves east
	teleport4west:
		cmp ghos4x, 0
		jne teleport4east
		mov ghos4x, 27								;moves ghost across map
		mov ghos4dir, 4								;ghost moves west
	teleport4east:
		cmp ghos4x, 27
		jne allDone
		mov ghos4x, 0								;moves ghost across map
		mov ghos4dir, 2								;ghost moves east
	allDone:
	ret
teleporter endp

ghostsVsPacman proc 
	mov ah, ghos1x								;compare pacman's x position to ghost 1's position
	cmp pacx, ah
		je pacmanY1									;if they are equal compare the y position of both
	mov ah, ghos2x								;compare pacman's x position to ghost 2's position
		cmp pacx, ah
	je pacmanY2									;if they are equal compare the y position of both
	mov ah, ghos3x								;compare pacman's x position to ghost 3's position
	cmp pacx, ah
		je pacmanY3									;if they are equal compare the y position of both
	mov ah, ghos4x								;compare pacman's x position to ghost 4's position
	cmp pacx, ah
		je pacmanY4
	jmp noDice
pacmanY1:	mov ah, ghos1y							;check pacman's y position compared to ghost 1's y position
			cmp pacy, ah
			je DeadMan								;if they are equal, pacman is caught by the ghost
			jmp noDice								;if they are not equal, pacman has not been caught
pacmanY2:	mov ah, ghos2y
			cmp pacy, ah							;compare pacman's y position compared to ghost 2's y position
			je DeadMan								;if they are equal, pacman has been caught
			jmp noDice								;otherwise, pacman has not been caught
pacmanY3:	mov ah, ghos3y
			cmp pacy, ah							;compare pacman's y position to ghost 3's y position
			je DeadMan								;if they are equal, pacman has been caught
			jmp noDice								;otherwise, pacman has not been caught
pacmanY4:	mov ah, ghos4y
			cmp pacy, ah							;compare pacman's y position to ghost 4's y position
			je DeadMan								;if they are equal, pacman has been caught
			jmp noDice								;otherwise pacman has not been caught
	DeadMan:	Call caughtInTheAct
	noDice:		ret
ghostsVsPacman endp

caughtInTheAct proc
	dec totalLives					
	Call resetUnits								;after pacman is caught all untis are reset to starting positions
	Call Lives									;prints lives and in main jumps to top of label
	ret
caughtInTheAct endp

resetUnits proc
	mov dh, 13									;Reset pacman to original position
	mov dl, 24							
	Call gotoxy 
	mov pacx, dh								;save pacman's coordinates
	mov pacy, dl
	mov pacdir, 2								;saves pacman's direction
	mov dh, 12									;Reset ghost to starting position
	mov dl, 12
	Call gotoxy
	mov ghos1x, dh								;saves x position of ghost
	mov ghos1y, dl								;saves y position of ghost 
	mov ghos1dir, 1								;saves direction for ghost to move in
	mov dh, 13									;Reset ghost to starting position
	mov dl, 12
	Call gotoxy
	mov ghos2x, dh								;saves x position of ghost
	mov ghos2y, dl								;saves y position of ghost 
	mov ghos2dir, 1								;saves direction for ghost to move in
	mov dh, 14									;Reset ghost to starting position
	mov dl, 12
	Call gotoxy
	mov ghos3x, dh								;saves x position of ghost
	mov ghos3y, dl								;saves y position of ghost 
	mov ghos3dir, 1								;saves direction for ghost to move in
	mov dh, 15									;Reset ghost to starting position
	mov dl, 12
	Call gotoxy
	mov ghos4x, dh								;saves x position of ghost
	mov ghos4y, dl								;saves y position of ghost 
	mov ghos4dir, 1								;saves direction for ghost to move in
	Call directGhosts
	ret
resetUnits endp

discardWallDirs proc uses ecx edx				;pass ghost X in ch, ghost Y in cl, and ghostdir in dl...changes the stored values in NESWlegal based on the passed values
	north:;-------------------------------------;determine if north is legal:
	cmp dl, 3									;if the ghost is facing south
		je ni										;north is illegal (ghosts can't arbitrarily reverse direction)
	mov bh, ch
	mov bl, cl
	dec bl										;bl now refers to the tile above ghost Y, checking if moving north is legal
	Call charAtXY								;returns the char at the referenced tile to al
	cmp al, '#'									;if the char is '#'
		jne nl									
	ni:											;"north illegal"
	mov northlegal, 0							;north is not legal
		jmp east										
	nl:											;"north legal"
	mov northlegal, 1							;otherwise, it is legal.
	east:;--------------------------------------;now determine if east is legal:
	cmp dl, 4									;if the ghost is facing west
		je ei										;east is illegal (ghosts can't arbitrarily reverse direction)
	mov bh, ch
	mov bl, cl
	inc bh										;bh now refers to the tile to the right of ghost X, checking if moving east is legal
	Call charAtXY								;returns the char at the referenced tile to al
	cmp al, '#'									;if the char is '#'
		jne el									
	ei:											;"east illegal"
	mov eastlegal, 0							;east is not legal
	jmp south										
	el:											;"east legal"
	mov eastlegal, 1							;otherwise, it is legal.
	south:;-------------------------------------;now determine if south is legal:
	cmp dl, 1									;if the ghost is facing north
		je sil										;south is illegal (ghosts can't arbitrarily reverse direction)
	mov bh, ch
	mov bl, cl
	inc bl										;bl now refers to the tile below ghost Y, checking if moving south is legal
	Call charAtXY								;returns the char at the referenced tile to al
	cmp al, '#'									;if the char is '#'
		jne sl									
	sil:										;"south illegal" (name had to be changed here because 'si' is reserved)
	mov southlegal, 0							;south is not legal
	jmp west									
	sl:											;"south legal"
	mov southlegal, 1							;otherwise, it is legal.
	west:;--------------------------------------;now determine if west is legal:
	cmp dl, 2									;if the ghost is facing east
	je wi										;west is illegal (ghosts can't arbitrarily reverse direction)
	mov bh, ch
	mov bl, cl
	dec bh										;bh now refers to the tile to the left of ghost X, checking if moving west is legal
	Call charAtXY								;returns the char at the referenced tile to al
	cmp al, '#'									;if the char is '#'
	jne wl									
	wi:											;"west illegal"
	mov westlegal, 0							;west is not legal
	jmp endchecks										
	wl:											;"west legal"
	mov westlegal, 1							;otherwise, it is legal.
	endchecks:
	ret
discardWallDirs endp

calculateDistance proc 							;calculate the distance for the ghost's 4 possible locations next frame from its target pass ghost X in ch, ghost Y in cl, ghost target X in dh, and ghost target Y in dl													
	edist:
	cmp eastlegal, 1
	jne sdist									;if east isn't a legal move don't bother calculating distance
	mov bl, ch								
	inc bl										;bl is now the X value of the tile to the right of the ghost
	mov al, dh									;al is now the X value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the x distance
	mov eastdist, al							;store it (=X)
	mov bl, cl									;bl is now the Y value of the ghost
	mov al, dl									;al is now the Y value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the y distance
	add eastdist, al							;add it (=X+Y)
	sdist:
	cmp southlegal, 1
	jne wdist									;if south isn't a legal move don't bother calculating distance
	mov bl, ch									;bl is now the X value of the ghost
	mov al, dh									;al is now the X value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the x distance
	mov southdist, al							;store it (=X)
	mov bl, cl								
	inc bl										;bl is now the Y value of the tile below the ghost
	mov al, dl									;al is now the Y value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the y distance
	add southdist, al							;add it (=X+Y)
	wdist:
	cmp westlegal, 1
	jne ndist									;if west isn't a legal move don't bother calculating distance
	mov bl, ch								
	dec bl										;bl is now the X value of the tile to the left of the ghost
	mov al, dh									;al is now the X value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the x distance
	mov westdist, al							;store it (=X)
	mov bl, cl									;bl is now the Y value of the ghost
	mov al, dl									;al is now the Y value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the y distance
	add westdist, al							;add it (=X+Y)
	ndist:
	cmp northlegal, 1
	jne endcalcin								;if north isn't a legal move don't bother calculating distance
	mov northdist, 0
	mov al, ch									;bl is now the X value of the ghost
	mov bl, dh									;al is now the X value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the x distance
	mov northdist, al							;store it (=X)
	mov bl, cl								
	dec bl										;bl is now the Y value of the tile above the ghost
	mov al, dl									;al is now the Y value of the ghost's target
	Call absoluteDistance						;use absoluteDist func to calculate the y distance
	add northdist, al							;add it (=X+Y)
	endcalcin:
	ret
calculateDistance endp

chooseGhostDir proc								;thankfully, since ghosts share variables for valid moves as it just handles them one at a time, they can all share this method this method returns the correct direction in al
	checknorth:;--------------------------------;check north
	cmp northlegal, 1
	jne checkwest								;if north isn't legal, skip factoring it in
	mov eax, 1									;otherwise set al to 'north'
	mov bl, northdist							;set bl to northdist because you can't compare mem to mem for no good reason
	cmp bl, westdist							;if north has <= distance to target than west does, west is illegal
	jg cmpn2s
	mov westlegal, 0
	cmpn2s:
	cmp bl, southdist							;if north has <= distance to target than south does, south is illegal
	jg cmpn2e
	mov southlegal, 0
	cmpn2e:
	cmp bl, eastdist							;if north has <= distance to target than east does, east is illegal
	jg checkwest
	mov eastlegal, 0
	checkwest:;---------------------------------;check west
	cmp westlegal, 1
	jne checksouth								;if west isn't legal, skip factoring it in
	mov eax, 4									;otherwise set al to 'west'
	mov bl, westdist							;set bl to westdist because you can't compare mem to mem for no good reason
	cmp bl, southdist							;if west has <= distance to target than south does, south is illegal
	jg cmpw2e
	mov southlegal, 0
	cmpw2e:
	cmp bl, eastdist							;if west has <= distance to target than east does, east is illegal
	jg checksouth
	mov eastlegal, 0
	checksouth:;--------------------------------;check south
	cmp southlegal, 1
	jne checkeast								;if south isn't legal, skip factoring it in
	mov eax, 3									;otherwise set al to 'south'
	mov bl, southdist							;set bl to southdist because you can't compare mem to mem for no good reason
	cmp bl, eastdist							;if south has <= distance to target than east does, east is illegal
	jg checkeast
	mov eastlegal, 0
	checkeast:;---------------------------------;check east
	cmp eastlegal, 1
	jne returndir
	mov eax, 2									;set al to east. if it hasn't been made 'illegal' by now, it must be the best option.
	returndir:		
	ret
chooseGhostDir endp

acquireG2Target proc							;pinky targeting scheme is 4 tiles ahead of where pac-man is facing
	cmp pacdir, 1								;north?
		jne eastcheck
	mov al, pacx								
	mov ghos2targx, al							;set ghos2targx to pacx
	mov al, pacy
	sub al, 4
	mov ghos2targy, al							;set ghos2targy to 4 tiles above pacy
		jmp targetacquired
eastcheck:		cmp pacdir, 2								;east?
				jne southcheck
				mov al, pacx	
				add al, 4							
				mov ghos2targx, al							;set ghos2targx to 4 tiles to the right of pacx
				mov al, pacy
				mov ghos2targy, al							;set ghos2targy to pacy
				jmp targetacquired
southcheck:	cmp pacdir, 3								;south?
			jne westcheck
			mov al, pacx						
			mov ghos2targx, al							;set ghos2targx to pacx
			mov al, pacy
			add al, 4
			mov ghos2targy, al							;set ghos2targy to 4 tiles below pacy
		jmp targetacquired
									
westcheck:		mov al, pacx					;no comparison cuz if it's not NES it's W
				sub al, 4
				mov ghos2targx, al				;set ghos2targx to 4 tiles to the left of pacx
				mov al, pacy
				mov ghos2targy, al				;set ghos2targy to pacy
				targetacquired:
	ret
acquireG2Target endp
	
acquireG3Target proc uses edx					;inky targeting scheme is double the distance from blinky's position and 2 tiles ahead of pac-man ;NOT DONE
	cmp pacdir, 1								;north?
	jne eastcheck
	mov al, pacx								
	mov ghos3targx, al							;set ghos3targx to pacx
	mov al, pacy
	sub al, 2
	mov ghos3targy, al							;set ghos3targy to 4 tiles above pacy
	jmp targetacquired
eastcheck:		cmp pacdir, 2								;east?
				jne southcheck
				mov al, pacx	
				add al, 2							
				mov ghos3targx, al							;set ghos3targx to 4 tiles to the right of pacx
				mov al, pacy
				mov ghos3targy, al							;set ghos3targy to pacy
				jmp targetacquired
southcheck:		cmp pacdir, 3								;south?
				jne westcheck
				mov al, pacx						
				mov ghos3targx, al							;set ghos3targx to pacx
				mov al, pacy
				add al, 2
				mov ghos3targy, al							;set ghos3targy to 4 tiles below pacy
				jmp targetacquired
										;no comparison cuz if it's not NES it's W
westcheck:	mov al, pacx						
			sub al, 2
			mov ghos3targx, al							;set ghos3targx to 4 tiles to the left of pacx
			mov al, pacy
			mov ghos3targy, al							;set ghos3targy to pacy
targetacquired:		mov dh, ghos3targx					;well only the offset target is acquired.
					mov dl, ghos3targy
					mov bl, ghos1x
					mov al, ghos3targx
					Call absoluteDistance				;use absoluteDist func to calculate the x distance
					cmp dh, ghos1x						;if blinky is to the right of 2 tiles ahead of pac man
					jge l2r
	
r2l:	sub ghos3targx, al							;move the target to the left equidistant from blinky		
		jmp ycheck
											
l2r:	add ghos3targx, al						;if blinky is the the left of 2 tiles ahead of pac man move the target to the right equidistant from blinky
		ycheck:
		mov bl, ghos1y
		mov al, ghos3targy
		Call absoluteDistance						;use absoluteDist func to calculate the x distance
		cmp dl, ghos1y								;if blinky is above the target
		jl d2u
	
u2d:	add ghos3targy, al							;move the target down equidistant from blinky		
		jmp noseriouslytargetacquired
											
d2u:	sub ghos3targy, al					    ;if blinky is the the left of 2 tiles ahead of pac man move the target up equidistant from blinky
		noseriouslytargetacquired:
		ret
acquireG3Target endp

acquireG4Target proc							;clyde targeting scheme is running to hardcoded target when near pac-man, chasing pac-man when far from him
	mov bl, ghos4x								;bl is now the x value of the ghost
	mov al, pacx								;al is now the x value of pac-man
	Call absoluteDistance						;use absoluteDist func to calculate the x distance
	mov dl, al									;store this distance in dl
	mov bl, ghos4y								;bl is now the Y value of the ghost
	mov al, pacy								;al is now the Y value of pac-man
	Call absoluteDistance						;use absoluteDist func to calculate the y distance
	add dl, al
	cmp dl, 8									;if ghos4 is within 8 tiles of pacman
	jne seeker
	mov ghos4targx, 0							;seek the predestined target
	mov ghos4targy, 31
	jmp targetacquired
	seeker:										;otherwise, seek pacman
	mov al, pacx
	mov ghos4targx, al
	mov al, pacy
	mov ghos4targy, al
	targetacquired:
	ret
acquireG4Target endp

directGhosts proc								;primary procedure that determines the ghosts' direction every frame, must be done one ghost at a time as they share some variables										
	mov ch, ghos1x								
	mov cl, ghos1y
	mov dl, ghos1dir
	Call discardWallDirs						;sets [north/south/west/east]legal to 1 or 0 depending on the values passed (based on walls and not being able to reverse direction)
	mov ch, ghos1x
	mov cl, ghos1y
	mov dh, pacx
	mov dl, pacy
	Call calculateDistance						;calculates the distance from target to the (legal) tiles north/south/east/west of the ghost
	Call chooseGhostDir							;uses those distances to choose the best direction (and return it in al)
	mov ghos1dir, al
	mov ch, ghos2x								
	mov cl, ghos2y
	mov dl, ghos2dir
	Call discardWallDirs						;sets [north/south/west/east]legal to 1 or 0 depending on the values passed (based on walls and not being able to reverse direction)
	Call acquireG2Target
	mov ch, ghos2x
	mov cl, ghos2y
	mov dh, ghos2targx
	mov dl, ghos2targy
	Call calculateDistance						;calculates the distance from target to the (legal) tiles north/south/east/west of the ghost
	Call chooseGhostDir							;uses those distances to choose the best direction (and return it in al)
	mov ghos2dir, al
	mov ch, ghos3x								
	mov cl, ghos3y
	mov dl, ghos3dir
	Call discardWallDirs						;sets [north/south/west/east]legal to 1 or 0 depending on the values passed (based on walls and not being able to reverse direction)
	Call acquireG3Target
	mov ch, ghos3x
	mov cl, ghos3y
	mov dh, ghos3targx
	mov dl, ghos3targy
	Call calculateDistance						;calculates the distance from target to the (legal) tiles north/south/east/west of the ghost
	Call chooseGhostDir							;uses those distances to choose the best direction (and return it in al)
	mov ghos3dir, al
	mov ch, ghos4x								
	mov cl, ghos4y
	mov dl, ghos4dir
	Call discardWallDirs						;sets [north/south/west/east]legal to 1 or 0 depending on the values passed (based on walls and not being able to reverse direction)
	Call acquireG4Target
	mov ch, ghos4x
	mov cl, ghos4y
	mov dh, ghos4targx
	mov dl, ghos4targy
	Call calculateDistance						;calculates the distance from target to the (legal) tiles north/south/east/west of the ghost
	Call chooseGhostDir							;uses those distances to choose the best direction (and return it in al)
	mov ghos4dir, al
	ret
directGhosts endp

tempPathfind proc								;just used to see if ghosts can successfully navigate the maze without breaking the rules, to be replaced with target-seeking pathfinding
	cmp northlegal, 1
	jne g1wgo
	mov ghos1dir, 1
	jmp g1done
	g1wgo:
	cmp westlegal, 1
	jne g1sgo
	mov ghos1dir, 4
	jmp g1done
	g1sgo:
	cmp southlegal, 1
	jne g1ego
	mov ghos1dir, 3
	jmp g1done
	g1ego:
	mov ghos1dir, 2
	g1done:
	ret
tempPathfind endp

charAtXY proc uses ebx ecx						;pass X in bh, Y in bl: returns the corresponding char in boardArray in al
	cmp bl, 0									;if Y is 0
	jne botcomp
	mov al, '#'									;the char is '#'
	jmp alldone
	botcomp:
		cmp bl, ROWS								;if Y is 31
		jne okfine
		mov al, '#'									;the char is '#'
		jmp alldone
	okfine:
		movzx cx, bh								;add x value to cx (index of char to be returned)
	addy:	
		dec bl										;row Y needs to add (Y-1)*28 to cx, this is why dec is first
		cmp bl, 0
		je returnchar								
		add cx, COLUMNS								;I coulda prolly used MULT but this seems easier
	jmp addy
	returnchar:
		mov al, BYTE PTR boardArray[ecx]			;returns the character at the correct location in boardArray
	alldone:
		ret
charAtXY endp

drawUnits proc
	mov bl, pacx								;in this case drawing pac-man's position
	add bl, bl									;doubles bl to account for spacing
	mov dh, pacy								;dh is used as the Y value in gotoXY
	dec dh										;row 1 = 0 in terms of gotoXY, so must -1
	mov dl, bl									;dl is used as the X value in gotoXY
	Call gotoxy									;overwrites the displayed char at XY with this one
	Call yellowtext
	mov al, pacChar
	Call writeChar
	mov eax, 12									;Setting 1st ghost color
	Call setTextColor
	mov bl, ghos1x								;in this case drawing ghost1's position
	add bl, bl									;doubles bl to account for spacing
	mov dh, ghos1y								;dh is used as the Y value in gotoXY
	Call writeGhost
	mov eax, 13									;Setting 2nd ghost color
	Call setTextColor
	mov bl, ghos2x								;in this case drawing ghost2's position
	add bl, bl									;doubles bl to account for spacing
	mov dh, ghos2y								;dh is used as the Y value in gotoXY
	Call writeGhost
	mov eax, 11									;Setting 3rd ghost color
	Call setTextColor
	mov bl, ghos3x								;in this case drawing ghost3's position
	add bl, bl									;doubles bl to account for spacing
	mov dh, ghos3y								;dh is used as the Y value in gotoXY
	Call writeGhost
	mov eax, 14									;Setting 4th ghost color
	Call setTextcolor
	mov bl, ghos4x								;in this case drawing ghost4's position
	add bl, bl									;doubles bl to account for spacing
	mov dh, ghos4y								;dh is used as the Y value in gotoXY
	Call writeGhost
	ret
drawUnits endp

writeGhost PROC
	dec dh										;row 1 = 0 in terms of gotoXY, so must -1
	mov dl, bl									;dl is used as the X value in gotoXY
	Call gotoxy
	mov al, 'G'									;overwrites the displayed char at XY with this one	
	Call writechar
ret
writeGhost ENDP

absoluteDistance proc							;used for calculating distance; need to get absolute value of the difference between the ghost's x,y and the target's x,y
;pass which two values to compare in bl and al (read: get abs(bl-al)), returned in al Mysteriously, this returns incorrect values for larger numbers that are still one byte. This is fixed by changing jl into jge
;but then it re-breaks the lower numbers and the logic doesn't make sense anyway. idkwtf. prolly something to do with overflows. luckily it will only be fed values 0-31, so it won't break.
	cmp al, bl								
	jl yolo										;if al is larger than bl
	sub al, bl									;subtract bl from al
	movzx eax, al
	jmp returndist
	yolo:										;but if bl is larger than al
	sub bl, al									;subtract al from bl
	movzx eax, bl								;mov bl to al for returning
	returndist:
	ret
absoluteDistance endp

gameOver proc
	Call clrscr									;clear the screen to output score
	mov dh, 12
	mov dl, 34
	Call gotoxy
	mov edx, offset thatsAllSheWrote
	Call writestring
	mov dh, 14
	mov dl, 28
	Call gotoxy
	mov edx, offset result
	Call writestring
	mov eax, totalScore
	Call writedec
	Call crlf
	mov eax, 1000						;delay when the window can close so that the user doesn't accidentally close the window
	call delay
	ret
gameOver endp

text PROC								;---------------------------------------;MS SPLASH SCREEN CODE
		Call SetTextColor
		mov al, bl
		Call WriteChar
ret
text ENDP
yellowText PROC							;SetTextToYellow
	mov eax, 14					
	Call setTextcolor					;---------------------------------------;MS
ret
yellowText ENDP
redText PROC							;Dark red text.
		mov eax, 4						;---------------------------------------;MS
		Call text
		Call yellowText
ret
redText ENDP
greenText PROC							;Bright green text.
		mov eax, 10						;---------------------------------------;MS
		Call Text
		Call yellowText
ret
greenText ENDP
blueText PROC							;Purplish text.
		mov eax, 13						;---------------------------------------;MS
		Call Text
		Call yellowText
ret
blueText ENDP
lightBlueText PROC						;light Blueish text.
		mov eax, 9						;---------------------------------------;MS
		Call Text
		Call yellowText
ret
lightBlueText ENDP
eyesAndPointsColor PROC					;Will set eyes color to white.
		Call WhiteText					;---------------------------------------;MS
		mov al, bl
		Call WriteChar
ret
eyesAndPointsColor ENDP

cmpEyes PROC							;Will save lines of code, and cmp character to ascii value of "O"
	mov al, bl							;---------------------------------------;MS
	cmp AL, 4Fh
ret
cmpEyes ENDP

spaceProc PROC							;Cleaning Up Code (Print 3 endline characters)
	Call crlf							;---------------------------------------;MS
	Call crlf
	Call crlf
ret
spaceProc ENDP

pacManWord PROC							;Will print the word PACMAN to screen
	Call yellowText						;---------------------------------------;MS
	mov ecx, 10							;This condenses SO MUCH CODE
	mov edx, OFFSET pac0-85				;87 is the difference between the offsets.
	printPacLoop:
		add edx, 85
		Call writeStrWithSP
	loop printPacLoop
ret
pacManWord ENDP

ghostImage PROC							;Will print the four ghosts to the screen.
	Call spaceProc						;---------------------------------------;MS
	mov esi, 0							;-----------------------------------;LINEONE
	line1:								;Will change the color of the first line of the ghosts.
		mov bl, ghost0[esi]
		inc esi
		cmp bl, 0h						;Looking for end of string to exit.
			je exx1
		cmp esi, 10						;First ghost color.
			jle pacNum11
		cmp esi, 18						;Second ghost color.
			jle pacNum12
		cmp esi, 26						;Third ghost color.
			jle pacNum13
		cmp esi, 33						;Fourth ghost color.
			jle pacNum14
		mov al, bl
		Call WriteChar
	jmp line1
	pacNum11:							;1st ghost 1st line setup
		Call RedText
		jmp line1
	pacNum12:							;2nd ghost 1st line setup
		Call greenText			
		jmp line1
	pacNum13:							;3rd ghost 1st line setup
		Call blueText
		jmp line1
	pacNum14:							;4th ghost 1st line setup
		Call lightBlueText
		jmp line1
	exx1:
		Call crlf
	mov esi, 0							;-----------------------------------;LINETWO
	line2:								;This will change the color of the eyes && print 2nd line of ghosts
		mov bl, ghost1[esi]
		inc esi
		cmp bl, 0h
			je exx2
		cmp esi, 11						;First ghost color.
			jle pacNum21
		cmp esi, 19						;Second ghost color.
			jle pacNum22
		cmp esi, 27						;Third ghost color.
			jle pacNum23
		cmp esi, 34						;Fouth ghost color.
			jle pacNum24 
		cmp bl, 2Ah						;Looking for * symbol to set white.
			je points1
		mov al, bl
		Call WriteChar
	jmp line2
	pacNum21:							;1st ghost setup 2nd line
		Call cmpEyes
		je eyesAndPoints
		Call Redtext
		jmp line2
	pacNum22:							;2nd ghost setup 2nd line
		Call cmpEyes
		je eyesAndPoints
		Call greenText
		jmp line2
	pacNum23:							;3rd ghost setup 2nd line
		Call cmpEyes	
		je eyesAndPoints
		Call blueText
		jmp line2
	pacNum24:
		Call cmpEyes
		je eyesAndPoints
		Call lightblueText
		jmp line2
	points1:
		Call eyesAndPointsColor
		jmp line2
	eyesAndPoints:						;Eye color
		Call eyesAndPointsColor
		jmp line2
	exx2:
		Call crlf
	mov esi, 0								;-----------------------------------;LINETHREE
	line3:									;Will print 3rd line of ghosts and change the points to white
		mov bl, ghost2[esi]
		inc esi
		cmp bl, 0h							;Last character to exit.
			je exx3
		cmp esi, 11							;1st ghost color
			jle pacNum31
		cmp esi, 19							;2nd ghost color
			jle pacNum32
		cmp esi, 27							;Third ghost color.
			jle pacNum33
		cmp esi, 34
			jle pacNum34
		cmp bl, 2Ah							;Looking for * symbol to set white.
		je points2
		mov al, bl
		Call WriteChar
	jmp line3
	pacNum31:								;1st ghost 3rd line setup
		Call RedText
		jmp line3
	pacNum32:								;2nd ghost 3rd line setup
		Call cmpEyes
		je eyesAndPoints
		Call greenText
		jmp line3
	pacNum33:								;3rd ghost 3rd line setup
		Call cmpEyes
		je eyesAndPoints
		Call blueText
		jmp line3
	pacNum34:
		Call cmpEyes
		je eyesAndPoints
		Call lightBlueText
		jmp line3
	points2:
		Call eyesAndPointsColor
		jmp line3
	exx3:
		Call crlf
	mov esi, 0							;-----------------------------------;LINEFOUR
	line4:								;Will change the color of the first line of the ghosts.
		mov bl, ghost3[esi]
		inc esi
		cmp bl, 0h						;Looking for last character to exit.
			je exx4
		cmp esi, 11						;Setting color of 1st ghost
			jle pacNum41
		cmp esi, 19						;Setting color of 2nd ghost
			jle pacNum42
		cmp esi, 27						;Setting color of 3rd ghost
			jle pacNum43
		cmp esi, 34
			jle pacNum44
		mov al, bl
		Call WriteChar
	jmp line4
	pacNum41:							;1st ghost 4th line setup
		Call RedText
		jmp line4
	pacNum42:							;2nd ghost 4th line setup 
		Call cmpEyes
		je eyesAndPoints
		Call greenText
		jmp line4
	pacNum43:							;3rd ghost 4th line setup
		Call cmpEyes
		je eyesAndPoints
		Call blueText
		jmp line4
	pacNum44:
		Call cmpEyes
		je eyesAndPoints
		Call lightBlueText
		jmp line4
	exx4:
	Call crlf
ret
ghostImage ENDP

whiteText PROC									;---------------------------------------;MS
	mov eax, 15
	Call SetTextColor
ret
whiteText ENDP

menuOption PROC									;---------------------------------------;MS
	Call WhiteText
	Call spaceProc
	Call crlf
	mov edx, OFFSET startGame
	Call WriteString
ret
menuOption ENDP

splashScreen PROC								;This will print the splash screen before the game. 
	Call spaceProc								;---------------------------------------;MS
	mov edx, OFFSET createdBy					;Will print our team member names
	Call WriteString
	Call spaceProc
	Call pacManWord								;Will print the PACMAN in symbols
	Call ghostImage								;Will print the ghosts to the screen
	Call menuOption								;Will print out menu options
	Call spaceProc								;Putting spaces in splash screen.
ret 
splashScreen ENDP

splashMenuWithoutMenuOptions PROC				;---------------------------------------;MS
	Call spaceProc
	mov edx, OFFSET createdBy					;Will print our team member names
	Call WriteString
	Call spaceProc
	Call pacManWord								;Will print the PACMAN in symbols
	mov eax, 13
	Call setTextColor
	call crlf
	mov edx, OFFSET directions1
	Call writeStrWithSP
	mov edx, OFFSET directions2
	Call writeStrWithSP
	mov edx, OFFSET directions3
	Call writeStrWithSP
	mov edx, OFFSET directions5
	Call writeStrWithSP
	Call spaceProc
	Call WhiteText
	mov edx, OFFSET PRESSS
	Call writeStrWithSP
ret
splashMenuWithoutMenuOptions ENDP

pacManControls PROC							;---------------------------------------;MS
	Call ReadKey							;Will read controls for pacman.				
	mov BH, pacx
	mov BL, pacy
	.IF AL == 's'
		inc BL								;This will point to the space below the pacman	
		Call charAtXY						;This will put the chacter below the pacman into the AL part of the EAX register
		mov pacDir, 3
		mov pacChar, '^'
		.IF AL != '#'						;If the character is a wall it is not a legal move.
			inc pacy						;if not a wall it can move
			call ghostsvspacman
		.ENDIF
	.ELSEIF AL == 'w'
		dec BL							
		Call charAtXY						
		mov pacDir, 1
		mov pacChar, 'v'
		.IF AL != '#'						
			dec pacy
			call ghostsvspacman
		.ENDIF
	.ELSEIF AL == 'd'
		inc BH							
		Call charAtXY						
		mov pacDir, 2
		mov pacChar, '<'
		.IF AL != '#' || pacx == 27						
			inc pacx
			call ghostsvspacman						
		.ENDIF	
	.ELSEIF AL == 'a' 
		dec BH							
		Call charAtXY		
		mov pacDir, 4	
		mov pacChar, '>'			
		.IF AL != '#'				
			dec pacx
			call ghostsvspacman						
		.ENDIF
	.ENDIF
	cmp pacx, -1								;once pacman goes beyond the 0 position, he is in the teleporter
	je teleportPacMan1
	cmp pacx, 28								;if pacman is in the 28th position, he is in the teleporter
	je teleportPacMan2
	jmp nothingHere
	teleportPacMan1:
		mov pacx, 27								;pacman's x position is moved to the teleporter across the map
		jmp nothingHere
	teleportPacMan2:
		mov pacx, 0									;pacman's x position is moved to the teleporter on the opposite side of the map
	nothingHere:
	ret
pacManControls ENDP

youWon proc
	call clrscr									;clear screen to display score
	mov dh, 12
	mov dl, 34
	call gotoxy
	mov edx, offset chickenDinner
	call writestring
	mov dh, 14
	mov dl, 32
	call gotoxy
	mov edx, offset outputScore
	call writestring
	mov eax, totalScore
	call writedec
	call crlf
	mov eax, 1000								;delay so user does not accidentally close the window instantly
	call delay
	exit
youWon endp

main PROC
	Call splashScreen							;Splash Screen Procedure
	mov pacChar, '<'
	tryAgain:
		Call readChar							;Will read input char from user.
		.IF AL == 's'							;If input is 's' clear the screen.
			Call clrscr
			jmp drawFrame
		.ELSEIF AL == 'c'							;If the input is 'c' then go to the control page.
			je control
		.ELSE
			jmp tryAgain
		.ENDIF	
	control:									;Will bring up control menu.
		Call clrscr
		Call splashMenuWithoutMenuOptions
		Call ReadChar							;Read character to start game.
		Call clrscr								;Clear splash screen off to load game.
		Call WhiteText							;Change text color back to white.
	drawFrame:
		Call pacManControls						;Will control the movement of the pacman 
		Call drawStringBoard					;draws the game board
		Call moveGhosts
		Call ghostsVsPacman
		Call directGhosts
		Call drawUnits							;overlays the units (pac-man and ghosts)
		Call removePellet						;changes the char on the game board corresponding to where pac-man is to ' '
		Call PacPellet
		Call Lives
		Call crlf
		mov eax, 450							;millisecond delay between frame draws
		Call delay
		cmp totalLives, 0						;after no lives are left and a ghost catches you, you lose
			jl donions
		cmp totalScore, 2470					;247 pellets on map all worth 10 points
			jl drawFrame
			jge winner
	winner:
		mov eax, 200
		call delay
		call youWon
	donions:
		mov eax, 200
		Call delay
		Call gameOver
	exit
main ENDP
END main