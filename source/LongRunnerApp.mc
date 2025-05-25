using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Math as Math;
using Toybox.Timer as Timer;
using Toybox.Time as Time;
using Toybox.Position as Position;
using Toybox.System as Sys;

var startTime = 0;              // start time in seconds since epoch
var elapsedSeconds = 0;         // elapsed seconds since start
var totalDistance = 0.0f;       // total distance in meters
var lastPosition = null;        // last known position [latitude, longitude] in radians

class LongRunnerApp extends App.AppBase {

    var timer;  // Timer for tracking elapsed time

    function initialize() {
        App.AppBase.initialize();
    }

    function onStart(state) {
        // Record the start time and initialize tracking variables
        startTime = Time.now().value();
        elapsedSeconds = 0;
        totalDistance = 0.0f;
        lastPosition = null;

        // Start a repeating timer to update elapsed time every second
        timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);

        // Enable continuous GPS location tracking
        if (Position has :enableLocationEvents) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        }

        // Request an initial screen update
        Ui.requestUpdate();
    }

    // Timer callback to update elapsed time and refresh the view
    function onTimer() {
        elapsedSeconds = Time.now().value() - startTime;
        Ui.requestUpdate();
    }

    // GPS location event callback (called whenever a new location fix is available)
    function onPosition(info as Position.Info) {
        if (info != null) {
            var loc = info.position;
            if (loc != null) {
                // Convert current location to radians [latitude, longitude]
                var currentPos = loc.toRadians();
                if (lastPosition != null) {
                    // Compute distance from last position to current (Haversine formula)
                    var dLat = currentPos[0] - lastPosition[0];
                    var dLon = currentPos[1] - lastPosition[1];
                    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                            Math.cos(lastPosition[0]) * Math.cos(currentPos[0]) *
                            Math.sin(dLon/2) * Math.sin(dLon/2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    var R = 6371000.0f; // Earth radius in meters
                    var segmentDistance = R * c;
                    // Filter out implausible jumps (>1000 m in one update)
                    if (segmentDistance < 1000.0f) {
                        totalDistance += segmentDistance;
                    }
                }
                // Update last known position
                lastPosition = currentPos;
            }
        }
        Ui.requestUpdate();
    }

    // Return the initial view (and input delegate for key handling)
    function getInitialView() {
        return [ new LongRunnerView(), new LongRunnerInputDelegate() ];
    }

    function onStop(state) {
        // Clean up: stop timer and disable GPS when app exits
        if (timer != null) {
            timer.stop();
        }
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }
}
