--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body Game is
   procedure Initialize (GS : out Game.State) is
   begin
      GS.Backbuffer.W      := 600;
      GS.Backbuffer.H      := 400;
      GS.Backbuffer.Pixels := new Pixel_Buffer (0 .. (GS.Backbuffer.W * GS.Backbuffer.H) - 1);

      GS.P1.X := Padding + Ball_Half_Dim;
      GS.P1.Y := GS.Backbuffer.H / 2 - Paddle_H / 2;

      GS.P2.X := GS.Backbuffer.W - Paddle_W - Padding;
      GS.P2.Y := GS.Backbuffer.H / 2 - Paddle_H / 2;
   end Initialize;

   procedure Process_Button (Button : out Button_State; Pressed : Boolean) is
   begin
      Button.Pressed      := Pressed;
      Button.Transitioned := True;
   end Process_Button;

   procedure Update (GS : in out Game.State; Frame_Duration : Time_Span) is
      procedure Clear (Color : Pixel_Value) is
      begin
         for Pixel of GS.Backbuffer.Pixels.all loop
            Pixel := Color;
         end loop;
      end Clear;

      procedure Draw_Rectangle (X, Y, W, H : Integer; Color : Pixel_Value) is
         X_Min : Integer := Integer'Max (X, 0);
         Y_Min : Integer := Integer'Max (Y, 0);
         X_Max : Integer := Integer'Min (X + W, GS.Backbuffer.W) - 1;
         Y_Max : Integer := Integer'Min (Y + H, GS.Backbuffer.H) - 1;
      begin
         for Y in Y_Min .. Y_Max loop
            for X in X_Min .. X_Max loop
               GS.Backbuffer.Pixels.all ((Y * GS.Backbuffer.W) + X) := Color;
            end loop;
         end loop;
      end Draw_Rectangle;

      Distance : Integer := 5;
   begin
      Clear (16#0000_FFFF#);

      if GS.Buttons (Player1_Up).Pressed then
         GS.P1.Y := GS.P1.Y - Distance;
      elsif Gs.Buttons (Player1_Down).Pressed then
         GS.P1.Y := GS.P1.Y + Distance;
      end if;

      if GS.Buttons (Player2_Up).Pressed then
         GS.P2.Y := GS.P2.Y - Distance;
      elsif Gs.Buttons (Player2_Down).Pressed then
         GS.P2.Y := GS.P2.Y + Distance;
      end if;

      Draw_Rectangle (X => GS.P1.X, Y => GS.P1.Y,
                      W => Paddle_W, H => Paddle_H, Color => 16#FFFF_FFFF#);

      Draw_Rectangle (X => GS.P2.X, Y => GS.P2.Y,
                      W => Paddle_W, H => Paddle_H, Color => 16#FFFF_FFFF#);

      Draw_Rectangle
        (X     => GS.Backbuffer.W / 2 - Ball_Half_Dim,
         Y     => GS.Backbuffer.H / 2 - Ball_Half_Dim,
         W     => Ball_Dim,
         H     => Ball_Dim,
         Color => 16#FFFF_FFFF#);

   end Update;
end Game;
