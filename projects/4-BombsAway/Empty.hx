package;
import kha.Framebuffer;
import kha.Color;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.KeyCode;
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
    var bomb = { x:0., y:0., w:8., h:8., vx:0., vy:0., alive:false };
    
    public function onDown(k : KeyCode) {
        fire = true;
    }
    public function onUp(k : KeyCode) {
        fire = false;
    }
    public function onDownMouse(button : Int, x : Int, y : Int) {
        fire = true;
    }
    public function onUpMouse(button : Int, x : Int, y : Int) {
        fire = false;
    }
    
    public function render(framebuffer: Framebuffer): Void {
        // color settings
        var col_bg = Color.Black;
        var col_plane = Color.White;
        var col_bomb = Color.Red;
        var transform = FastMatrix3.scale(
            System.windowWidth(0) / WIDTH, 
            System.windowHeight(0) / HEIGHT);
        { // graphics2 calls
            var g = framebuffer.g2;
            g.begin();
            g.pushTransformation(transform);
            { // render bg
                g.clear(col_bg);
            }
            { // render plane
                g.color = col_plane;
                g.fillRect(plane.x, plane.y, plane.w, plane.h);
            }
            if (bomb.alive) { // render bomb
                g.color = col_bomb;
                g.fillRect(bomb.x, bomb.y, bomb.w, bomb.h);
            }
            g.popTransformation();
            g.end();
        }
    }
    
    public function update(): Void {
        { // if we tapped the button spawn the bomb, if possible
            if (fire && !bomb.alive)  {
                bomb.alive = true;
                bomb.x = plane.x;
                bomb.y = plane.y;
                bomb.vx = plane.vx;
                bomb.vy = 0.;
            }
        }
        { // advance plane movement
            plane.x += plane.vx;
            plane.y += plane.vy;
            // wrap around
            if (plane.x > WIDTH)
                plane.x = -plane.w + 1;
            else if (plane.x < -plane.w)
                plane.x = WIDTH + 1;
        }
        { // advance bomb movement
            if (bomb.alive) {
                bomb.vy += 0.2; // gravity
                bomb.x += bomb.vx;
                bomb.y += bomb.vy;
                if (bomb.y > HEIGHT)
                    bomb.alive = false;
            }
        }
    }
}
