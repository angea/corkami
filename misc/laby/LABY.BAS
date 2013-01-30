1 ' a maze generation program in GW-BASIC [1988] (it used to be a one-liner)
2 ' Ange Albertini, BSD Licence 2013
3 ' load with LOAD"LABY.BAS" then RUN
10 SCREEN(9):CLS ' screen init
20 RANDOMIZE TIMER ' seed init
21 W = 32 : H = 32 : mycol = 15: COLOR mycol
30 LINE (0,0)-(2 * W + 2,2 * H + 2), , B ' drawing the box
40 LINE (1,2)-(2,2): PSET (2 * W + 1, 2 * H) ' drawing the start and end points
50 count = W  * H - 1 ' points left to join
60 WHILE count > 0
70 X = 2 * INT(RND*W) + 2: Y = 2 * INT(RND*H) + 2 ' choose randomly a start point
72 if POINT(X,Y) = 0 then GOTO 70 ' not already drawn? retry
73 DIRECTION = INT(RND*4) ' scan in a random position
74 IF DIRECTION = 0 then XD = -1: YD =  0: GOTO 80
75 IF DIRECTION = 1 then XD =  1: YD =  0: GOTO 80
76 IF DIRECTION = 2 then XD =  0: YD = -1: GOTO 80
77 IF DIRECTION = 3 then XD =  0: YD =  1: GOTO 80
80 IF POINT(X + 2 * XD, Y + 2 * YD) = 0 THEN LINE(X,Y)-(X + 2 * XD, Y + 2 * YD),MYCOL else GOTO 70 ' if the target point is clear, then draw the line
90 count = count - 1 ' another one bites the dust
100 WEND
110 LOCATE 20, 1
