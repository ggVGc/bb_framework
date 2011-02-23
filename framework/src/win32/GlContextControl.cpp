#include "GlContextControl.h"

GlContextControl::GlContextControl()
{
}
GlContextControl::~GlContextControl()
{
}
bool GlContextControl::Create(TCHAR title[], int x, int y, int w, int h,HWND parent)
{
	PIXELFORMATDESCRIPTOR pfd ={	
		sizeof(PIXELFORMATDESCRIPTOR),	//size
		1,								//version
		PFD_SUPPORT_OPENGL |			//Flags	
		PFD_DRAW_TO_WINDOW |			//-''-
		PFD_DOUBLEBUFFER,				//-''-
		PFD_TYPE_RGBA,					//Color type
		32,								//Color depth(prefered)
		0, 0, 0, 0, 0, 0,				//Color bits
		0,								//Alpha buffer
		0,								//Alpha bits
		0,								//Accumulation buffer
		0, 0, 0, 0,						//Accumulation bits
		16,								//Depth buffer
		0,								//Stencil buffer
		0,								//Auxiliary buffers
		PFD_MAIN_PLANE,					//Layer type
		0,								//Reserved
		0,								//Layer mask
		0,								//Visibible mask
		0,								//Damage mask
	};
	return Create(title, x, y, w, h, parent, pfd);
}
bool GlContextControl::Create(TCHAR title[], int x, int y, int w, int h,HWND parent, PIXELFORMATDESCRIPTOR pfd)
{
	m_pfd=pfd;
	m_parent = parent;
	if(InternalCreate(title,x,y,w,h,CS_HREDRAW | CS_VREDRAW | CS_OWNDC, WS_VISIBLE|WS_CHILD, 0,parent))
	{
		SetPixelFormat(GetDC(m_hWnd),ChoosePixelFormat(GetDC(m_hWnd),&m_pfd), &m_pfd);
		m_hRC = wglCreateContext(GetDC(m_hWnd));
		return true;
	}
	else
		return false;
}
void GlContextControl::SetActive()
{
	wglMakeCurrent(GetDC(GetHandle()),m_hRC);
}
void GlContextControl::EndDraw()
{
	SwapBuffers(GetDC(GetHandle()));
}

void GlContextControl::_OnDestroy()
{
	wglDeleteContext(m_hRC);
}