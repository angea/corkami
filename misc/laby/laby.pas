{
 a maze generator in Turbo Pascal 3.0

 Ange Albertini, BSD Licence 2013

 1/ execute turbo.com
 2/ choose "W"ork file, "LABY.PAS"
 3/ "R"un
}
Program Laby;

{$I Graph.p}

const
    W = 64;
    H = 64;
    COLOR = 3;


procedure Init;

begin
    ClrScr;
    GraphColorMode;

    (* draw the box *)
    Draw(0, 0, 2 * W + 2, 0, COLOR);
    Draw(0, 0, 0, 2 * H + 2, COLOR);
    Draw(0, 2 * H + 2, 2 * W + 2, 2 * H + 2, COLOR);
    Draw(2 * W + 2, 0, 2 * W + 2, 2 * H + 2, COLOR);

    (* draw start, end and first points *)
    Draw(1, 2, 2, 2, COLOR);
    Plot(2 * W + 1, 2 * H, COLOR);
end;


procedure Main;

var
    X, Y: integer;
    XD, YD: integer;
    counter: integer;
    direction: integer;
    label loopstart;

begin
    counter := W * H - 1;
    while counter > 0 do
    begin
loopstart:
        (* get an random empty start point *)
        X := 2 * Random(W) + 2;
        Y := 2 * Random(H) + 2;
        if GetDotColor(X, Y) <> COLOR then goto loopstart;

        (* pick a direction for target *)
        direction := Random(4);
        XD := 0;
        YD := 0;
        case direction of
        0: XD := -1;
        1: XD :=  1;
        2: YD := -1;
        3: YD :=  1;
        end{case};

        (* check if target is already used *)
        if GetDotColor(X + 2 * XD, Y + 2 * YD) <> COLOR
        then begin
            Draw(X, Y, X + 2 * XD, Y + 2 * YD, COLOR);
            counter := counter - 1;
        end{if};

    end{while};
end{procedure};


procedure CleanUp;

var
    Ch: char;

begin
    gotoxy(1, 25);
    write('Press any key');

    repeat until KeyPressed;
    read(Kbd,Ch);

    TextMode;
end{procedure};


begin
    Init;
    Main;
    CleanUp;
end.
