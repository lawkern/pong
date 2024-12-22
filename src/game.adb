--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body Game is
   procedure Initialize (GS : out Game.State) is
   begin
      GS.Backbuffer.W      := 600;
      GS.Backbuffer.H      := 400;
      GS.Backbuffer.Pixels := new Pixel_Buffer (0 .. (GS.Backbuffer.W * GS.Backbuffer.H) - 1);

      GS.P1.Position := (Float(Padding + Paddle_Half_W), Float(GS.Backbuffer.H / 2));
      GS.P2.Position := (Float (GS.Backbuffer.W - Paddle_W - Padding), Float (GS.Backbuffer.H / 2));

      GS.Ball.Position := (Float (GS.Backbuffer.W / 2 - Ball_Half_Dim), Float (GS.Backbuffer.H / 2 - Ball_Half_Dim));
      GS.Ball.Velocity := (1.0, 0.5);
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

      procedure Draw_Board is
         Divider_W : Integer := 6;
         Divider_H : Integer := 16;

         X : Integer := GS.Backbuffer.W / 2 - Divider_W / 2;
         Y : Integer := 0;
      begin
         while Y < GS.Backbuffer.H loop
            Draw_Rectangle (X => X, Y => Y, W => Divider_W, H => Divider_H, Color => 16#FFFF_FFCC#);
            Y := Y + (Divider_H * 2);
         end loop;
      end Draw_Board;

      procedure Draw_Paddle (M : Movement; Color : Pixel_Value) is
      begin
         Draw_Rectangle (X => Integer (M.Position (1)) - Paddle_Half_W,
                         Y => Integer (M.Position (2)) - Paddle_Half_H,
                         W     => Paddle_W,
                         H     => Paddle_H,
                         Color => Color);

         Draw_Rectangle (X     => Integer (M.Position (1)) - 2,
                         Y     => Integer (M.Position (2)) - 2,
                         W     => 4,
                         H     => 4,
                         Color => 16#00FF_00FF#);

      end Draw_Paddle;

      type Move_Direction is (Move_None, Move_Up, Move_Down);

      procedure Move_Paddle (M : in out Movement; Direction : Move_Direction) is
         Distance : Integer := 5;

         Paddle_Half_H : Integer := Paddle_H / 2;
      begin
         case Direction is
            when Move_Up =>
               M.Position (2) := M.Position (2) - Float (Distance);
               if Integer (M.Position (2)) < Paddle_Half_H then
                  M.Position (2) := Float (Paddle_Half_H);
               end if;

            when Move_Down =>
               M.Position (2) := M.Position (2) + Float (Distance);
               if Integer (M.Position (2)) > (GS.Backbuffer.H - Paddle_Half_H) then
                  M.Position (2) := Float (GS.Backbuffer.H - Paddle_Half_H);
               end if;

            when Move_None =>null;
         end case;
      end Move_Paddle;

      procedure Move_Ball (M : in out Movement) is
         Factor : Float := 100.0;
         Min : Vec2 := (Float (Ball_Half_Dim), Float (Ball_Half_Dim));
         Max : Vec2 := (Float (GS.Backbuffer.W - Ball_Half_Dim), Float (GS.Backbuffer.H - Ball_Half_Dim));
      begin
         -- NOTE: Bounce off walls.
         if (M.Position (1) > Max (1) and M.Velocity (1) > 0.0) or (M.Position (1) < Min (1) and M.Velocity (1) < 0.0) then
            M.Velocity (1) := M.Velocity (1) * (-1.0);
         end if;

         if (M.Position (2) > Max (2) and M.Velocity (2) > 0.0) or (M.Position (2) < Min (2) and M.Velocity (2) < 0.0) then
            M.Velocity (2) := M.Velocity (2) * (-1.0);
         end if;

         M.Position (1) := M.Position (1) + (Float (To_Duration (Frame_Duration)) * M.Velocity (1) * Factor);
         M.Position (2) := M.Position (2) + (Float (To_Duration (Frame_Duration)) * M.Velocity (2) * Factor);
      end Move_Ball;

   begin
      Clear (16#0000_FFFF#);

      Draw_Board;

      if GS.Buttons (Player1_Up).Pressed then
         Move_Paddle (GS.P1, Move_Up);
      elsif GS.Buttons (Player1_Down).Pressed then
         Move_Paddle (GS.P1, Move_Down);
      end if;

      if GS.Buttons (Player2_Up).Pressed then
         Move_Paddle (GS.P2, Move_Up);
      elsif GS.Buttons (Player2_Down).Pressed then
         Move_Paddle (GS.P2, Move_Down);
      end if;

      Move_Ball(GS.Ball);

      Draw_Paddle (GS.P1, 16#FFFF_FFFF#);
      Draw_Paddle (GS.P2, 16#FFFF_FFFF#);

      Draw_Rectangle
        (X     => Integer (GS.Ball.Position (1)) - Ball_Half_Dim,
         Y     => Integer (GS.Ball.Position (2)) - Ball_Half_Dim,
         W     => Ball_Dim,
         H     => Ball_Dim,
         Color => 16#FFFF_FFFF#);

   end Update;
end Game;
