import sys
import os
import appmap

#start the recorder
r = appmap.Recording()
with r:
    #run the SSH demo code
    import sshdemo
    sshdemo.Demo().runDemo()

#write recorded AppMap to disk
with open("tmp/sshdemo.py.appmap.json", "w+") as mapfile:
    mapfile.write(appmap.generation.dump(r))
    mapfile.flush()