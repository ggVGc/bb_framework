E= @echo
Q= @
cp= @cp

MOON_FILES := $(wildcard src/lua/*.moon)
LUA_FILES := $(wildcard src/lua/*.lua)
OBJ_FILES := $(addprefix obj/,$(notdir $(MOON_FILES:.moon=.lua)))
LUA_COPY := $(addprefix obj/,$(notdir $(LUA_FILES:.lua=.lua)))

framework_src: $(OBJ_FILES) $(LUA_COPY)

obj/%.lua: src/lua/%.moon
	./simple_moon_compile.lua $<

obj/%.lua: src/lua/%.lua
	cp $< $@

