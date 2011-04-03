#ifndef _H_GL_CONTEXT_
#define _H_GL_CONTEXT_

#include "Window.h"
#include "GL/gl.h"
class GlContextControl:public Window
{
public:
	GlContextControl();
	virtual ~GlContextControl();
	virtual bool Create(TCHAR title[], int x, int y, int w, int h,HWND parent);
	virtual bool Create(TCHAR title[], int x, int y, int w, int h,HWND parent,  PIXELFORMATDESCRIPTOR pfd);
	void SetActive();
	void EndDraw();

protected:
	virtual void _OnDestroy();

private:
	HGLRC m_hRC;
	HWND m_parent;
	PIXELFORMATDESCRIPTOR m_pfd;
};
#endif

