#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// Global window handle for window control
HWND g_hwnd = nullptr;

// Function to restore window to normal size (not maximized)
void RestoreWindow() {
  if (g_hwnd) {
    ShowWindow(g_hwnd, SW_RESTORE);
  }
}

// Function to maximize window (windowed full screen with title bar)
void MaximizeWindow() {
  if (g_hwnd) {
    ShowWindow(g_hwnd, SW_MAXIMIZE);
  }
}

// Function to toggle between maximized and restored
void ToggleMaximize() {
  if (g_hwnd) {
    WINDOWPLACEMENT wp;
    wp.length = sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(g_hwnd, &wp);
    
    if (wp.showCmd == SW_MAXIMIZE) {
      ShowWindow(g_hwnd, SW_RESTORE);
    } else {
      ShowWindow(g_hwnd, SW_MAXIMIZE);
    }
  }
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  
  // Get screen dimensions for maximized window
  int screenWidth = GetSystemMetrics(SM_CXSCREEN);
  int screenHeight = GetSystemMetrics(SM_CYSCREEN);
  
  // Create window at screen size for maximized appearance
  Win32Window::Point origin(0, 0);
  Win32Window::Size size(screenWidth, screenHeight);
  
  if (!window.Create(L"HealSearch", origin, size)) {
    return EXIT_FAILURE;
  }
  
  // Get window handle and maximize it (keeps title bar and decorations)
  HWND hwnd = window.GetHandle();
  g_hwnd = hwnd; // Store global reference for window control functions
  if (hwnd) {
    // Show the window maximized - this keeps the title bar but fills the screen
    ShowWindow(hwnd, SW_MAXIMIZE);
  }
  
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
