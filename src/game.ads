--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Ada.Real_Time; use Ada.Real_Time;
with Ada.Numerics.Real_Arrays;

with Interfaces; use Interfaces;

package Game is
   type U8 is new Unsigned_8;
   type U16 is new Unsigned_16;
   type U32 is new Unsigned_32;
   type U64 is new Unsigned_64;

   type Pixel_Buffer is array (Natural range <>) of U32;
   type Pixel_Access is access Pixel_Buffer;

   type Texture is record
      W, H   : Integer;
      Pixels : Pixel_Access;
   end record;

   type Button_Type is
     (Player1_Up, Player1_Down, Player1_Left, Player1_Right, Player1_Start,
      Player2_Up, Player2_Down, Player2_Left, Player2_Right, Player2_Start);

   type Button_State is record
      Pressed, Transitioned : Boolean := False;
   end record;

   type Button_States is array (Button_Type) of Button_State;

   type Input_Indices is mod 2;
   type Input_States is array (Input_Indices) of Button_States;

   type Vec2 is new Ada.Numerics.Real_Arrays.Real_Vector (1 .. 2);
   type Vec4 is new Ada.Numerics.Real_Arrays.Real_Vector (1 .. 4);

   White : Vec4 := (1.0, 1.0, 1.0, 1.0);
   Blue  : Vec4 := (0.0, 0.0, 1.0, 1.0);
   Green : Vec4 := (0.0, 1.0, 0.0, 1.0);

   type Movement is record
      Position : Vec2 := (0.0, 0.0);
      Velocity : Vec2 := (0.0, 0.0);
   end record;

   type Ball_Indices is mod 2**4;
   type Ball_Movements is array (Ball_Indices) of Movement;

   type State is record
      Backbuffer : Texture;
      Frame      : U32;
      Paused     : Boolean := False;

      Input_Index : Input_Indices;
      Inputs      : Input_States;


      P1, P2 : Movement;

      Ball_Index : Ball_Indices := 0;
      Ball       : Ball_Movements;
   end record;

   Paddle_Half_W : Float := 8.0;
   Paddle_Half_H : Float := 50.0;

   Paddle_W : Float := Paddle_Half_W * 2.0;
   Paddle_H : Float := Paddle_Half_H * 2.0;

   Padding       : Float := 10.0;
   Ball_Half_Dim : Float := 10.0;
   Ball_Dim      : Float := Ball_Half_Dim * 2.0;

   procedure Initialize (GS : out Game.State);
   procedure Process_Button (Button : out Button_State; Pressed : Boolean);
   procedure Update (GS : in out Game.State; Frame_Time_Elapsed : Time_Span);
end Game;
