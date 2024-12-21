--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with System;

with SDL3; use SDL3;

procedure Pong is
   Window   : SDL3.Window;
   Renderer : SDL3.Renderer;

   Running : Boolean := True;

   type Frame_Counter is mod 2**64;
   Frame_Count : Frame_Counter := 0;
begin
   Put_Line ("Pong Start!");

   SDL3.Init (Flags => SDL3.Init_Video);

   SDL3.Create_Window_And_Renderer
     (Title    => "PONG", W => 600, H => 400,
      Flags    => SDL3.Window_Resizable or SDL3.Window_High_Pixel_Density,
      Window   => Window,
      Renderer => Renderer);

   while Running loop
      declare
         Event : SDL3.Event;
      begin
         while SDL3.Poll_Event (Event) loop
            if Event.Kind = SDL3.Event_Quit then
               Running := False;
               exit;
            end if;
         end loop;
      end;

      SDL3.Set_Render_Draw_Color (Renderer, R => 32, G => 32, B => 64, A => 255);
      SDL3.Render_Clear (Renderer);
      SDL3.Render_Present (Renderer);

      delay 0.016_67;

      Frame_Count := Frame_Count + 1;
      if (Frame_Count mod 60) = 0 then
         Put_Line ("Frames:" & Frame_Count'Image);
      end if;
   end loop;

exception
   when E : SDL3.Initialization_Error =>
      Put_Line ("ERROR: SDL3 initialzation failed.");

end Pong;
