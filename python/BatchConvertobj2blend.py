#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#by frainfreeze

#---Description---
#batch converts .obj files to .blend
#run using: blender.exe --background --python main.py

#---aditional notes---
#create two folders
#./obj and ./blend
#open terminal
#write -> cd /path/to/work/folder
#then -> path/to/blend_exe --background --python obj2blend.py
#oh and make sure that you put the obj files in the obj folder


#---code---
#!/usr/bin/python3
import os
import bpy
for paths, dirs, files in os.walk("./obj/"):
        for file in files:
                # new blend
                bpy.ops.wm.read_homefile()
 
                # import obj
                path = os.path.join(paths, file)
                print("importing:", path)
                bpy.ops.import_scene.obj(filepath=path, global_clamp_size=10*3, axis_up = "Z", axis_forward="Y")
 
                # save blend
                blend_name = file.replace(".obj", ".blend") if str(file).endswith(".obj") else "%s.blend" % file
                bpy.ops.wm.save_mainfile(filepath=os.path.join("./blend", blend_name), )
