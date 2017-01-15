------------------- GENERALLY USEFUL STUFF --------------------

_CWD = ScriptPath():sub(1, -ScriptPath():reverse():find("/")-1) -- has no trailing backslash
_ScriptFileName = ScriptPath():sub(ScriptPath():reverse():find("/")+1, -1)
