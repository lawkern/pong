--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body Game is
   procedure Initialize (Backbuffer : out Texture) is
   begin
      Backbuffer.W := 600;
      Backbuffer.H := 400;
      Backbuffer.Pixels := new Pixel_Buffer (1 .. Backbuffer.W * Backbuffer.H);
   end Initialize;

   procedure Update (Backbuffer : in out Texture; Frame_Duration : Time_Span) is
   begin
      for Pixel of Backbuffer.Pixels.all loop
         Pixel := 16#0000_FFFF#;
      end loop;
   end Update;
end Game;
