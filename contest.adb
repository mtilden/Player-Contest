--Name: Madison Tilden
--Date: May 03, 2014
--Purpose: program simulates a double elimination contest
-- After all players have been input, pairs of players are
-- repeatedly formed and the members of a pair play a match
-- against each other. As described below, the skill level
-- (and perhaps some other information) determines who wins the match.
-- Players are eliminated from the competition when they have two losses.

--The output of your program should consist of the following information for each player, in columns with one line per player:

--Name
--Arrival number (eg first player to arrive is number 1)
--Skill level
--Number of wins
--Number of losses

WITH Ada.Text_IO; USE Ada.Text_IO;
WITH Ada.Integer_Text_IO; USE Ada.Integer_Text_IO;
WITH dynamic_queue_pkg;
WITH dynamic_stack_pkg;

PROCEDURE Contest IS

   -- creates type contestant
   TYPE Contestant IS RECORD
      Name : String(1 .. 20);      -- name length 30
      Arriv_Num: Integer;          --Arrival Number
      Skill: Integer;              --Skill level
      Wins: Integer := 0;          --Number of wins set to 0
      Fails: Integer := 0;         --Number of times you failed
   END RECORD;
   type Player_Ptr is access Contestant;
   PACKAGE ContestStack IS NEW dynamic_stack_pkg(Player_Ptr);
   USE ContestStack;
   PACKAGE ContestQueue IS NEW dynamic_queue_pkg(Player_Ptr);
   USE ContestQueue;

   PlayerInfo : Queue; -- holds all the players and their info
   OneFailure : Queue; -- players after first round
   TwoFailures : Stack; -- puts players in final order of elimination
   Counter : Integer := 0;  --arrival counter
   Plyr1 : Contestant; -- player one
   Plyr2 : Contestant; -- player two for games

BEGIN

   WHILE NOT End_Of_File LOOP

      Get(Plyr1.Name);         -- get player name
      Plyr1.Arriv_Num := Counter + 1; -- incements plyr1 arriv_num
      Counter := Counter + 1; -- increments counter var
      Get(Plyr1.Skill);         -- get player skill level
      enqueue(Plyr1, PlayerInfo); -- adds plyr1 to playerInfo

   END LOOP;


  -----------------------------------------------------------------
   --first round of challenges


   FOR A IN 1 .. (Counter - 1) LOOP

      Plyr1 := Front(PlayerInfo);
      Dequeue(PlayerInfo);
      Plyr2 := Front(PlayerInfo);
      Dequeue(PlayerInfo);

      IF Plyr1.Skill > Plyr2.Skill THEN
         Plyr1.Wins := Plyr1.Wins + 1;
         Plyr2.Fails := Plyr2.Fails + 1;
         Enqueue(Plyr1, PlayerInfo);
         Enqueue(Plyr2, OneFailure);

      ELSIF Plyr1.Skill < Plyr2.Skill THEN
         Plyr1.Fails := Plyr1.Fails + 1;
         Plyr2.Wins := Plyr2.Wins + 1;
         Enqueue(Plyr2, PlayerInfo);
         Enqueue(Plyr1, OneFailure);

      ELSE -- Plyr1.Skill = Plyr2.Skill THEN

         ---------------------------------------------------------------
         -- if plyr1 and plyr2 skill are equal then the winner is
         -- decided by who has more wins
         IF Plyr1.Wins > Plyr2.Wins THEN --plyr1 wins is more
           Plyr1.Wins := Plyr1.Wins + 1;
           Plyr2.Fails := Plyr2.Fails + 1;
           Enqueue(Plyr1, PlayerInfo);
           Enqueue(Plyr2, OneFailure);
         ELSIF Plyr1.Wins < Plyr2.Wins THEN  -- plyr2 wins is more
            Plyr1.Fails := Plyr1.Fails + 1;
            Plyr2.Wins := Plyr2.Wins + 1;
            Enqueue(Plyr2, PlayerInfo);
            Enqueue(Plyr1, OneFailure);
         ELSE
              ----------------------------------------------------------
              -- if plyr1 and plyr2 skill are equal then the winner is
              -- decided by who has less losses
            IF Plyr1.Fails < Plyr2.Fails THEN --plyr1 fails is less
                 Plyr1.Wins := Plyr1.Wins + 1;
                 Plyr2.Fails := Plyr2.Fails + 1;
                 Enqueue(Plyr1, PlayerInfo);
                 Enqueue(Plyr2, OneFailure);
            ELSIF Plyr1.Fails > Plyr2.Fails THEN  -- plyr2 wins is more
                 Plyr1.Fails := Plyr1.Fails + 1;
                 Plyr2.Wins := Plyr2.Wins + 1;
                 Enqueue(Plyr2, PlayerInfo);
                 Enqueue(Plyr1, OneFailure);
            ELSE
                  -----------------------------------------------------
                  -- then decided by who came first if still a tie
                  IF Plyr1.Arriv_Num < Plyr2.Arriv_Num THEN
                       Plyr1.Wins := Plyr1.Wins + 1;
                       Plyr2.Fails := Plyr2.Fails + 1;
                       Enqueue(Plyr1, PlayerInfo);
                       Enqueue(Plyr2, OneFailure);
                  ELSE
                       Plyr2.Wins := Plyr2.Wins + 1;
                       Plyr1.Fails := Plyr1.Fails + 1;
                       Enqueue(Plyr2, PlayerInfo);
                       Enqueue(Plyr1, OneFailure);
                  END IF;  -- end if tie by Arriv_NuM
                  -------------------------------------------------------
         END IF; -- end if tie by fewer failures
         ----------------------------------------------------------------
        END IF; -- end if tie by more wins
        -----------------------------------------------------------------
      END IF; -- end if to figure out who wins

   END LOOP;



-------------------------------------------------------------------------
-- END FIRST ROUND, START ROUND 2


     FOR A IN 1 .. (Counter - 2) LOOP

      Plyr1 := Front(OneFailure);
      Dequeue(OneFailure);
      Plyr2 := Front(OneFailure);
      Dequeue(OneFailure);

      IF Plyr1.Skill > Plyr2.Skill THEN
         Plyr1.Wins := Plyr1.Wins + 1;
         Plyr2.Fails := Plyr2.Fails + 1;
         Enqueue(Plyr1, OneFailure);
         Push(Plyr2, TwoFailures);

      ELSIF Plyr1.Skill < Plyr2.Skill THEN
         Plyr1.Fails := Plyr1.Fails + 1;
         Plyr2.Wins := Plyr2.Wins + 1;
         Enqueue(Plyr2, OneFailure);
         Push(Plyr1, TwoFailures);

      ELSE --Plyr1.Skill = Plyr2.Skill THEN

         ---------------------------------------------------------------
         -- if plyr1 and plyr2 skill are equal then the winner is
         -- decided by who has more wins
         IF Plyr1.Wins > Plyr2.Wins THEN --plyr1 wins is more
           Plyr1.Wins := Plyr1.Wins + 1;
           Plyr2.Fails := Plyr2.Fails + 1;
           Enqueue(Plyr1, OneFailure);
           Push(Plyr2, TwoFailures);
         ELSIF Plyr1.Wins < Plyr2.Wins THEN  -- plyr2 wins is more
            Plyr1.Fails := Plyr1.Fails + 1;
            Plyr2.Wins := Plyr2.Wins + 1;
            Enqueue(Plyr2, OneFailure);
            Push(Plyr1, TwoFailures);
         ELSE
              ----------------------------------------------------------
              -- if plyr1 and plyr2 skill are equal then the winner is
              -- decided by who has less losses
            IF Plyr1.Fails < Plyr2.Fails THEN --plyr1 fails is less
                 Plyr1.Wins := Plyr1.Wins + 1;
                 Plyr2.Fails := Plyr2.Fails + 1;
                 Enqueue(Plyr1, OneFailure);
                 Push(Plyr2, TwoFailures);
            ELSIF Plyr1.Fails > Plyr2.Fails THEN  -- plyr2 wins is more
                 Plyr1.Fails := Plyr1.Fails + 1;
                 Plyr2.Wins := Plyr2.Wins + 1;
                 Enqueue(Plyr2, OneFailure);
                 Push(Plyr1, TwoFailures);
            ELSE
                  -----------------------------------------------------
                  -- then decided by who came first if still a tie
                  IF Plyr1.Arriv_Num < Plyr2.Arriv_Num THEN
                       Plyr1.Wins := Plyr1.Wins + 1;
                       Plyr2.Fails := Plyr2.Fails + 1;
                       Enqueue(Plyr1, OneFailure);
                       Push(Plyr2, TwoFailures);
                  ELSE
                       Plyr2.Wins := Plyr2.Wins + 1;
                       Plyr1.Fails := Plyr1.Fails + 1;
                       Enqueue(Plyr2, OneFailure);
                       Push(Plyr1, TwoFailures);
                  END IF;  -- end if tie by Arriv_NuM
                  -------------------------------------------------------
         END IF; -- end if tie by fewer failures
         ----------------------------------------------------------------
        END IF; -- end if tie by more wins
        -----------------------------------------------------------------
      END IF; -- end if to figure out who wins

   END LOOP;


   -------------------------------------------------------------------------
   -- END OF ROUND 2
   -- BEGINNING OF ROUND 3
   Plyr1 := Front(PlayerInfo);
   Dequeue(PlayerInfo);
   Plyr2 := Front(OneFailure);
   Dequeue(OneFailure);

      IF Plyr1.Skill > Plyr2.Skill THEN
         Plyr1.Wins := Plyr1.Wins + 1;
         Plyr2.Fails := Plyr2.Fails + 1;
         Push(Plyr2, TwoFailures);
         Push(Plyr1, TwoFailures);

      ELSIF Plyr1.Skill < Plyr2.Skill THEN
         Plyr1.Fails := Plyr1.Fails + 1;
         Plyr2.Wins := Plyr2.Wins + 1;
         Push(Plyr1, TwoFailures);
         Push(Plyr2, TwoFailures);

      ELSE -- Plyr1.Skill = Plyr2.Skill THEN

         ---------------------------------------------------------------
         -- if plyr1 and plyr2 skill are equal then the winner is
         -- decided by who has more wins
         IF Plyr1.Wins > Plyr2.Wins THEN --plyr1 wins is more
              Plyr1.Wins := Plyr1.Wins + 1;
              Plyr2.Fails := Plyr2.Fails + 1;
              Push(Plyr1, TwoFailures);
              Push(Plyr2, TwoFailures);
         ELSIF Plyr1.Wins < Plyr2.Wins THEN  -- plyr2 wins is more
              Plyr1.Fails := Plyr1.Fails + 1;
              Plyr2.Wins := Plyr2.Wins + 1;
              Push(Plyr1, TwoFailures);
              Push(Plyr2, TwoFailures);
         ELSE
              ----------------------------------------------------------
              -- if plyr1 and plyr2 skill are equal then the winner is
              -- decided by who has less losses
            IF Plyr1.Fails < Plyr2.Fails THEN --plyr1 fails is less
                 Plyr1.Wins := Plyr1.Wins + 1;
                 Plyr2.Fails := Plyr2.Fails + 1;
                 Push(Plyr1, TwoFailures);
                 Push(Plyr2, TwoFailures);
            ELSIF Plyr1.Fails > Plyr2.Fails THEN  -- plyr2 wins is more
                 Plyr1.Fails := Plyr1.Fails + 1;
                 Plyr2.Wins := Plyr2.Wins + 1;
                 Push(Plyr1, TwoFailures);
                 Push(Plyr2, TwoFailures);
            ELSE
                  -----------------------------------------------------
                  -- then decided by who came first if still a tie
                  IF Plyr1.Arriv_Num < Plyr2.Arriv_Num THEN
                       Plyr1.Wins := Plyr1.Wins + 1;
                       Plyr2.Fails := Plyr2.Fails + 1;
                       Push(Plyr1, TwoFailures);
                       Push(Plyr2, TwoFailures);
                  ELSE
                       Plyr2.Wins := Plyr2.Wins + 1;
                       Plyr1.Fails := Plyr1.Fails + 1;
                       Push(Plyr1, TwoFailures);
                       Push(Plyr2, TwoFailures);
                  END IF;  -- end if tie by Arriv_NuM
                  -------------------------------------------------------
         END IF; -- end if tie by fewer failures
         ----------------------------------------------------------------
        END IF; -- end if tie by more wins
        -----------------------------------------------------------------
      END IF; -- end if to figure out who wins


---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- to get player info and prints it out
   Put("Name                          ");
   Put("ID       ");
   Put("Skill        ");
   Put("Wiins      ");
   Put("Losses");
   New_Line;
WHILE NOT IsEmpty(TwoFailures) LOOP
   Put(Top(TwoFailures).Name); -- name of player
   Put(Top(TwoFailures).Arriv_Num); -- arrival number
   Put(Top(TwoFailures).Skill); -- skill level of player
   Put(Top(TwoFailures).Wins); -- number of wins
   Put(Top(TwoFailures).Fails); -- number of times player lost
   NEW_LINE;
   Pop(TwoFailures);
END LOOP;

 exception                              -- for testiing
      when Data_Error =>
         Put_Line("Your an idiot Maddy...");


---------------------------------------------------------------------------
---------------------------------------------------------------------------
end Contest;


