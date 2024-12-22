--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Real_Time; use Ada.Real_Time;

package Game is
   procedure Update (Frame_Duration : Time_Span);
end Game;
