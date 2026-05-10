// SwiftShare Windows WiFi Plugin
// Proprietary & Confidential. All Rights Reserved.
// Native C++ implementation for Windows WiFi Direct and WiFi radio management.

#include <windows.h>
#include <wlanapi.h>
#pragma comment(lib, "wlanapi.lib")
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

class WifiPlugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "com.swiftshare/wifi",
            &flutter::StandardMethodCodec::GetInstance());
        channel->SetMethodCallHandler(
            [](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
                if (call.method_name().compare("isWifiEnabled") == 0) {
                    result->Success(flutter::EncodableValue(IsWifiEnabled()));
                } else if (call.method_name().compare("enableWifi") == 0) {
                    result->Success(flutter::EncodableValue(EnableWifi()));
                } else if (call.method_name().compare("getDeviceName") == 0) {
                    CHAR computerName[MAX_COMPUTERNAME_LENGTH + 1];
                    DWORD size = sizeof(computerName);
                    if (GetComputerNameA(computerName, &size)) {
                        result->Success(flutter::EncodableValue(std::string(computerName)));
                    } else {
                        result->Success(flutter::EncodableValue("Windows Device"));
                    }
                } else {
                    result->NotImplemented();
                }
            });
    }

private:
    static bool IsWifiEnabled() {
        HANDLE hClient = NULL;
        DWORD dwMaxClient = 2;
        DWORD dwCurVersion = 0;
        DWORD dwResult = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
        if (dwResult != ERROR_SUCCESS) return false;

        PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
        dwResult = WlanEnumInterfaces(hClient, NULL, &pIfList);
        bool enabled = false;
        if (dwResult == ERROR_SUCCESS && pIfList != NULL) {
            for (DWORD i = 0; i < pIfList->dwNumberOfItems; i++) {
                if (pIfList->InterfaceInfo[i].isState == wlan_interface_state_connected ||
                    pIfList->InterfaceInfo[i].isState == wlan_interface_state_ad_hoc_network_formed) {
                    enabled = true;
                    break;
                }
            }
            WlanFreeMemory(pIfList);
        }
        WlanCloseHandle(hClient, NULL);
        return enabled;
    }

    static bool EnableWifi() {
        // Windows does not allow programmatic WiFi enable for security reasons.
        // The app should open the WiFi settings panel instead.
        return false;
    }
};
