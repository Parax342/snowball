       identification division.
       program-id. ticktest.
       author. Miley Scioscia.
       date-written. 9/24/2026.

       environment division.

       data division.
       file section.
       working-storage section.
       01 DateString pic x(16).
       01 CurTime pic 9(16).
       01 NextTick pic 9(16).
       01 TickTime pic 99 value 25.
       01 MinTickTime constant 10.
       
       01 IsKeyPressed pic S9(9).
       01 InputKey pic 999 value zeros.
           88 IsW value 119, 087.
           88 IsA value 097, 065.
           88 IsS value 115, 083.
           88 IsD value 100, 068.
           88 IsEnter value 013.
           88 IsQ value 113, 081.
           88 IsP value 112, 080.
           88 IsArrowStart value 224.
           88 IsUp value 072.
           88 IsDw value 080.
           88 IsLf value 075.
           88 IsRi value 077.
       01 GameKey pic x.
           88 IsGameKey value "U", "D", "L", "R", "P", "E", "Q".
           88 IsDirKey value "U", "D", "L", "R".
           88 IsPauseKey value "P".
           88 IsStartKey value "E".
           88 IsQuitKey value "Q".
       
       01 Snake.
           03 Piece occurs 256 times indexed by P.
               05 PieceX pic 9(2).
               05 PieceY pic 9(2).
       01 SnakeDir pic x value "R".
       01 SnakeLength pic 999 value 4.

       01 Apple.
           02 AppleX pic 99.
           02 AppleY pic 99.
       01 RandomPos pic 99v99.

       01 ScreenData pic x(648). *> 36*18 ((16*2)x16 play area + border)
       01 ScreenLine pic 99 value 0.
       01 ScreenLineStart pic 9(4).
       01 ScreenLineEnd pic 9(4).

       01 GameState pic x.
           88 IsTitle value "T".
           88 IsPlay value "G".
           88 IsPause value "P".
           88 IsDie value "D".

       
       procedure division.
       
       set IsTitle to true.
       perform MainLoop.

       InitGame.

           set P to 4.
           move 0202 to Piece(P).
           set P to 3.
           move 0302 to Piece(P).
           set P to 2.
           move 0402 to Piece(P).
           set P to 1.
           move 0502 to Piece(P).
    
           set Apple to 0909.
    
           set SnakeLength to 4.

           set TickTime to 25.

           set SnakeDir to "R".
    
           set IsPlay to true.

       exit paragraph.
       
       GetTime.
           set DateString to function current-date.
           set CurTime to DateString.
       exit paragraph.
       
       SetNextTick.
           perform GetTime.
           compute NextTick = CurTime + TickTime.
       exit paragraph.

       GetInput.
           call "kbhit" returning IsKeyPressed.
           if not IsKeyPressed = 0 then
               call "getch" returning InputKey
       
               evaluate true
                   when IsW set GameKey to "U"
                   when IsS set GameKey to "D"
                   when IsA set GameKey to "L"
                   when IsD set GameKey to "R"
                   When IsEnter set GameKey to "E"
                   When IsQ set GameKey to "Q"
                   When IsP set GameKey to "P"
                   when IsArrowStart perform GetArrowKey
                   when other set GameKey to "N"
               end-evaluate
           end-if.
       exit paragraph.

       GetArrowKey.
           call "cob_getch" returning InputKey.
           evaluate true
               when IsUp set GameKey to "U"
               when IsDw set GameKey to "D"
               when IsLf set GameKey to "L"
               when IsRi set GameKey to "R"
               when other set GameKey to "N"
           end-evaluate.
       exit paragraph.

       TurnSnake.
           if IsDirKey and
           not (GameKey = "U" and SnakeDir = "D") and
           not (GameKey = "D" and SnakeDir = "U") and
           not (GameKey = "L" and SnakeDir = "R") and
           not (GameKey = "R" and SnakeDir = "L") then
               set SnakeDir to GameKey
           end-if.
       exit paragraph.

       MoveSnake.
           set Piece(SnakeLength + 1) to Piece(SnakeLength)

           perform
           varying P from SnakeLength by -1
           until P < 2
               set Piece(P) to Piece(P - 1)
           end-perform.

           evaluate true
               when SnakeDir = "U" subtract 1 from PieceY(1)
               when SnakeDir = "D" add 1 to PieceY(1)
               when SnakeDir = "L" subtract 1 from PieceX(1)
               when SnakeDir = "R" add 1 to PieceX(1)
           end-evaluate.

           perform
           varying P from 2 by 1
           until P > SnakeLength
               if Piece(P) = Piece(1) then
                   set IsDie to true
               end-if
           end-perform.

           if Apple = Piece(1) then
               perform EatApple
           end-if.

           if PieceY(1) <= 00 or
           PieceY(1) >= 17 or
           PieceX(1) <= 00 or
           PieceX(1) >= 17 then
               set IsDie to true
           end-if.

       exit paragraph.

       EatApple.
           add 1 to SnakeLength.
           set TickTime to function max(TickTime - 1, MINTICKTIME).

           set RandomPos to function random.
           compute RandomPos = RandomPos * 16.
           move RandomPos to AppleX.
           add 1 to AppleX.

           set RandomPos to function random.
           compute RandomPos = RandomPos * 16.
           move RandomPos to AppleY.
           add 1 to AppleY.
       exit paragraph.

       BuildScreen.
           set ScreenData to zeros.
           set ScreenData(1:36)
               to "]]=========== SNOWBALL ===========[[".
           perform varying ScreenLine from 2 by 1 until ScreenLine > 17
               set ScreenData(ScreenLine*36 - 35:36)
                   to " |................................| "
           end-perform.
           set ScreenData(613:36)
               to "]]================================[[".

           evaluate true
               when IsTitle perform BuildScreenTitle
               when IsPlay perform BuildScreenPlay
               when IsPause perform BuildScreenPause
               when IsDie perform BuildScreenDie
           end-evaluate.
       exit paragraph.

       BuildScreenTitle.
           set ScreenData(36*3 + 4:30) to
               "******************************".
           set ScreenData(36*4 + 4:30) to
               "* .--. .-..-. .--. .-.   .-. *".
           set ScreenData(36*5 + 4:30) to
               "*: .--': ': :: .. :: :.-.: : *".
           set ScreenData(36*6 + 4:30) to
               "*'. '. : .  :: :: :: :: :: : *".
           set ScreenData(36*7 + 4:30) to
               "* _'. :: :. :: :: :: '' '' : *".
           set ScreenData(36*8 + 4:30) to
               "*'.__.':_::_:'.__.' '..'..'  *".
           set ScreenData(36*9 + 4:30) to
               "*  .---.  .--. .-.   .-.     *".
           set ScreenData(36*10 + 4:30) to
               "*  : .; :: .: :: :   : :     *".
           set ScreenData(36*11 + 4:30) to
               "*  :   .':    :: :   : :     *".
           set ScreenData(36*12 + 4:30) to
               "*  : .; :: :: :: :__ : :__   *".
           set ScreenData(36*13 + 4:30) to
               "*  :___.':_::_::___.':___.'  *".
           set ScreenData(36*14 + 4:30) to
               "******************************".
           set ScreenData(36*15 + 8:22) to
               " PRESS ENTER TO START ".
               
       exit paragraph.

       BuildScreenPlay.
           string " Length:" SnakeLength " " into ScreenData(617:12)

           perform 
           varying P from SnakeLength by -1
           until Piece(P) = 0000 or P < 1
               set ScreenData(1 + (PieceX(P) * 2) + PieceY(P) * 36:2)
                   to "()"
           end-perform.
           
           set ScreenData(1 + (AppleX * 2) + AppleY * 36:2) to "{}"
       exit paragraph.

       BuildScreenPause.
           perform BuildScreenPlay.
           perform BuildScreenDie.
           set ScreenData(36*7 + 8:22) to
               "*    GAME PAUSED     *".
       exit paragraph.

       BuildScreenDie.
           perform 
           varying P from SnakeLength by -1
           until Piece(P) = 0000 or P < 1
               set ScreenData(1 + (PieceX(P) * 2) + PieceY(P) * 36:2)
                   to "XX"
           end-perform.

           set ScreenData(36*6 + 8:22) to
               "**********************".
           set ScreenData(36*7 + 8:22) to
               "*      YOU DIED!     *".
           set ScreenData(36*8 + 8:22) to
               "* Score: xxx         *".
           set ScreenData(36*9 + 8:22) to
               "* Q to quit          *".
           set ScreenData(36*10 + 8:22) to
               "* Enter to continue  *".
           set ScreenData(36*11 + 8:22) to
               "**********************".
               
           set ScreenData(36*8 + 17:3) to
               SnakeLength.

       exit paragraph.

       DrawScreen.
           call "SYSTEM" using "cls".
           perform varying ScreenLine from 1 by 1 until ScreenLine > 18
               display ScreenData(ScreenLine*36 - 35:36)
           end-perform.
       exit paragraph.

       MainLoop.

           if IsTitle or IsPause then

               perform BuildScreen
               perform DrawScreen

               perform until IsStartKey or IsQuitKey
                   perform GetInput
               end-perform
               
               if IsQuitKey
                   stop run
               end-if
               
               evaluate true
                   when IsTitle perform InitGame
                   when IsPause 
                       set IsPlay to true
                       set GameKey to "N"
               end-evaluate
           end-if.

           if IsPlay then

               perform until CurTime >= NextTick
                   perform GetTime
                   perform GetInput
               end-perform

               if IsPauseKey then
                   set IsPause to true
               end-if
               
               if not IsPause then
                   perform TurnSnake
                   perform MoveSnake
               end-if

               perform BuildScreen
               
               perform SetNextTick
               
               perform DrawScreen
           end-if.

           if IsDie then
               perform BuildScreen
               perform DrawScreen

               perform until IsStartKey or IsQuitKey
                   perform GetInput
               end-perform
               
               if IsQuitKey
                   stop run
               end-if
               
               set GameKey to "N"
               set IsTitle to true
           end-if

       go to MainLoop.
       
       stop run.
