#The code needs python3 and install pyffi.
#converting niff to egg
#(used for getting The Elder Scrolls models into panda3d)

from pyffi.formats.nif import NifFormat
import os
import sys


#Get file name
filename = sys.argv[1]


#Create output file
file_object = open(filename+".egg", "w")
try:
   stream = open(filename+".nif", 'rb')
   data = NifFormat.Data()
   print(stream.name) # stream.name is file name
   data.read(stream)
   print(hex(data.version)) # It talk our which game the mod belong in.
   print(data.user_version)
   num = 0
   for root in data.roots:
      print(root.get_global_display())
      for block in root.tree():
         # print the block class
         print("++++++++++++++++++++++++++++++++++++++++++\nblock.class:",block.__class__)
         if 'vertices' in dir(block):
            print("<VertexPool> main"+str(num)," { \n", file=file_object)
            vnum = 0
            # write vertex and normal
            for v,n in zip(block.vertices, block.normals):
               print("<Vertex>",vnum,"{", v.x, " ", v.y, " ", v.z, file=file_object)
               print("<Normal> {", n.x, " ", n.y, " ", n.z, "} \n }", file=file_object)
               vnum += 1
            file_object.write("}")
            # write triangles
            for tri in block.triangles:
               print("<Polygon>  {", file=file_object)
               print("<VertexRef> {", tri.v_1, " ", tri.v_2, " ", tri.v_3, file=file_object)
               print("<Ref> { main"+str(num)," } \n  }", file=file_object)
               file_object.write("}")
            # I want know total number of vertices
            print("Length:", len(block.vertices))
            num += 1
         if 'name' in dir(block):
            print("block.name:",block.name)
         # I try read skeleton, bone and weight.
         if isinstance(block, NifFormat.NiSkinInstance):
            print("skeleton root name:", block.skeleton_root.name)
            print("num bones:", block.num_bones)
            for bone in block.bones:
               print("bones:", bone.name)
            for body in block.partitions:
               print("body part:", body)
         elif isinstance(block, NifFormat.NiSkinData):
            print("num bones:", block.num_bones)
      
            print(block.has_vertex_weights)
finally:
   file_object.close()
print("block_types:")
for blocktype in data.header.block_types:
   print(blocktype.decode("ascii"))

# Run pview automatically
os.system("pview "+filename+".egg")