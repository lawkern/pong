--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Platform; use Platform;
with Game;

procedure Main is
begin
   Platform.Initialize;

   while Platform.Running loop
      Platform.Process_Input;

      Game.Update (Platform.Frame_Duration);

      Platform.Render;
      Platform.Frame_End;
   end loop;

end Main;
