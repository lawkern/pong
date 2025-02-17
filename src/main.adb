--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Platform; use Platform;
with Game;

procedure Main is
   GS : Game.State;
begin
   Platform.Log ("Pong Start!");

   Game.Initialize (GS);
   Platform.Initialize (W => GS.Backbuffer.W, H => GS.Backbuffer.H);

   while Platform.Running loop
      Platform.Process_Input (GS.Inputs (GS.Input_Index));

      Game.Update (GS, Platform.Frame_Time_Elapsed);

      Platform.Render (GS.Backbuffer);
      Platform.Frame_End;
   end loop;

end Main;
