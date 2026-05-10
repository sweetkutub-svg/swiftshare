// SwiftShare Windows Toast Plugin
// Proprietary & Confidential. All Rights Reserved.
// This file contains the native C++ implementation for Windows Toast Notifications.
// It uses the Windows.UI.Notifications API to display Accept/Decline popups.

#include <windows.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/Windows.Data.Xml.Dom.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

using namespace winrt;
using namespace Windows::UI::Notifications;
using namespace Windows::Data::Xml::Dom;

class ToastPlugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "com.swiftshare/toast",
            &flutter::StandardMethodCodec::GetInstance());
        channel->SetMethodCallHandler(
            [](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
                if (call.method_name().compare("showTransferToast") == 0) {
                    auto args = std::get<flutter::EncodableMap>(*call.arguments());
                    std::string sender = "Unknown";
                    int fileCount = 0;
                    std::string totalSize = "0 MB";

                    auto it = args.find(flutter::EncodableValue("senderName"));
                    if (it != args.end()) {
                        sender = std::get<std::string>(it->second);
                    }
                    auto it2 = args.find(flutter::EncodableValue("fileCount"));
                    if (it2 != args.end()) {
                        fileCount = std::get<int>(it2->second);
                    }
                    auto it3 = args.find(flutter::EncodableValue("totalSize"));
                    if (it3 != args.end()) {
                        totalSize = std::get<std::string>(it3->second);
                    }

                    ShowTransferToast(sender, fileCount, totalSize);
                    result->Success(flutter::EncodableValue(true));
                } else {
                    result->NotImplemented();
                }
            });
    }

private:
    static void ShowTransferToast(const std::string& sender, int fileCount, const std::string& totalSize) {
        XmlDocument toastXml;
        toastXml.LoadXml(L"<toast activationType='foreground' launch='accept'>"
            L"<visual><binding template='ToastGeneric'>"
            L"<text>SwiftShare - Incoming Transfer</text>"
            L"<text>From: " + winrt::to_hstring(sender) + L"</text>"
            L"<text>" + winrt::to_hstring(std::to_string(fileCount)) + L" files (" + winrt::to_hstring(totalSize) + L")</text>"
            L"</binding></visual>"
            L"<actions>"
            L"<action content='Accept' arguments='accept' activationType='foreground'/>"
            L"<action content='Decline' arguments='decline' activationType='foreground'/>"
            L"</actions>"
            L"</toast>");

        ToastNotificationManager::CreateToastNotifier().Show(ToastNotification(toastXml));
    }
};
