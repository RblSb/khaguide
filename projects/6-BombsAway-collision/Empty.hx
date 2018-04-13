package;
import kha.Framebuffer;
import kha.Color;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.KeyCode;
import kha.math.FastMatrix3;
import kha.System;

enum MapTile {
    MTNone;
    MTWall;
    MTRock;
}

class Empty {
    public function new() {
        if (Keyboard.get() != null) Keyboard.get().notify(onDown,onUp);
        if (Mouse.get() != null) Mouse.get().notify(onDownMouse, onUpMouse, null, null);
        startLevel();
    }
    
    public static inline var WIDTH = 320;
    public static inline var HEIGHT = 240;
    
    public static inline var TILE_W = 8;
    public static inline var TILE_H = 8;
    public static inline var MAP_W = Std.int(WIDTH / TILE_W);
    public static inline var MAP_H = Std.int(HEIGHT / TILE_H);
    public static inline var CANYON_Y = Std.int(MAP_H / 2);
    
    public var fire = false;
    var plane = { x:0., y:0., w:8., h:8., vx:1., vy:0. };
    var bomb = { x:0., y:0., w:8., h:8., vx:0., vy:0., alive:false };
    var map : Tilemap<MapTile>;
    
    public function startLevel() {
        plane = { x:0., y:0., w:8., h:8., vx:1., vy:0. };
        bomb = { x:0., y:0., w:8., h:8., vx:0., vy:0., alive:false };
        fire = false;
        map = new Tilemap(MAP_W, MAP_H, TILE_W, TILE_H, MTNone); // initial sizing
        var columns = new Array<Int>();
        for (x in 0...MAP_W) { // generate walls
            var y = 0;
            if (x == 0 || x == MAP_W - 1) { y = CANYON_Y; } // sides blocked
            else { // procedural wall pattern
                y = Math.round(Math.sin((x / MAP_W) * 3.14159) * // take half a sine
                    (MAP_H - CANYON_Y)); // scaling
                y += CANYON_Y; // offset
                y += Std.int(Math.random() * 6 - 3); // noise
                // clamp:
                if (y < CANYON_Y) y = CANYON_Y;
                if (y >= MAP_H) y = MAP_H - 1;
            }
            columns.push(y);
        }
        for (x in 0...MAP_W - 2) { // smooth columns to prevent narrow gaps
            if (columns[x] < columns[x + 1] && columns[x + 2] < columns[x + 1])
            {
                columns[x + 1] = columns[x];
            }
        }
        for (x in 0...MAP_W) { // set the columns
            var wall_y = columns[x];
            for (y in 0...MAP_H) {
                var idx = map.i(x, y);
                if (y >= CANYON_Y) { // start drawing canyon here
                    if (y >= wall_y) {
                        map.d[idx] = MTWall;
                    } else {
                        map.d[idx] = MTRock;
                    }
                } else {
                    map.d[idx] = MTNone;
                }
            }
        }
    }
    
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
        var col_wall = Color.Blue;
        var col_rock = Color.Orange;
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
            { // render canyon
                var x = 0.;
                var y = 0.;
                for (t0 in map.d) {
                    switch(t0) {
                        case MTNone:
                        case MTWall:
                            g.color = col_wall;
                            g.fillRect(x * TILE_W, y * TILE_H, TILE_W, TILE_H);
                        case MTRock:
                            g.color = col_rock;
                            g.fillRect(x * TILE_W, y * TILE_H, TILE_W, TILE_H);
                    }
                    x += 1;
                    if (x >= MAP_W) { x = 0; y += 1; }
                }
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
                var top = bomb.y;
                var left = bomb.x;
                var right = bomb.x + bomb.w;
                var bottom = bomb.y + bomb.h;
                var i0 = map.p2i(left, top);
                var i1 = map.p2i(right, top);
                var i2 = map.p2i(left, bottom);
                var i3 = map.p2i(right, bottom);
                bomb.alive = bomb.alive && bombCollision(i0)
                                        && bombCollision(i1)
                                        && bombCollision(i2)
                                        && bombCollision(i3);
                if (bomb.y > HEIGHT) 
                    bomb.alive = false;
            }
        }
    }
    
    public function bombCollision(idx : Int) {
        if (idx < 0 || idx > map.d.length) return false;
        else switch(map.d[idx]) {
            case MTNone: return true;
            case MTWall: return false;
            case MTRock: map.d[idx] = MTNone; return true;
        }
    }
    
}
