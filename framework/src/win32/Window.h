#ifndef _H_WINDOW_
#define _H_WINDOW_

#include <cstdlib>
#include <string>
#include <map>
#include <windows.h>
#include "WindowDefines.h"

#ifndef WINDOW_ICON_ID
#define WINDOW_ICON_ID IDI_APPLICATION
#endif
#ifndef WINDOW_SMALLICON_ID
#define WINDOW_SMALLICON_ID IDI_APPLICATION
#endif
#ifndef WINDOW_CURSOR_ID
#define WINDOW_CURSOR_ID IDC_ARROW
#endif
#ifndef WINDOW_MENU_ID
#define WINDOW_MENU_ID NULL
#endif
#ifndef WINDOW_BCKGROUND_BRUSH
#define WINDOW_BCKGROUND_BRUSH (HBRUSH)GetStockObject( WHITE_BRUSH );
#endif

#define WND_DEF_CLASS_STYLE CS_HREDRAW|CS_VREDRAW
#define WND_DEF_STYLE WS_VISIBLE|WS_OVERLAPPEDWINDOW
#define WND_DEF_EXTENDED_STYLE WS_EX_CLIENTEDGE

class Window;

struct MessageHandler
{
	LRESULT(*handler)(Window*, WPARAM, LPARAM,  void* data);
	void* data;
};

class Window
{
public:
	Window();
	virtual ~Window();
	virtual bool Create(TCHAR title[], int xPos, int yPos, int width, int height,
				  DWORD wndClassStyles, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent = NULL, HMENU child = NULL, LPVOID creationData = NULL);
	virtual bool Create(TCHAR title[], int xPos, int yPos, int width, int height,
				  WNDCLASSEX wcex, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent = NULL, HMENU child = NULL, LPVOID creationData = NULL);
	virtual bool Create(TCHAR title[], int xPos, int yPos, int width, int height, WNDCLASSEX wcex);
	virtual bool Create(TCHAR title[], int xPos, int yPos, int width, int height);
	HWND GetHandle();
	void Destroy();
	bool Exists();
	bool HandleMessage();
	void AssignMessageHandler(UINT msg, LRESULT(*handler)(Window*, WPARAM, LPARAM, void* data), void* data=NULL);
	int GetHeight();
	int GetWidth();
	int GetClientWidth();
	int GetClientHeight();
	POINT GetPos();
protected:
	bool InternalCreate(TCHAR *title, int xPos, int yPos, int width, int height,
				  DWORD wndClassStyles, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent = NULL, HMENU child = NULL, LPVOID creationData = NULL);
	bool InternalCreate(TCHAR *title, int xPos, int yPos, int width, int height,
				  WNDCLASSEX wcex, DWORD wndStyles,DWORD extendedWndStyles,
				  HWND parent = NULL, HMENU child = NULL, LPVOID creationData = NULL);

	virtual void _OnDestroy();

	HWND m_hWnd;
	HINSTANCE m_hInstance;
	WNDCLASSEX m_windowClass;
	int m_height, m_width, m_clientHeight, m_clientWidth;
	TCHAR *m_title;
	POINT m_pos;
private:
	static LRESULT CALLBACK WndProcWrapper(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
	static LRESULT OnClose(Window* wnd, WPARAM wParam, LPARAM lParam, void* data);
	static LRESULT OnDestroy(Window* wnd, WPARAM wParam, LPARAM lParam, void* data);
	void PassKeyState(unsigned int key_code,bool state);
	static std::map<HWND, Window*> m_ptrMap;
	static Window* WndPtr(Window* setPtr = NULL);
	std::map<UINT, MessageHandler> m_messageHandlers;
};
#endif
