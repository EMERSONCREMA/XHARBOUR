/*

 MaxC.prg
 Biblioteca de funcoes desenvolvidas na linguagem C.

 DENIS MAZZUCATTO RODRIGUES
 27/01/16 * Desenvolvimento de DisableButtonClose() e EnableButtonClose().
 29/05/13 * Desenvolvimento de BringToFront().
 13/10/10 * Início do desenvolvimento.

*/

#pragma begindump

#include <shlobj.h>
#include <windows.h>
#include <commctrl.h>
#include <wingdi.h>
#include "hbapi.h"
#include "hbapiitm.h"

#define _WIN32_WINNT 0x0500

#define CS_TITLE "Control Shop .NET "


HB_FUNC( TITLECONSOLE )
// Modifica o título da janela DOS.
{
   SetConsoleTitle( CS_TITLE );
}


HB_FUNC( HIDECONSOLE )
// Esconde a janela DOS.
{
   SetConsoleTitle( CS_TITLE );
   ShowWindow( (HWND) FindWindow( NULL, CS_TITLE ), SW_HIDE );
   mouse_event( MOUSEEVENTF_ABSOLUTE, 0, 0, 0, 0 );
   SetForegroundWindow( (HWND) hb_parnl(1) );
}


HB_FUNC( SHOWCONSOLE )
// Exibe a janela DOS.
{
   HWND hWnd = FindWindow( NULL, CS_TITLE );
   HMENU hMenu = GetSystemMenu( hWnd, FALSE );
   RECT rRect;

   DeleteMenu( hMenu, SC_CLOSE, MF_BYCOMMAND );
   if ( ( IsIconic( hWnd ) ) || ( ! IsWindowVisible( hWnd ) ) )
   {
      ShowWindow( hWnd, SW_RESTORE );
      GetWindowRect( hWnd, &rRect );
      SetWindowPos( hWnd, HWND_TOP, (GetSystemMetrics(SM_CXSCREEN)-(rRect.right-rRect.left))/2, (GetSystemMetrics(SM_CYSCREEN)-(rRect.bottom-rRect.top))/2, 800, 600, SWP_SHOWWINDOW && SWP_NOSIZE );
   }
   mouse_event( MOUSEEVENTF_ABSOLUTE, 0, 0, 0, 0 );
   SetForegroundWindow( hWnd );
}


HB_FUNC( SHOWREPORT )
// Forca a exibicao da tela de parametrizacoes do relatorio
{
   HWND hWnd = (HWND) hb_parnl(2);
   HMENU hMenu = GetSystemMenu( hWnd, FALSE );
   DeleteMenu( hMenu, SC_CLOSE, MF_BYCOMMAND );

   mouse_event( MOUSEEVENTF_ABSOLUTE, 0, 0, 0, 0 ); 
   SetForegroundWindow( (HWND) hb_parnl(1) );
}


HB_FUNC( BRINGTOFRONT )
// Envia uma janela para a frente
{
   mouse_event( MOUSEEVENTF_ABSOLUTE, 0, 0, 0, 0 );
   SetForegroundWindow( (HWND) hb_parnl(1) );
}


HB_FUNC( DISABLEBUTTONCLOSE )
// Desabilita o botao fechar do formulario
{
   HWND hWnd = (HWND) hb_parnl(1);
   HMENU hMenu = GetSystemMenu( hWnd, FALSE );
   if ( hMenu )
   {
      EnableMenuItem( hMenu, SC_CLOSE, MF_BYCOMMAND || MF_DISABLED );
   }
}


HB_FUNC( ENABLEBUTTONCLOSE )
// Habilita o botao fechar do formulario
{
   HWND hWnd = (HWND) hb_parnl(1);
   HMENU hMenu = GetSystemMenu( hWnd, FALSE );
   if ( hMenu )
   {
      EnableMenuItem( hMenu, SC_CLOSE, MF_BYCOMMAND || MF_ENABLED );
   }
}


HB_FUNC( MXPRESSMOUSE )
// Simula o clique do mouse
{
   if ( hb_parl(1) )  // WM_MOUSE_LEFT (botao esquerdo)
   {
      if ( hb_parl(2) )  // WM_MOUSE_DOWN (clicar)
      {
         mouse_event( MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0 ) ;
      }
      else  // WM_MOUSE_UP (soltar)
      {
         mouse_event( MOUSEEVENTF_LEFTUP, 0, 0, 0, 0 ) ;
      }
   }
   else  // WM_MOUSE_RIGHT (botao direito)
   {
      if ( hb_parl(2) )  // WM_MOUSE_DOWN (clicar)
      {
         mouse_event( MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0 ) ;
      }
      else  // WM_MOUSE_UP (soltar)
      {
         mouse_event( MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0 ) ;
      }
   }
}


HB_FUNC ( MXWSETSTYLE )
// Define o estilo da janela (deixa a borda de titulo menor)
{
   HWND hWnd = (HWND) hb_parnl(1);
   SetWindowLong( hWnd, GWL_EXSTYLE, WS_EX_TOOLWINDOW );
}


// Le as entradas de teclado e retorna informacoes sobre a tecla pressionada.
// Estas funcoes interceptam as mensagens de teclado do sistema (WM_KEYUP e
// WM_KEYDOWN) e armazena as informacoes sobre a tecla virtual.

HB_LONG flag_hhk  = 0;  // FALSE
HB_LONG PAUSE_hhk = 0;  // FALSE
HB_LONG VK_PRESS  = 0;
HB_LONG VK_lParam = 0;
HHOOK hhk = NULL;

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    if (nCode < 0) 
        return CallNextHookEx( hhk, nCode, wParam, lParam );
        
    if (PAUSE_hhk == 0)  // FALSE
    {   VK_PRESS = (long) wParam;
        VK_lParam = (LONG) lParam;
    }
    else    
    {   VK_PRESS = 0;
        VK_lParam = 0;
    }   
    return CallNextHookEx(hhk, nCode, wParam, lParam);
}


HB_FUNC (MXREADKEYON)
// Instala o controle para leitura do teclado
{
   if (flag_hhk == 0)  // FALSE
   {    hhk = SetWindowsHookEx (WH_KEYBOARD, KeyboardProc, (HINSTANCE) NULL, GetCurrentThreadId());
        
        if (hhk == NULL) 
            hb_retl (FALSE);
        else
        {   flag_hhk = 1;  // TRUE
            hb_retl (TRUE);                       
        }   
   }
   else
      hb_retl (TRUE);      
}


HB_FUNC (MXREADKEYOFF)
// Desinstala o controle para leitura do teclado
{
   if (flag_hhk == 1)  // TRUE
   {   if (UnhookWindowsHookEx (hhk) == TRUE)
       {   flag_hhk = 0;  // FALSE
           hb_retl (TRUE);           
       }
       else
           hb_retl (FALSE);   
   }
   else
      hb_retl (TRUE);      
}


HB_FUNC (PAUSE_READ_VK)
// Pausa/restabelece a leitura do teclado
{
   if (hb_pcount () == 1 && hb_parinfo (1) == HB_IT_LOGICAL)   
   {   if (hb_parl (1) == TRUE) 
       {   VK_PRESS = 0;
           VK_lParam = 0;
       }     
       if (hb_parl (1) == TRUE)
          PAUSE_hhk = 1;
       else
          PAUSE_hhk = 0;
   }
}


HB_FUNC (MXLASTKEY)
// Retorna o valor virtual (VK Code) de tecla presionada
{
   if (flag_hhk == 1)  // TRUE
       hb_retnl (VK_PRESS);
   else
      hb_retnl (0);    
}


HB_FUNC (MXLASTKEYNAME)
// Retorna o nome da tecla virtual pressionada
{
   CHAR cadena [128];

   if (flag_hhk == 1)  // TRUE
      {  GetKeyNameText (VK_lParam, (LPTSTR) &cadena, 128);
         hb_retc (cadena);
      }
   else
      hb_retc ("");    
}


static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle);

HB_FUNC ( SHOWNOTIFYINFO )
{
	ShowNotifyInfo( (HWND) hb_parnl(1), (BOOL) hb_parl(2), (HICON) hb_parnl(3), (LPSTR) hb_parc(4),
			(LPSTR) hb_parc(5), (LPSTR) hb_parc(6) );
}

static void ShowNotifyInfo(HWND hWnd, BOOL bAdd, HICON hIcon, LPSTR szText, LPSTR szInfo, LPSTR szInfoTitle)
{
	NOTIFYICONDATA nid;

	ZeroMemory( &nid, sizeof(nid) );

	nid.cbSize		= sizeof(NOTIFYICONDATA);
	nid.hIcon		= hIcon;
	nid.hWnd		= hWnd;
	nid.uID			= 0;
	nid.uFlags		= NIF_INFO | NIF_TIP | NIF_ICON;
	nid.dwInfoFlags		= NIIF_INFO;

	lstrcpy( nid.szTip, TEXT(szText) );
	lstrcpy( nid.szInfo, TEXT(szInfo) );
	lstrcpy( nid.szInfoTitle, TEXT(szInfoTitle) );

	if(bAdd)
		Shell_NotifyIcon( NIM_ADD, &nid );
	else
		Shell_NotifyIcon( NIM_DELETE, &nid );

	if(hIcon)
		DestroyIcon( hIcon );
}

#pragma enddump