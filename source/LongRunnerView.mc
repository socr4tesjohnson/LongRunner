using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Position;
using Toybox.Activity;
using Toybox.Communications;

class LongRunnerView extends WatchUi.View {

    var startTime;
    var distance = 0.0;
    var lastLocation = null;

    function onShow() {
        startTime = Time.now();
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT | Position.LOCATION_CONTINUOUS);
        System.println("LongRunner Mode Activated");
    }

    function onHide() {
        Position.disableLocationEvents();
    }

    function onPosition(locInfo) {
        if (lastLocation != null) {
            var delta = locInfo.position.distanceTo(lastLocation);
            distance += delta / 1000.0; // meters to km
        }
        lastLocation = locInfo.position;
        View.requestUpdate();
    }

    function onUpdate(dc) {
        var elapsed = Time.now().value() - startTime.value();
        var pace = distance > 0 ? (elapsed / 60.0) / distance : 0;

        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 30, Graphics.FONT_LARGE, "LongRunner", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 70, Graphics.FONT_XLARGE, format("%.2f km", distance), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 110, Graphics.FONT_LARGE, format("Pace: %.2f min/km", pace), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, 150, Graphics.FONT_LARGE, format("Time: %s", formatTime(elapsed)), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onKey(keyEvent) {
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
            System.println("📍 Location Ping Sent!");
            return true;
        }
        return false;
    }

    function formatTime(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        return format("%02d:%02d", h, m);
    }
}
