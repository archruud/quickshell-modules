pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Standalone Quickshell notification receiver, opted into by the user.
// NEVER instantiates NotificationServer while an existing D-Bus owner is found.
// Notification text is kept in memory for this session only (50 items max).
Singleton {
    id: root

    property string status: "checking"  // checking, disabled, conflict, error, active
    property var history: []
    property var toasts: []
    property var refs: ({})
    property int nextKey: 1
    readonly property int maxHistory: 50
    readonly property int maxToasts: 3
    readonly property int toastMilliseconds: 6500

    Process {
        running: true
        command: ["python3", Quickshell.shellPath("scripts/notifications_control.py"), "probe"]
        stdout: StdioCollector {
            onStreamFinished: {
                var state = text.trim();
                root.status = (["disabled", "conflict", "error", "active"].indexOf(state) >= 0)
                    ? state : "error";
                if (root.status !== "active")
                    console.log("ARCHRUUD Kairos notifications: " + root.status);
            }
        }
    }

    // This Loader creates the bus-owning server ONLY after the independent
    // probe has verified the explicit user opt-in and checked D-Bus ownership.
    Loader {
        active: root.status === "active"
        sourceComponent: Component {
            NotificationServer {
                bodySupported: true
                imageSupported: false
                actionsSupported: false
                bodyMarkupSupported: false
                persistenceSupported: false
                keepOnReload: false
                onNotification: (notification) => root.receive(notification)
            }
        }
    }

    function receive(notification) {
        if (!notification) return;
        // Track until the toast times out so the client gets the close signal.
        notification.tracked = true;
        var key = root.nextKey++;
        var now = Date.now();
        var entry = {
            key: key,
            appName: String(notification.appName || "Application").slice(0, 100),
            summary: String(notification.summary || "Notification").slice(0, 250),
            body: String(notification.body || "").slice(0, 1200),
            timestamp: now,
            expiresAt: now + root.toastMilliseconds
        };
        root.refs[key] = notification;
        root.history = [entry].concat(root.history).slice(0, root.maxHistory);
        var visible = [entry].concat(root.toasts);
        while (visible.length > root.maxToasts) {
            var oldest = visible.pop();
            root.release(oldest.key, false);
        }
        root.toasts = visible;
    }

    function release(key, dismissed) {
        var notification = root.refs[key];
        if (notification) {
            try {
                if (dismissed) notification.dismiss();
                else notification.expire();
            } catch (e) {
                console.warn("ARCHRUUD notification close:", e);
            }
            delete root.refs[key];
        }
    }

    function closeToast(key) {
        root.release(key, true);
        root.toasts = root.toasts.filter(function(item) { return item.key !== key; });
    }

    function clearAll() {
        var list = root.toasts;
        for (var i = 0; i < list.length; ++i)
            root.release(list[i].key, true);
        root.toasts = [];
        root.history = [];
    }

    function prune() {
        var now = Date.now();
        var keep = [];
        for (var i = 0; i < root.toasts.length; ++i) {
            var item = root.toasts[i];
            if (item.expiresAt <= now) root.release(item.key, false);
            else keep.push(item);
        }
        if (keep.length !== root.toasts.length)
            root.toasts = keep;
    }

    Timer {
        interval: 400
        repeat: true
        running: root.toasts.length > 0
        onTriggered: root.prune()
    }
}
