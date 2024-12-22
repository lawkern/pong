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

   procedure Set_Render_Draw_Color (Renderer : SDL3.Renderer; R, G, B, A : Uint8) is
      function SDL_Set_Render_Draw_Color (Renderer : SDL3.Renderer; R, G, B, A : Uint8) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_SetRenderDrawColor";
   begin
      if SDL_Set_Render_Draw_Color (Renderer, R, G, B, A) /= C.False then
         null; -- TODO: Do we care if this fails?
      end if;
   end Set_Render_Draw_Color;

   procedure Render_Clear (Renderer : SDL3.Renderer) is
      function SDL_Render_Clear (Renderer : SDL3.Renderer) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_RenderClear";
   begin
      if SDL_Render_Clear (Renderer) /= C.True then
         null; -- TODO: Do we care if this fails?
      end if;
   end Render_Clear;

   procedure Render_Present (Renderer : SDL3.Renderer) is
      function SDL_Render_Present (Renderer : SDL3.Renderer) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_RenderPresent";
   begin
      if SDL_Render_Present (Renderer) /= C.True then
         null; -- TODO: Do we care if this fails?
      end if;
   end Render_Present;

   function Create_Texture
     (Renderer : SDL3.Renderer;
      W, H     : Integer) return Texture is

      function SDL_Create_Texture
        (Renderer       : SDL3.Renderer;
         Format         : Pixel_Format;
         Access_Pattern : Texture_Access;
         W, H           : C.int) return Texture
         with Import => True, Convention => C, External_Name => "SDL_CreateTexture";

      Result : Texture;
   begin
      Result := SDL_Create_Texture (Renderer, Pixel_Format_RGBA8888, Target, C.int (W), C.int (H));
      if Result = Texture (System.Null_Address) then
         raise Initialization_Error;
      end if;

      return Result;
   end Create_Texture;

   procedure Update_Texture
     (Texture : SDL3.Texture;
      Pixels  : Game.Pixel_Access;
      Pitch   : Integer) is

      function SDL_Update_Texture
        (Texture : SDL3.Texture;
         Rect    : System.Address;
         Pixels  : System.Address;
         Pitch   : C.int) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_UpdateTexture";
   begin
      if SDL_Update_Texture
          (Texture, System.Null_Address, Pixels.all'Address, C.int (Pitch)) /= C.True then
         null; -- TODO: Do we care if this fails?
      end if;
   end Update_Texture;

   procedure Render_Texture
     (Renderer           :        SDL3.Renderer;
      Texture            :        SDL3.Texture;
      Src_Rect, Dst_Rect : in out FRect) is

      function SDL_Render_Texture
        (Renderer           : SDL3.Renderer;
         Texture            : SDL3.Texture;
         Src_Rect, Dst_Rect : System.Address) return C.C_bool
        with Import => True, Convention => C, External_Name => "SDL_RenderTexture";
   begin
      if SDL_Render_Texture (Renderer, Texture, Src_Rect'Address, Dst_Rect'Address) /= C.True then
         null; -- TODO: Do we care if this fails?
      end if;
   end Render_Texture;

end SDL3;
