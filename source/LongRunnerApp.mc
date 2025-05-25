using Toybox.Application;
using Toybox.WatchUi;

class LongRunnerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart() {
        WatchUi.pushView(new LongRunnerView(), WatchUi.SLIDE_IMMEDIATE);
    }
}
