--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body Game is
   procedure Initialize (Backbuffer : out Texture) is
   begin
      Backbuffer.W := 600;
      Backbuffer.H := 400;
      Backbuffer.Pixels := new Pixel_Buffer (0 .. (Backbuffer.W * Backbuffer.H)- 1);
   end Initialize;

   procedure Update (Backbuffer : in out Texture; Frame_Duration : Time_Span) is
      procedure Clear (Color : Pixel_Value) is
      begin
         for Pixel of Backbuffer.Pixels.all loop
            Pixel := Color;
         end loop;
      end Clear;

      procedure Draw_Rectangle (X, Y, W, H : Integer; Color : Pixel_Value) is
         X_Min : Integer := Integer'Max (X, 0);
         Y_Min : Integer := Integer'Max (Y, 0);
         X_Max : Integer := Integer'Min (X + W, Backbuffer.W) - 1;
         Y_Max : Integer := Integer'Min (Y + H, Backbuffer.H) - 1;
      begin
         for Y in Y_Min .. Y_Max loop
            for X in X_Min .. X_Max loop
               Backbuffer.Pixels.all ((Y * Backbuffer.W) + X) := Color;
            end loop;
         end loop;
      end Draw_Rectangle;

      Board_H : Integer := 100;
      Board_W : Integer := 20;
      Padding : Integer := 10;

      Ball_Half_Dim : Integer := 10;
      Ball_Dim : Integer := Ball_Half_Dim * 2;

   begin
      Clear (16#0000_FFFF#);

      Draw_Rectangle
        (X     => Padding,
         Y     => Backbuffer.H / 2 - Board_H / 2,
         W     => Board_W,
         H     => Board_H,
         Color => 16#FFFF_FFFF#);

      Draw_Rectangle
        (X     => Backbuffer.W - Board_W - Padding,
         Y     => Backbuffer.H / 2 - Board_H / 2,
         W     => Board_W,
         H     => Board_H,
         Color => 16#FFFF_FFFF#);

      Draw_Rectangle
        (X     => Backbuffer.W / 2 - Ball_Half_Dim,
         Y     => Backbuffer.H / 2 - Ball_Half_Dim,
         W     => Ball_Dim,
         H     => Ball_Dim,
         Color => 16#FFFF_FFFF#);

   end Update;
end Game;
