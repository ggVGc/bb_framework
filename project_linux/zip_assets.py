import os

curDir = os.getcwd()
os.chdir("../jumpz/")
os.system("zip -ur  ../project_linux/assets.zip assets")
os.chdir("../framework/src/lua")
os.system("zip -ur ../../../project_linux/assets.zip assets")
os.chdir(curDir)
