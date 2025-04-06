A long time ago I made a game called Berry Bounce.

Instead of just making a game I, of course, spent the majority of the time building a small cross-platform game engine and asset pipeline.
This is that engine, along with some unfinished continued work, making Nim bindings.

General facts:
- The core rendering and audio engine was implemented in C and OpenGL
- Lua (actually moonscript, which compiles to lua) was used for the game code, and for engine functionality that did not need to be in C.
- Wrappers were made for PC, Android and iOS
- Assets (art and animations) were created in the Flash IDE, and exported to `CreateJS`, which was a stepping stone for Flash moving to HTML5. The output was javascript which ran using a `CreateJS` runtime library.
- This engine contains a lua port of most of that `CreateJS` runtime library, where every non-static table allocation has been removed, in order to be useable with GC turned off. The rendering is tightly coupled to the C code.
- The file `convert_flash_export.moon` translated the exported JS file into a lua file, which could be loaded and run (rendered and animated) in the game.
