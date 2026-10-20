
#include "../dll/AxHost/RdpWinMain.h"

int WINAPI wWinMain(
    _In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPWSTR lpCmdLine,
    _In_ int nShowCmd)
{
    if (!GetEnvironmentVariableA("MSRDPEX_MANUAL_CLIPBOARD_SYNC", NULL, 0))
        SetEnvironmentVariableA("MSRDPEX_MANUAL_CLIPBOARD_SYNC", "1");

    return MsRdpEx_WinMain(hInstance, hPrevInstance, lpCmdLine, nShowCmd, "mstsc");
}
