--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Platform; use Platform;
with Game;

procedure Main is
   Backbuffer : Game.Texture;
begin
   Platform.Log ("Pong Start!");

   Game.Initialize (Backbuffer);
   Platform.Initialize (W => Backbuffer.W, H => Backbuffer.H);

   while Platform.Running loop
      Platform.Process_Input;

      Game.Update (Backbuffer, Platform.Frame_Duration);

      Platform.Render (Backbuffer);
      Platform.Frame_End;
   end loop;

end Main;
