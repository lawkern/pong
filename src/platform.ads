--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Real_Time; use Ada.Real_Time;
with Game;

package Platform is
   Frames_Per_Second : Natural;
   Frame_Duration    : Time_Span;

   Running : Boolean := False;

   procedure Log (Message : String);
   procedure Initialize (W, H : Integer);
   procedure Process_Input (Buttons : out Game.Button_States);
   procedure Render (Backbuffer : Game.Texture);
   procedure Frame_End;
end Platform;
