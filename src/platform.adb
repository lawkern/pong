--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Text_IO;
with System;
with Interfaces.C; use Interfaces.C;

with SDL3; use SDL3;
with Game;

package body Platform is
   Window   : SDL3.Window;
   Renderer : SDL3.Renderer;
   Texture  : SDL3.Texture;

   Frame_Count : Natural := 0;

   Start_Time, Next_Frame_Time, Prev_Frame_Time : Time;

   procedure Log (Message : String) is
   begin
      Ada.Text_IO.Put_Line (Message);
   end Log;

   procedure Initialize (W, H : Integer) is
      Window_Width  : Integer           := W;
      Window_Height : Integer           := H;
      Window_Flags  : SDL3.Window_Flags := 0;

      Use_High_DPI : Boolean := False;
   begin
      SDL3.Init (Flags => SDL3.Init_Video);

      if Use_High_DPI then
         Window_Width  := Window_Width / 2;
         Window_Height := Window_Height / 2;
         Window_Flags  := Window_Flags or SDL3.Window_High_Pixel_Density;
      end if;

      SDL3.Create_Window_And_Renderer
        (Title => "PONG", W => Window_Width, H => Window_Height, Flags => Window_Flags,
         Window => Window, Renderer => Renderer);

      SDL3.Set_Render_V_Sync (Renderer, 1);

      Texture := SDL3.Create_Texture (Renderer, W, H);

      Frames_Per_Second := 60; -- TODO: Determine based on monitor hz.
      Frame_Time_Elapsed := Microseconds (1_000_000) / Frames_Per_Second;

      Start_Time      := Clock;
      Prev_Frame_Time := Start_Time;
      Next_Frame_Time := Start_Time + Frame_Time_Elapsed;

      Running := True;
   exception
      when E : SDL3.Initialization_Error =>
         Log ("ERROR: SDL3 initialzation failed.");
   end Initialize;

   procedure Process_Input (Buttons : out Game.Button_States) is
      Event : SDL3.Event;
   begin
      while SDL3.Poll_Event (Event) loop
         case Event.Basic.Kind is
            when SDL3.Event_Quit =>
               Running := False;
               exit;

            when SDL3.Event_Key_Up | SDL3.Event_Key_Down =>
               declare
                  Pressed : Boolean := Boolean (Event.Key.Down);
               begin
                  case Event.Key.Key is
                     when Keycode_Escape =>
                        Running := False;
                        exit;

                     when Keycode_W =>Game.Process_Button (Buttons (Game.Player1_Up), Pressed);
                     when Keycode_A =>Game.Process_Button (Buttons (Game.Player1_Left), Pressed);
                     when Keycode_S =>Game.Process_Button (Buttons (Game.Player1_Down), Pressed);
                     when Keycode_D =>Game.Process_Button (Buttons (Game.Player1_Right), Pressed);

                     when Keycode_I =>Game.Process_Button (Buttons (Game.Player2_Up), Pressed);
                     when Keycode_J =>Game.Process_Button (Buttons (Game.Player2_Left), Pressed);
                     when Keycode_K =>Game.Process_Button (Buttons (Game.Player2_Down), Pressed);
                     when Keycode_L =>Game.Process_Button (Buttons (Game.Player2_Right), Pressed);

                     when others =>null;
                  end case;
               end;
            when others =>null;
         end case;
      end loop;
   end Process_Input;

   procedure Render (Backbuffer : Game.Texture) is
      Pitch : Integer := Backbuffer.W * Backbuffer.Pixels'Component_Size / 8;
      Src_Rect : SDL3.FRect :=
        (X => 0.0, Y => 0.0, W => Float (Backbuffer.W), H => Float (Backbuffer.H));
      Dst_Rect : SDL3.FRect := Src_Rect;
   begin
      SDL3.Set_Render_Draw_Color (Renderer, R => 32, G => 32, B => 64, A => 255);
      SDL3.Render_Clear (Renderer);

      SDL3.Update_Texture (Texture, Backbuffer.Pixels, Pitch);
      SDL3.Render_Texture (Renderer, Texture, Src_Rect => Src_Rect, Dst_Rect => Dst_Rect);

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
            Log ("Frame:" & Frame_Seconds'Image & "sec, Total:" & Total_Seconds'Image & "sec");
         end;
      end if;

      Prev_Frame_Time := Next_Frame_Time;
      Next_Frame_Time := Next_Frame_Time + Frame_Time_Elapsed;

      if Clock > Next_Frame_Time then
         Next_Frame_Time := Clock + Frame_Time_Elapsed;
      end if;
   end Frame_End;

end Platform;
