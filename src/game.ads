--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Real_Time; use Ada.Real_Time;

package Game is
   type Pixel_Value is mod 2**32;
   type Pixel_Buffer is array (Natural range <>) of Pixel_Value;
   type Pixel_Access is access Pixel_Buffer;

   type Texture is record
      W, H   : Integer;
      Pixels : Pixel_Access;
   end record;

   procedure Initialize (Backbuffer : out Texture);
   procedure Update (Backbuffer : in out Texture; Frame_Duration : Time_Span);
end Game;
