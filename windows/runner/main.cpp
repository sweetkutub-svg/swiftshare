#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <memory>
#include "win32_window.h"
#include "resource.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
    // Attach to console when present (e.g., output of flutter run, or build).
    if (::AttachConsole(ATTACH_PARENT_PROCESS) || ::AllocConsole()) {
        FILE *unused;
        if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
            _dup2(_fileno(stdout), 1);
        }
        if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
            _dup2(_fileno(stderr), 2);
        }
        std::ios::sync_with_stdio();
        FlutterDesktopResyncOutputStreams();
    }

    // Use HTTPS by default on Windows to avoid insecure content warnings.
    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    flutter::DartProject project(L"data");
    std::vector<std::string> command_line_arguments =
        GetCommandLineArguments();
    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(L"SwiftShare", origin, size)) {
        return EXIT_FAILURE;
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
