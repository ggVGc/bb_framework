//
//  Shader.fsh
//  framework
//
//  Created by Walt on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
