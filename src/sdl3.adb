--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

package body SDL3 is

   procedure Init (Flags : Init_Flags) is
      function SDL_Init (Flags : Init_Flags) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_Init";
   begin
      if SDL_Init (Flags) /= C.True then
         raise Initialization_Error;
      end if;
   end Init;

   procedure Create_Window_And_Renderer
     (Title    :     String;
      W, H     :     Integer;
      Flags    :     Window_Flags;
      Window   : out SDL3.Window;
      Renderer : out SDL3.Renderer)
   is
      function SDL_Create_Window_And_Renderer
        (Title        : C.char_array;
         W, H         : C.int;
         Flags        : Window_Flags;
         Window_Ptr   : System.Address;
         Renderer_Ptr : System.Address) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_CreateWindowAndRenderer";
   begin
      if SDL_Create_Window_And_Renderer
          (Title        => To_C (Title),
           W            => C.int (W),
           H            => C.int (H),
           Flags        => Flags,
           Window_Ptr   => Window'Address,
           Renderer_Ptr => Renderer'Address) /= C.True then
         raise Initialization_Error;
      end if;
   end Create_Window_And_Renderer;

   function Poll_Event (Event : out SDL3.Event) return Boolean is
      function SDL_Poll_Event (Event_Ptr : System.Address) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_PollEvent";
   begin
      return SDL_Poll_Event (Event'Address) = C.True;
   end Poll_Event;

end SDL3;
