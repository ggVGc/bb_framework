# !sh
swig -lua  -includeall  -ignoremissing -o src/common/framework_wrap.c ./src/framework.i 
swig -lua  -includeall  -ignoremissing -o src/common/chipmunk_wrap.c ./src/chipmunk_wrap.i 
