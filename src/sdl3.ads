--------------------------------------------------------------------------------
-- (c) copyright 2024 Lawrence D. Kern /////////////////////////////////////////
--------------------------------------------------------------------------------

with Interfaces.C; use Interfaces.C;
with System;

package SDL3 is
   package C renames Interfaces.C;

   Initialization_Error : exception;

   type Uint32 is mod 2**32 with Convention => C;
   type Uint64 is mod 2**64 with Convention => C;

   type Init_Flags is new Uint64;
   Init_Audio    : constant Init_Flags := 16#0000_0010#;
   Init_Video    : constant Init_Flags := 16#0000_0020#;
   Init_Joystick : constant Init_Flags := 16#0000_0200#;
   Init_Haptic   : constant Init_Flags := 16#0000_1000#;
   Init_Gamepad  : constant Init_Flags := 16#0000_2000#;
   Init_Events   : constant Init_Flags := 16#0000_4000#;
   Init_Sensor   : constant Init_Flags := 16#0000_8000#;
   Init_Camera   : constant Init_Flags := 16#0001_0000#;

   procedure Init (Flags : Init_Flags);

   type Window_Flags is new Uint64;
   Window_Fullscreen          : constant Window_Flags := 16#0000_0000_0000_0001#;
   Window_Opengl              : constant Window_Flags := 16#0000_0000_0000_0002#;
   Window_Occluded            : constant Window_Flags := 16#0000_0000_0000_0004#;
   Window_Hidden              : constant Window_Flags := 16#0000_0000_0000_0008#;
   Window_Borderless          : constant Window_Flags := 16#0000_0000_0000_0010#;
   Window_Resizable           : constant Window_Flags := 16#0000_0000_0000_0020#;
   Window_Minimized           : constant Window_Flags := 16#0000_0000_0000_0040#;
   Window_Maximized           : constant Window_Flags := 16#0000_0000_0000_0080#;
   Window_Mouse_Grabbed       : constant Window_Flags := 16#0000_0000_0000_0100#;
   Window_Input_Focus         : constant Window_Flags := 16#0000_0000_0000_0200#;
   Window_Mouse_Focus         : constant Window_Flags := 16#0000_0000_0000_0400#;
   Window_External            : constant Window_Flags := 16#0000_0000_0000_0800#;
   Window_Modal               : constant Window_Flags := 16#0000_0000_0000_1000#;
   Window_High_Pixel_Density  : constant Window_Flags := 16#0000_0000_0000_2000#;
   Window_Mouse_Capture       : constant Window_Flags := 16#0000_0000_0000_4000#;
   Window_Mouse_Relative_Mode : constant Window_Flags := 16#0000_0000_0000_8000#;
   Window_Always_On_Top       : constant Window_Flags := 16#0000_0000_0001_0000#;
   Window_Utility             : constant Window_Flags := 16#0000_0000_0002_0000#;
   Window_Tooltip             : constant Window_Flags := 16#0000_0000_0004_0000#;
   Window_Popup_Menu          : constant Window_Flags := 16#0000_0000_0008_0000#;
   Window_Keyboard_Grabbed    : constant Window_Flags := 16#0000_0000_0010_0000#;
   Window_Vulkan              : constant Window_Flags := 16#0000_0000_1000_0000#;
   Window_Metal               : constant Window_Flags := 16#0000_0000_2000_0000#;
   Window_Transparent         : constant Window_Flags := 16#0000_0000_4000_0000#;
   Window_Not_Focusable       : constant Window_Flags := 16#0000_0000_8000_0000#;

   type Window is new System.Address;
   type Renderer is new System.Address;

   procedure Create_Window_And_Renderer
     (Title    :     String;
      W, H     :     Integer;
      Flags    :     Window_Flags;
      Window   : out SDL3.Window;
      Renderer : out SDL3.Renderer);

   type Event_Type is new Uint32;
   Event_First    : constant Event_Type := 16#000#;
   Event_Quit     : constant Event_Type := 16#100#;
   Event_Key_Down : constant Event_Type := 16#300#;
   Event_Key_Up   : constant Event_Type := 16#301#;

   -- NOTE: Just pad out the remaining 120 bytes of the 128 byte Event union.
   type Event_Padding is array (0 .. 14) of Uint64 with Component_Size => 64;

   type Event is record
      Kind : Event_Type;
      Pad  : Event_Padding;
   end record;
   for Event'Size use 1024;
   for Event'Alignment use 8;

   function Poll_Event (Event : out SDL3.Event) return Boolean;

end SDL3;
