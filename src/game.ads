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

   type Button_Type is
     (Player1_Up, Player1_Down, Player1_Left, Player1_Right,
      Player2_Up, Player2_Down, Player2_Left, Player2_Right);

   type Button_State is record
      Pressed, Transitioned : Boolean := False;
   end record;

   type Button_States is array (Button_Type) of Button_State;

   type Position is record
      X, Y : Integer := 0;
   end record;

   type State is record
      Backbuffer : Texture;
      Buttons    : Button_States;

      P1, P2, Ball : Position;
   end record;

   Paddle_Half_W : Integer := 8;
   Paddle_Half_H : Integer := 50;

   Paddle_W : Integer := Paddle_Half_W * 2;
   Paddle_H : Integer := Paddle_Half_H * 2;

   Padding       : Integer := 10;
   Ball_Half_Dim : Integer := 10;
   Ball_Dim      : Integer := Ball_Half_Dim * 2;

   procedure Initialize (GS : out Game.State);
   procedure Process_Button (Button : out Button_State; Pressed : Boolean);
   procedure Update (GS : in out Game.State; Frame_Duration : Time_Span);
end Game;
