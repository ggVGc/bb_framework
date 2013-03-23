#include "Window.h"

std::map<HWND, Window*> Window::m_ptrMap;

Window::Window():m_hWnd(NULL), m_hInstance(GetModuleHandle(NULL)), m_height(0), m_width(0), m_clientHeight(0),m_clientWidth(0), m_title(0)
{
	m_pos.x=0; m_pos.y=0;
}
Window::~Window()
{
	if(Exists())
		Destroy();
}
bool Window::Create(TCHAR title[], int xPos, int yPos, int width, int height)
{
	return InternalCreate(title,xPos,yPos, width, height,
				  WND_DEF_CLASS_STYLE, WND_DEF_STYLE, WND_DEF_EXTENDED_STYLE);
}
bool Window::Create(TCHAR title[], int xPos, int yPos, int width, int height, WNDCLASSEX wcex)
{
	return InternalCreate(title,xPos,yPos, width, height,
				  wcex, WND_DEF_STYLE, WND_DEF_EXTENDED_STYLE);
}
bool Window::Create(TCHAR title[], int xPos, int yPos, int width, int height,
				  DWORD wndClassStyles, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent, HMENU child, LPVOID creationData )
{
	return InternalCreate(title, xPos, yPos, width, height,
				  wndClassStyles, wndStyles,extendedWndStyles,
				  parent, child, creationData );
}
bool Window::Create(TCHAR title[], int xPos, int yPos, int width, int height,
				  WNDCLASSEX wcex, DWORD wndStyles, DWORD extendedWndStyles,
				  HWND parent, HMENU child, LPVOID creationData )
{
	return InternalCreate(title, xPos, yPos, width, height,
				  wcex, wndStyles,extendedWndStyles,
				  parent, child, creationData );
}

bool Window::InternalCreate(TCHAR title[], int xPos, int yPos, int width, int height,
				  DWORD wndClassStyles, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent, HMENU child, LPVOID creationData )
{
	if(Exists())
		return false;
	m_windowClass.cbSize =				sizeof(WNDCLASSEX);
	m_windowClass.style =				wndClassStyles;
	m_windowClass.cbClsExtra =			0;
	m_windowClass.cbWndExtra =			0;
	m_windowClass.lpfnWndProc =			WndProcWrapper;
	m_windowClass.hInstance =			m_hInstance;
	m_windowClass.hbrBackground =		WINDOW_BCKGROUND_BRUSH;
	m_windowClass.hIcon =				LoadIcon(NULL, WINDOW_ICON_ID);
	m_windowClass.hIconSm =				LoadIcon(NULL, WINDOW_SMALLICON_ID);
	m_windowClass.hCursor =				LoadCursor(NULL, WINDOW_CURSOR_ID);
	m_windowClass.lpszMenuName =		MAKEINTRESOURCE(WINDOW_MENU_ID);
	m_windowClass.lpszClassName =		title;
	return InternalCreate(title,xPos,yPos,width,height,m_windowClass,wndStyles,extendedWndStyles,parent,child,creationData);

}
bool Window::InternalCreate(TCHAR title[], int xPos, int yPos, int width, int height,
				  WNDCLASSEX wcex, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent, HMENU child, LPVOID creationData)
{
	if(Exists())
		return false;
	m_title = title;
	if(RegisterClassEx(&wcex)==0)
		return false;

	WndPtr(this);
	AssignMessageHandler(WM_CLOSE, OnClose, NULL);
	AssignMessageHandler(WM_DESTROY, OnDestroy, NULL);
	m_hWnd = CreateWindowEx(
	extendedWndStyles,					//Extended window style
	wcex.lpszClassName,					//Registered window class
	title,								//Window caption
	wndStyles,							//Window styles
	xPos,yPos,							//Window position
	width, height,						//Window dimensions
	parent,								//Handle to parent window
	child,								//Handle to menu or child window
	m_hInstance,						//Handle to associated instance
	creationData						//Window creation data
	);

	if(m_hWnd!=NULL)
	{
		return true;
	}
	else
	{
		UnregisterClass(m_title, m_hInstance);
		return false;
	}
}
bool Window::HandleMessage()
{
	MSG msg;
	if(PeekMessage(&msg, m_hWnd, 0, 0, PM_REMOVE) != 0)
	{
		TranslateMessage(&msg);//convert the message into char messages
		DispatchMessage(&msg);//send msg to wndproc()
		return true;
	}
	return false;
}
void Window::Destroy()
{
	_OnDestroy();
	DestroyWindow(m_hWnd);
	m_hWnd=NULL;
	UnregisterClass(m_title, m_hInstance);
}
LRESULT CALLBACK Window::WndProcWrapper(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	// Messages dispatched at window creation, in order:

	// WM_GETMINMAXINFO = 0x24 = 36
	// WM_NCCREATE = 0x0081 = 129
	// WM_NCCALCSIZE = 0x0083 = 131
	// WM_CREATE = 0x0001 = 1

	if(msg==WM_NCCREATE)
	{
		Window* ptr = WndPtr();
		m_ptrMap.insert(std::make_pair(hwnd,ptr));
		CREATESTRUCT* wc = (CREATESTRUCT*)(lParam);
		ptr->m_width=wc->cx;
		ptr->m_height=wc->cy;
		ptr->m_pos.x=wc->x;
		ptr->m_pos.y=wc->y;
	}
	else
	{
		static std::map<HWND, Window*>::iterator it;
		it = m_ptrMap.find(hwnd);
		if(msg==WM_SIZE)
		{
			RECT rect;
			GetWindowRect(hwnd,&rect);
			it->second->m_width=rect.right-rect.left;
			it->second->m_height=rect.bottom-rect.top;
			it->second->m_clientHeight=HIWORD(lParam);
			it->second->m_clientWidth=LOWORD(lParam);
		}
		if(it != m_ptrMap.end())
		{
			std::map<UINT, MessageHandler>::iterator it2;
			it2 = it->second->m_messageHandlers.find(msg);
			if(it2 != it->second->m_messageHandlers.end())
				return it2->second.handler(it->second,wParam, lParam, it2->second.data);
		}
	}
	return DefWindowProc(hwnd,msg,wParam,lParam);
}
void Window::AssignMessageHandler(UINT msg, LRESULT(*handler)(Window*, WPARAM, LPARAM, void* data), void* data)
{
	std::map<UINT, MessageHandler>::iterator it;
	it = m_messageHandlers.find(msg);
	if(it!=m_messageHandlers.end())
	{
		it->second.handler = handler;
		it->second.data=data;
	}
	else
	{
		MessageHandler msgh;
		msgh.data=data;
		msgh.handler=handler;
		m_messageHandlers.insert(std::make_pair(msg, msgh));
	}
}
Window* Window::WndPtr(Window* setPtr)
{
	static Window* ptr;
	if(setPtr!=NULL)
		ptr=setPtr;
	else
	{
		Window* retPtr = ptr;
		ptr=NULL;
		return retPtr;
	}
	return ptr;

}
HWND Window::GetHandle()
{
	return m_hWnd;
}
bool Window::Exists()
{
	return (m_hWnd!=NULL);
}
LRESULT Window::OnClose(Window* wnd, WPARAM , LPARAM , void* )
{
	wnd->Destroy();
	return 0;
}
LRESULT Window::OnDestroy(Window* , WPARAM , LPARAM , void* )
{
	PostQuitMessage(0);
	return 0;
}

void Window::_OnDestroy()
{
	
}

int Window::GetHeight()
{
	return m_height;
}
int Window::GetWidth()
{
	return m_width;
}
int Window::GetClientHeight()
{
	return m_clientHeight;
}
int Window::GetClientWidth()
{
	return m_clientWidth;
}
POINT Window::GetPos()
{
	return m_pos;
}
