%module chipmunk

%{
#include "chipmunk/chipmunk.h"
%}


#define CP_PRIVATE(__symbol__)

#include "deps/common/chipmunk-6.2.1/include/chipmunk/chipmunk_types.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpVect.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpBB.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpSpatialIndex.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpBody.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpShape.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpPolyShape.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpArbiter.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpSpace.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/constraints/cpConstraint.h"

void cpInitChipmunk(void);
void cpEnableSegmentToSegmentCollisions(void);
cpFloat cpMomentForCircle(cpFloat m, cpFloat r1, cpFloat r2, cpVect offset);
cpFloat cpAreaForCircle(cpFloat r1, cpFloat r2);
cpFloat cpMomentForSegment(cpFloat m, cpVect a, cpVect b);
cpFloat cpAreaForSegment(cpVect a, cpVect b, cpFloat r);
cpFloat cpMomentForPoly(cpFloat m, int numVerts, const cpVect *verts, cpVect offset);
cpFloat cpAreaForPoly(const int numVerts, const cpVect *verts);
cpVect cpCentroidForPoly(const int numVerts, const cpVect *verts);
void cpRecenterPoly(const int numVerts, cpVect *verts);
cpFloat cpMomentForBox(cpFloat m, cpFloat width, cpFloat height);
cpFloat cpMomentForBox2(cpFloat m, cpBB box);
int cpConvexHull(int count, cpVect *verts, cpVect *result, int *first, cpFloat tol);
