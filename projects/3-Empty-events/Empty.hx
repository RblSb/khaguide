package;
import kha.Framebuffer;
import kha.Color;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.input.Mouse;
import kha.math.FastMatrix3;
import kha.System;

class Empty {
    public function new() {
        if (Keyboard.get() != null) Keyboard.get().notify(onDown,onUp);
        if (Mouse.get() != null) Mouse.get().notify(onDownMouse,onUpMouse, null, null);
    }
    
    public static inline var WIDTH = 320;
    public static inline var HEIGHT = 240;
    
    public var fire = false;
    var plane = { x:0., y:0., w:8., h:8., vx:1., vy:0. };
    
    public function onDown(k : KeyCode) {
        trace(k + " down");
        fire = true;
    }
    public function onUp(k : KeyCode) {
        trace(k+" up");
        fire = false;
    }
    public function onDownMouse(button : Int, x : Int, y : Int) {
        trace('$button down');
        fire = true;
    }
    public function onUpMouse(button : Int, x : Int, y : Int) {
        trace('$button up');
        fire = false;
    }
    
    public function render(framebuffer: Framebuffer): Void {
        // color settings
        var col_bg = Color.Black;
        if (fire) 
            col_bg = Color.Red;
        var col_plane = Color.White;
        var transform = FastMatrix3.scale(
            System.windowWidth(0) / WIDTH, 
            System.windowHeight(0) / HEIGHT);
        { // graphics2 calls
            var g = framebuffer.g2;
            g.begin();
            g.clear(col_bg);
            g.pushTransformation(transform);
            g.color = col_plane;
            g.fillRect(plane.x, plane.y, plane.w, plane.h);
            g.popTransformation();
            g.end();
        }
    }
    
    public function update(): Void {
        { // advance plane movement
            plane.x += plane.vx;
            plane.y += plane.vy;
            // wrap around
            if (plane.x > WIDTH)
                plane.x = -plane.w + 1;
            else if (plane.x < -plane.w)
                plane.x = WIDTH + 1;
        }
    }
}
