--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with System;

with SDL3; use SDL3;
with Game;

package body Platform is
   Window   : SDL3.Window;
   Renderer : SDL3.Renderer;

   Frame_Count : Natural := 0;
   Start_Time, Next_Frame_Time, Prev_Frame_Time : Time;

   procedure Initialize is
   begin
      Put_Line ("Pong Start!");

      SDL3.Init (Flags => SDL3.Init_Video);

      SDL3.Create_Window_And_Renderer
        (Title    => "PONG", W => 600, H => 400,
         Flags => SDL3.Window_Resizable or SDL3.Window_High_Pixel_Density,
         Window   => Window,
         Renderer => Renderer);

      Frames_Per_Second := 60; -- TODO: Determine based on monitor hz.
      Frame_Duration := Microseconds (1_000_000) / Frames_Per_Second;

      Start_Time := Clock;
      Prev_Frame_Time := Start_Time;
      Next_Frame_Time := Start_Time + Frame_Duration;

   exception
      when E : SDL3.Initialization_Error =>
         Put_Line ("ERROR: SDL3 initialzation failed.");
   end Initialize;

   procedure Process_Input is
      Event : SDL3.Event;
   begin
      while SDL3.Poll_Event (Event) loop
         if Event.Kind = SDL3.Event_Quit then
            Running := False;
            exit;
         end if;
      end loop;
   end Process_Input;

   procedure Render is
   begin
      SDL3.Set_Render_Draw_Color (Renderer, R => 32, G => 32, B => 64, A => 255);
      SDL3.Render_Clear (Renderer);

      SDL3.Render_Present (Renderer);
   end Render;

   procedure Frame_End is
   begin
      Frame_Count := Frame_Count + 1;

      delay until Next_Frame_Time;

      if (Frame_Count mod (Frames_Per_Second / 2)) = 0 then
         declare
            Frame_Seconds : Float := Float (To_Duration (Next_Frame_Time - Prev_Frame_Time));
            Total_Seconds : Float := Float (To_Duration (Next_Frame_Time - Start_Time));
         begin
            Put_Line ("Frame:" & Frame_Seconds'Image & "sec, Total:" & Total_Seconds'Image & "sec");
         end;
      end if;

      Prev_Frame_Time := Next_Frame_Time;
      Next_Frame_Time := Next_Frame_Time + Frame_Duration;

      if Clock > Next_Frame_Time then
         Next_Frame_Time := Clock + Frame_Duration;
      end if;
   end Frame_End;

end Platform;
