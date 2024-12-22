--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Real_Time; use Ada.Real_Time;

package Platform is
   Frames_Per_Second : Natural;
   Frame_Duration : Time_Span;

   Running : Boolean := True;

   procedure Initialize;
   procedure Process_Input;
   procedure Render;
   procedure Frame_End;
end Platform;
