using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Attention as Attention;

class LongRunnerView extends Ui.View {

    function initialize() {
        Ui.View.initialize();
    }

    function onUpdate(dc as Gfx.Dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Format elapsed time as HH:MM:SS
        var hours = (elapsedSeconds / 3600).floor();
        var minutes = ((elapsedSeconds % 3600) / 60).floor();
        var seconds = (elapsedSeconds % 60).floor();
        var hoursStr = hours < 10 ? "0" + hours : "" + hours;
        var minutesStr = minutes < 10 ? "0" + minutes : "" + minutes;
        var secondsStr = seconds < 10 ? "0" + seconds : "" + seconds;
        var timeText = "Time: " + hoursStr + ":" + minutesStr + ":" + secondsStr;

        // Format distance in kilometers with two decimal places
        var distanceKm = totalDistance / 1000.0;
        var distText = "Distance: " + distanceKm.format("%.2f") + " km";

        // Format pace (minutes per km)
        var paceText;
        if (totalDistance < 20.0) {
            // Not enough distance to compute pace
            paceText = "Pace: --:-- min/km";
        } else {
            var secPerKm = elapsedSeconds / distanceKm;
            var paceMin = (secPerKm / 60).floor();
            var paceSec = (secPerKm % 60).floor();
            var paceMinStr = "" + paceMin;
            var paceSecStr = paceSec < 10 ? "0" + paceSec : "" + paceSec;
            paceText = "Pace: " + paceMinStr + ":" + paceSecStr + " min/km";
        }

        // Clear background
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.clear();

        // Choose a font and vertical positions for three lines of text
        var font = Gfx.FONT_MEDIUM;
        var y1 = (height * 0.2).toNumber();  // ~20% from top
        var y2 = (height * 0.5).toNumber();  // center
        var y3 = (height * 0.8).toNumber();  // ~80% from top

        // Draw Time (top)
        var w1 = dc.getTextWidth(font, timeText);
        dc.drawText((width - w1) / 2, y1, font, timeText);
        // Draw Distance (middle)
        var w2 = dc.getTextWidth(font, distText);
        dc.drawText((width - w2) / 2, y2, font, distText);
        // Draw Pace (bottom)
        var w3 = dc.getTextWidth(font, paceText);
        dc.drawText((width - w3) / 2, y3, font, paceText);
    }
}

class LongRunnerInputDelegate extends Ui.InputDelegate {

    function initialize() {
        Ui.InputDelegate.initialize();
    }

    function onKey(keyEvent as Ui.Input.KeyEvent) {
        var key = keyEvent.getKey();
        if (key == Ui.KEY_ENTER) {
            // "Ping" action – trigger a short vibration on Enter/Start button
            if (Attention has :vibrate) {
                Attention.vibrate([ new Attention.VibeProfile(100, 100) ]);
            }
            return true;  // handled
        } else if (key == Ui.KEY_ESC) {
            // Back button – not handled (allow system default to exit app)
            return false;
        }
        // Other keys – no action
        return false;
    }
}
