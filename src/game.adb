--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body Game is

   ----------------------------------------------------------------------------
   procedure Initialize (GS : out Game.State) is
   begin
      GS.Backbuffer.W      := 600;
      GS.Backbuffer.H      := 400;
      GS.Backbuffer.Pixels := new Pixel_Buffer (0 .. (GS.Backbuffer.W * GS.Backbuffer.H) - 1);

      GS.P1.Position := (Padding + Paddle_Half_W, Float (GS.Backbuffer.H) / 2.0);
      GS.P2.Position := (Float (GS.Backbuffer.W) - Paddle_W - Padding, Float (GS.Backbuffer.H) / 2.0);

      for I in Ball_Indices loop
         GS.Ball (I).Position := (Float (GS.Backbuffer.W) / 2.0 - Ball_Half_Dim, Float (GS.Backbuffer.H) / 2.0 - Ball_Half_Dim);
         GS.Ball (I).Velocity := (200.0, 150.0);
      end loop;
   end Initialize;

   ----------------------------------------------------------------------------
   procedure Process_Button (Button : out Button_State; Pressed : Boolean) is
   begin
      Button.Pressed      := Pressed;
      Button.Transitioned := True;
   end Process_Button;

   ----------------------------------------------------------------------------
   procedure Update (GS : in out Game.State; Frame_Time_Elapsed : Time_Span) is
      function To_U32 (V : Vec4) return U32 is
      begin
         return
           Shift_Left (U32 (V (1) * 255.0), 24) or
           Shift_Left (U32 (V (2) * 255.0), 16) or
           Shift_Left (U32 (V (3) * 255.0), 8) or
           Shift_Left (U32 (V (4) * 255.0), 0);
      end To_U32;

      function To_Vec2 (V : Float) return Vec2 is
      begin
         return (V, V);
      end To_Vec2;

      -------------------------------------------------------------------------
      function To_Vec4 (V : U32) return Vec4 is
         R, G, B, A : Float;
      begin
         R := Float (Shift_Right (V, 24)) / 255.0;
         G := Float (Shift_Right (V, 16)) / 255.0;
         B := Float (Shift_Right (V, 8)) / 255.0;
         A := Float (Shift_Right (V, 0)) / 255.0;

         return (R, G, B, A);
      end To_Vec4;

      -------------------------------------------------------------------------
      function Lerp (A, B, T : Float) return Float is
      begin
         return (A * (1.0 - T)) + (B * T);
      end Lerp;

      -------------------------------------------------------------------------
      procedure Clear (Color : Vec4) is
         Color32 : U32 := To_U32 (Color);
      begin
         for Pixel of GS.Backbuffer.Pixels.all loop
            Pixel := Color32;
         end loop;
      end Clear;

      -------------------------------------------------------------------------
      procedure Draw_Rectangle (X, Y, W, H : Float; Color : Vec4) is
         X_Min : Integer := Integer'Max (Integer (X), 0);
         Y_Min : Integer := Integer'Max (Integer (Y), 0);
         X_Max : Integer := Integer'Min (Integer (X + W), GS.Backbuffer.W) - 1;
         Y_Max : Integer := Integer'Min (Integer (Y + H), GS.Backbuffer.H) - 1;

         Offset        : Natural;
         Blended_Color : Vec4;

         R, G, B, A : Float;
      begin
         R := Color (1);
         G := Color (2);
         B := Color (3);
         A := Color (4);

         for Y in Y_Min .. Y_Max loop
            for X in X_Min .. X_Max loop
               Offset := Y * GS.Backbuffer.W + X;

               Blended_Color := To_Vec4 (GS.Backbuffer.Pixels.all (Offset));

               Blended_Color (1) := Lerp (Blended_Color (1), R, A);
               Blended_Color (2) := Lerp (Blended_Color (2), G, A);
               Blended_Color (3) := Lerp (Blended_Color (3), B, A);
               Blended_Color (4) := 1.0;

               GS.Backbuffer.Pixels.all (Offset) := To_U32 (Blended_Color);
            end loop;
         end loop;
      end Draw_Rectangle;

      -------------------------------------------------------------------------
      type Move_Direction is (Move_None, Move_Up, Move_Down);

      procedure Move_Paddle (M : in out Movement; Direction : Move_Direction) is
         Distance : Float := 5.0;
      begin
         case Direction is
            when Move_Up =>
               M.Position (2) := M.Position (2) - Distance;
               if M.Position (2) < Paddle_Half_H then
                  M.Position (2) := Paddle_Half_H;
               end if;

            when Move_Down =>
               M.Position (2) := M.Position (2) + Distance;
               if M.Position (2) > Float (GS.Backbuffer.H) - Paddle_Half_H then
                  M.Position (2) := Float (GS.Backbuffer.H) - Paddle_Half_H;
               end if;

            when Move_None =>
               null;
         end case;
      end Move_Paddle;

      -------------------------------------------------------------------------
      function Made_Contact (Ball, Paddle : Movement) return Boolean is
         X_Min, X_Max, Y_Min, Y_Max : Float;
      begin
         X_Min := Paddle.Position (1) - Paddle_Half_W - Ball_Half_Dim;
         X_Max := Paddle.Position (1) + Paddle_Half_W + Ball_Half_Dim;
         Y_Min := Paddle.Position (2) - Paddle_Half_H - Ball_Half_Dim;
         Y_Max := Paddle.Position (2) + Paddle_Half_H + Ball_Half_Dim;

         return Ball.Position (1) >= X_Min and Ball.Position (1) <= X_Max and
             Ball.Position (2) >= Y_Min and Ball.Position (2) <= Y_Max;
      end Made_Contact;

      -------------------------------------------------------------------------
      procedure Move_Ball (Ball : in out Movement; P1, P2 : Movement) is
         Half_Dim : Vec2 := (Ball_Half_Dim, Ball_Half_Dim);

         Min : Vec2 := Half_Dim;
         Max : Vec2 := (Float (GS.Backbuffer.W), Float (GS.Backbuffer.H)) - Half_Dim;

         Hit1, Hit2 : Boolean := False;

         DT : Float := Float (To_Duration (Frame_Time_Elapsed));
      begin
         Hit1 := Made_Contact (Ball => Ball, Paddle => P1);
         Hit2 := Made_Contact (Ball => Ball, Paddle => P2);

         -- NOTE: Speed up the ball on each hit.
         if Hit1 or Hit2 then
            Ball.Velocity := Ball.Velocity * 1.05;
         end if;

         -- NOTE: Ball collided while moving to the left.
         if Ball.Velocity (1) < 0.0 and (Hit1 or Ball.Position (1) < Min (1)) then
            Ball.Velocity (1) := Ball.Velocity (1) * (-1.0);
         end if;

         -- NOTE: Ball collided while moving to the right.
         if Ball.Velocity (1) > 0.0 and (Hit2 or Ball.Position (1) > Max (1)) then
            Ball.Velocity (1) := Ball.Velocity (1) * (-1.0);
         end if;

         -- NOTE: Ball collided with top or bottom border.
         if
           (Ball.Position (2) > Max (2) and Ball.Velocity (2) > 0.0) or
           (Ball.Position (2) < Min (2) and Ball.Velocity (2) < 0.0) then

            Ball.Velocity (2) := Ball.Velocity (2) * (-1.0);
         end if;

         Ball.Position := Ball.Position + (Ball.Velocity * DT);
      end Move_Ball;

      -------------------------------------------------------------------------
      procedure Draw_Board is
         Divider_W : Float := 6.0;
         Divider_H : Float := 16.0;

         X : Float := Float (GS.Backbuffer.W) / 2.0 - Divider_W / 2.0;
         Y : Float := 0.0;
      begin
         while Y < Float (GS.Backbuffer.H) loop
            Draw_Rectangle (X => X, Y => Y, W => Divider_W, H => Divider_H, Color => White);
            Y := Y + (Divider_H * 2.0);
         end loop;
      end Draw_Board;

      -------------------------------------------------------------------------
      procedure Draw_Paddle (M : Movement; Color : Vec4) is
      begin
         Draw_Rectangle (X     => M.Position (1) - Paddle_Half_W,
                         Y     => M.Position (2) - Paddle_Half_H,
                         W     => Paddle_W,
                         H     => Paddle_H,
                         Color => Color);

         Draw_Rectangle (X     => M.Position (1) - 2.0,
                         Y     => M.Position (2) - 2.0,
                         W     => 4.0,
                         H     => 4.0,
                         Color => Blue);
      end Draw_Paddle;

      -------------------------------------------------------------------------
      procedure Draw_Ball (GS : Game.State) is
         Step  : Integer := 4;
         Count : Integer := Ball_Indices'Modulus / Step;

         A     : Float := 0.0;
         A_Inc : Float := Float (Step) / Float (Ball_Indices'Modulus);
      begin
         for I in reverse 0 .. Count - 1 loop
            declare
               Offset : Integer  := (I * Step);
               M : Movement := GS.Ball (GS.Ball_Index - Ball_Indices (Offset));
            begin
               A := A + A_Inc;

               Draw_Rectangle
                 (X     => Float (M.Position (1)) - Ball_Half_Dim,
                  Y     => Float (M.Position (2)) - Ball_Half_Dim,
                  W     => Ball_Dim,
                  H     => Ball_Dim,
                  Color => (1.0, 1.0, 1.0, A));
            end;
         end loop;
      end Draw_Ball;


   begin ----------------------------------------------------------------------
      Clear ((0.0, 0.0, 1.0, 1.0));

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

      GS.Ball_Index           := GS.Ball_Index + 1;
      GS.Ball (GS.Ball_Index) := GS.Ball (GS.Ball_Index - 1);

      GS.Frame := GS.Frame + 1;
      Move_Ball (GS.Ball (GS.Ball_Index), GS.P1, GS.P2);

      Draw_Ball (GS);
      Draw_Paddle (GS.P1, White);
      Draw_Paddle (GS.P2, White);

   end Update;
end Game;
