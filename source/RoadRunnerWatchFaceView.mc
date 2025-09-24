import Toybox.ActivityMonitor; // replaced Activity with ActivityMonitor for daily steps
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class RoadRunnerWatchFaceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);

        var now = new Time.Moment(Time.now().value());
        var date = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
        
        // Format date as "31 JAN" (day and 3-letter month)
        var dateString = Lang.format("$1$", [date.day.toString()]);

        // Set the time text on the TimeLabel
        var timeLabel = View.findDrawableById("TimeLabel") as WatchUi.Text;
        timeLabel.setText(timeString);
        
        // Set the date text on the DateLabel
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        dateLabel.setText(dateString);
        
        // Daily steps via ActivityMonitor
        var info = ActivityMonitor.getInfo();
        if (info.steps != null) {
            (View.findDrawableById("StepsLabel") as WatchUi.Text).setText(info.steps.toString());
        }
        
        // Update battery icon
        _setBatteryIcon();
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function _setBatteryIcon() as Void {
        var pct = 0;
        
        // Try to get battery percentage from system stats
        try {
            var stats = System.getSystemStats();
            pct = stats.battery;
        } catch(e1) {}

        var res;
        if (pct <= 5) {
            res = $.Rez.Drawables.Battery0;
        } else if (pct <= 37) {
            res = $.Rez.Drawables.Battery25;
        } else if (pct <= 62) {
            res = $.Rez.Drawables.Battery50;
        } else if (pct <= 87) {
            res = $.Rez.Drawables.Battery75;
        } else {
            res = $.Rez.Drawables.Battery100;
        }

        var bmp = View.findDrawableById("BatteryIconDrawable") as Bitmap;
        try { 
            bmp.setBitmap(res); 
        } catch(e2) {}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    function _drawCustomTime(dc as Dc, timeString as String) as Void {
        var screenWidth = dc.getWidth();
        var screenHeight = dc.getHeight();
        var centerX = screenWidth / 2;
        var centerY = screenHeight / 2;
        
        // PoiretOne-inspired font settings
        var digitWidth = 40;
        var digitHeight = 60;
        var digitSpacing = 8;
        var colonWidth = 12;
        
        // Calculate total width and starting position
        var totalWidth = (digitWidth * 4) + (digitSpacing * 3) + colonWidth;
        var startX = centerX - (totalWidth / 2);
        var startY = centerY - (digitHeight / 2);
        
        // Set drawing color to white
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw each character
        var x = startX;
        for (var i = 0; i < timeString.length(); i++) {
            var char = timeString.substring(i, i + 1);
            if (char.equals(":")) {
                _drawColon(dc, x, startY + 15, colonWidth, digitHeight - 30);
                x += colonWidth + digitSpacing;
            } else {
                _drawDigit(dc, char.toNumber(), x, startY, digitWidth, digitHeight);
                x += digitWidth + digitSpacing;
            }
        }
    }

    function _drawDigit(dc as Dc, digit as Number, x as Number, y as Number, w as Number, h as Number) as Void {
        var strokeWidth = 4;
        var midY = y + (h / 2);
        
        // Draw PoiretOne-style thin digits
        switch (digit) {
            case 0:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x, y, strokeWidth, h, 2); // left
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 1:
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right line
                dc.fillRoundedRectangle(x + w/2, y, strokeWidth, strokeWidth * 2, 2); // top accent
                break;
            case 2:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h/2, 2); // top right
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x, midY, strokeWidth, h/2, 2); // bottom left
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 3:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                dc.fillRoundedRectangle(x + w/3, midY - strokeWidth/2, w/3*2, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 4:
                dc.fillRoundedRectangle(x, y, strokeWidth, h/2, 2); // top left
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                break;
            case 5:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x, y, strokeWidth, h/2, 2); // top left
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x + w - strokeWidth, midY, strokeWidth, h/2, 2); // bottom right
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 6:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x, y, strokeWidth, h, 2); // left
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x + w - strokeWidth, midY, strokeWidth, h/2, 2); // bottom right
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 7:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                break;
            case 8:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x, y, strokeWidth, h, 2); // left
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
            case 9:
                dc.fillRoundedRectangle(x, y, w, strokeWidth, 2); // top
                dc.fillRoundedRectangle(x, y, strokeWidth, h/2, 2); // top left
                dc.fillRoundedRectangle(x + w - strokeWidth, y, strokeWidth, h, 2); // right
                dc.fillRoundedRectangle(x, midY - strokeWidth/2, w, strokeWidth, 2); // middle
                dc.fillRoundedRectangle(x, y + h - strokeWidth, w, strokeWidth, 2); // bottom
                break;
        }
    }

    function _drawColon(dc as Dc, x as Number, y as Number, w as Number, h as Number) as Void {
        var dotSize = 6;
        var centerX = x + (w / 2) - (dotSize / 2);
        dc.fillCircle(centerX + dotSize/2, y + h/3, dotSize/2);
        dc.fillCircle(centerX + dotSize/2, y + (h*2/3), dotSize/2);
    }

}
