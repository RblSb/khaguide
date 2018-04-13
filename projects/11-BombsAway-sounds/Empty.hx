package;
import kha.audio1.Audio;
import kha.audio1.AudioChannel;
import kha.Framebuffer;
import kha.Color;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.KeyCode;
import kha.math.FastMatrix3;
import kha.System;
import kha.Assets;
import BoundsData;
import kha.Sound;

enum MapTile {
    MTNone;
    MTWall;
    MTWallTL;
    MTWallTR;
    MTRock(value : Int);
}
enum ParticleProgram {
    Explosion;
}

typedef Plane = { x:Float, y:Float, 
    w:Float, h:Float, 
    vx:Float, vy:Float, 
    dropped:Bool, passes:Int
    };
typedef Bomb = { x:Float, y:Float, 
    w:Float, h:Float, 
    vx:Float, vy:Float, 
    alive:Bool, hit:Bool, hit_time:Int };
typedef Player = {
    score : Int, lives : Int,
    plane : Plane,
    bomb : Bomb
};
typedef Particle = {
    x : Float, y : Float,
    time : Int,
    program : ParticleProgram,
    sprite_image : Int,
    sprite_name : String
};

class Empty {
    public function new() {
        if (Keyboard.get() != null) Keyboard.get().notify(onDown,onUp);
        if (Mouse.get() != null) Mouse.get().notify(onDownMouse, onUpMouse, null, null);
        Assets.loadEverything(function() { load_finished = true; startGame(); game_over = true; } );
    }
    
    public static inline var WIDTH = 320;
    public static inline var HEIGHT = 240;
    
    public static inline var TILE_W = 8;
    public static inline var TILE_H = 8;
    public static inline var MAP_W = Std.int(WIDTH / TILE_W);
    public static inline var MAP_H = Std.int(HEIGHT / TILE_H);
    public static inline var CANYON_Y = Std.int(MAP_H / 2);
    public static inline var ROCKFALL_TIMER = 4;
    public static inline var PLANE_MINY = Std.int(HEIGHT * 0.1);
    public static inline var PLANE_MAXY = Std.int(HEIGHT * 0.4);
    public static inline var BOMB_HIT_TIMER = 6;
    public static inline var BOMB_GRAVITY = 0.08;
    public static inline var EXPLODE_0 = 10 * 4/4;
    public static inline var EXPLODE_1 = 10 * 3/4;
    public static inline var EXPLODE_2 = 10 * 2/4;
    public static inline var EXPLODE_3 = 10 * 1/4;
    public static inline var IS_BLIMP_UNTIL_VX = 1.0;
    
    public var load_finished = false;
    public var fire = false;
    var player : Array<Player>;
    var map : Tilemap<MapTile>;
    var rockfall_time : Int;
    var game_over : Bool;
    var high_score : Int = 100;
    var particle : Array<Particle>;
    var sprite : KhaBoundsData;
    var sound_bomb : Array<String>;
    var sound_explode : Array<String>;
    var channel_engine_blimp : AudioChannel;
    var channel_engine_plane : AudioChannel;
    var channel_drop : AudioChannel;
    var channel_break : AudioChannel;
    
    public function startGame() {
        player = [{ bomb:null, plane:null, score:0, lives:5 }];
        game_over = false;
        particle = [for (n in 0...64) 
            {x:0., y:0., program:Explosion, time: -1, 
            sprite_image:0, sprite_name:null}
        ];
        sound_bomb = [for (i in 0...4) ('bomb${i+1}')];
        sound_explode = [for (i in 0...12) ('explode${i+1}')];
        sprite = new KhaBoundsData(
            Assets.blobs.spritedata_json.toString(),
            [Assets.images.sprites],
            [
            {
                font_name:"alphabet1",
                image_idx:0,
                sprite_name:"alphabet1",
                characters:"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                whitespace:4
            },
            {
                font_name:"alphabet2",
                image_idx:0,
                sprite_name:"alphabet2",
                characters:"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                whitespace:4
            }
            ]
            );
        startLevel();
    }
    
    public function startLevel() {
        rockfall_time = 0;
        for (p in player) {
            p.plane = { x:0., y:0., w:8., h:8., vx:2., vy:0.,
                dropped:false, passes:0
            };
            respawnPlane(p.plane);
            p.bomb = { x:0., y:0., w:4., h:4., vx:0., vy:0., alive:false, hit:false,
                hit_time:BOMB_HIT_TIMER
            };
        }
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
                        map.d[idx] = // score based on depth
                        MTRock(Std.int((y - CANYON_Y + 1) * 5 / 
                            (MAP_H - CANYON_Y)));
                    }
                } else {
                    map.d[idx] = MTNone;
                }
            }
        }
        for (y in 0...map.h) { // smooth canyon
            for (x in 0...map.w) {
                var idx = map.i(x, y);
                if (map.d[idx] == MTWall && 
                    y > 0 && 
                    map.d[idx - MAP_W] != MTWall &&
                    map.d[idx - MAP_W] != MTWallTL &&
                    map.d[idx - MAP_W] != MTWallTR
                    ) {
                    if (x > 0 && map.d[idx - 1] != MTWall &&
                        map.d[idx - 1] != MTWallTL &&
                        map.d[idx - 1] != MTWallTR)
                        map.d[idx] = MTWallTL;
                    else if (x < map.w - 1 && 
                        map.d[idx + 1] != MTWall &&
                        map.d[idx + 1] != MTWallTL &&
                        map.d[idx + 1] != MTWallTR)
                        map.d[idx] = MTWallTR;
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
        if (!load_finished) return;
        // color settings
        var col_bg = Color.Black;
        var col_plane = Color.White;
        var col_bomb = Color.Red;
        var col_wall = Color.Blue;
        var col_rock = [Color.Orange, Color.Pink, Color.Purple, 
            Color.Red, Color.Cyan];
        var col_explosion = Color.White;
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
                            sprite.draw(g, 
                                x * TILE_W, y * TILE_H, 
                                0, "block");
                        case MTWallTL:
                            g.color = col_wall;
                            sprite.draw(g, 
                                x * TILE_W, y * TILE_H, 
                                0, "blocktl");
                        case MTWallTR:
                            g.color = col_wall;
                            sprite.draw(g, 
                                x * TILE_W, y * TILE_H, 
                                0, "blocktr");
                        case MTRock(v):
                            g.color = col_rock[v%5];
                            sprite.draw(g, 
                                x * TILE_W, y * TILE_H, 
                                0, "boulder");                          
                    }
                    x += 1;
                    if (x >= MAP_W) { x = 0; y += 1; }
                }
            }
            for (p in player) {
                { // render plane
                    g.color = col_plane;
                    var mirror = 1;
                    var plane = p.plane;
                    if (plane.vx < 0) mirror = -1;
                    var spr = "plane";
                    if (isBlimp(plane))
                        spr = "blimp";
                    sprite.drawCenterScaled(g, plane.x, plane.y,
                        plane.w, plane.h, 
                        mirror, 1, 0, spr);
                }
                if (p.bomb.alive) { // render bomb
                    var bomb = p.bomb;
                    g.color = col_bomb;
                    sprite.drawCenter(g, bomb.x, bomb.y, bomb.w, bomb.h, 
                        0, "bomb");
                }
            }
            for (p in particle) { // render particles
                if (p.time > 0) {
                    g.color = col_explosion;
                    sprite.draw(g, p.x, p.y, p.sprite_image, p.sprite_name);
                }
            }
            { // render some text
                if (game_over) {
                    string(
                        g, 'SCORE ${player[0].score}     HIGH ${high_score}',
                        8, 8, 1
                    );
                    var gotxt = 'Game Over'.toUpperCase();
                    centerString(
                        g, 
                        gotxt,
                        WIDTH / 2,
                        HEIGHT / 2,
                        1
                    );
                } else {
                    string(
                        g,
                        'LIVES ${player[0].lives}     SCORE ${player[0].score}' +
                        '     HIGH ${high_score}',  
                        8, 8, 1
                    );
                }
            }
            g.popTransformation();
            g.end();
        }
    }
    
    public function outOfBounds(plane : Plane) {
        return (plane.x > WIDTH + plane.w || plane.x < -plane.w * 2);
    }
    public function respawnPlane(plane : Plane) {
        if (Math.random() > 0.5) {
            plane.x = -plane.w + 1;
            plane.vx = 1;
        } else {
            plane.x = WIDTH + 1;
            plane.vx = -1;
        }
        plane.y = (Math.random() * (PLANE_MAXY - PLANE_MINY)) 
            + PLANE_MINY;
        plane.vx *= Math.min(0.5 + (plane.passes+1) * 0.15, 1.5);
        if (channel_engine_blimp != null) channel_engine_blimp.stop();
        if (channel_engine_plane != null) channel_engine_plane.stop();
        if (isBlimp(plane)) {
            channel_engine_blimp = Audio.play(Assets.sounds.engine_blimp, true);
            channel_engine_blimp.volume = 0.0;
        } else {
            channel_engine_plane = Audio.play(Assets.sounds.engine_plane, true);            
            channel_engine_plane.volume = 0.0;
        }
    }
    
    public function update(): Void {
        if (!load_finished) return;
        for (p in player) {
            var bomb = p.bomb;
            var plane = p.plane;
            { // if we tapped the button spawn the bomb, if possible
                if (!game_over && fire && !bomb.alive && p.lives > 0)  {
                    bomb.alive = true;
                    bomb.x = plane.x + plane.w / 2 - bomb.w / 2;
                    bomb.y = plane.y + plane.h;
                    bomb.vx = plane.vx;
                    bomb.vy = 0.;
                    bomb.hit = false;
                    bomb.hit_time = BOMB_HIT_TIMER;
                    p.plane.dropped = true;
                    channel_drop = playRandom(sound_bomb);
                } else if (fire && game_over) {
                    startGame();
                }
            }
            { // advance plane movement
                plane.x += plane.vx;
                plane.y += plane.vy;
                { // adjust engine noise volume
                    var ch : AudioChannel;
                    if (Math.abs(plane.vx) < IS_BLIMP_UNTIL_VX)
                        ch = channel_engine_blimp;
                    else
                        ch = channel_engine_plane;
                    if (ch != null)
                        ch.volume = Math.sin((plane.x / WIDTH) * Math.PI * 0.9 + 0.1); 
                }
                // move plane into new passing position; end turn
                var turn_over = false;
                if (outOfBounds(plane) && !bomb.alive)
                {
                    plane.passes += 1;
                    respawnPlane(plane);
                    turn_over = true;
                }
                if (turn_over && !game_over) {
                    // test for whether turn was successful
                    if (!p.plane.dropped) {
                        p.lives -= 1;
                        Audio.play(Assets.sounds.miss);
                        channel_drop.stop();
                    } else if (!p.bomb.alive) {
                        //Audio.play(Assets.sounds.hit);
                        channel_drop.stop();
                    }
                    p.plane.dropped = false;
                    // test for new level
                    var newlevel = true;
                    for (t in map.d) {
                        if (t.getIndex() == MTRock(0).getIndex()) {
                            newlevel = false;
                        }
                    }
                    if (newlevel) {
                        startLevel();
                    }
                    if (p.lives < 1) {
                        game_over = true;
                        if (p.score > high_score)
                            high_score = p.score;
                    }
                }
            }
            { // advance bomb movement
                if (bomb.alive) {
                    bomb.vy += BOMB_GRAVITY; // gravity
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
                    var damage = 0;
                    damage = Std.int(Math.max(damage, bombCollision(i0, p)));
                    damage = Std.int(Math.max(damage, bombCollision(i1, p)));
                    damage = Std.int(Math.max(damage, bombCollision(i2, p)));
                    damage = Std.int(Math.max(damage, bombCollision(i3, p)));
                    if (damage > 0 && bomb.hit)
                    {
                        if (channel_break == null || channel_break.position > 0)
                            channel_break = playRandom(sound_explode);
                    }
                    bomb.hit_time -= damage;
                    if (bomb.hit_time < 1) bomb.alive = false;
                    if (bomb.y > HEIGHT)
                        bomb.alive = false;
                    if (!bomb.alive && !bomb.hit)
                    {
                        p.lives -= 1;
                        Audio.play(Assets.sounds.miss);
                    }
                }
            }
        }
        if (rockfall_time < 1) { // advance the rock fall
            rockfall_time = ROCKFALL_TIMER;
            for (y in 1...MAP_H) {
                var iy0 = (MAP_H - 1) - y; // rock to fall
                var iy1 = iy0 + 1; // tile underneath
                for (x in 0...MAP_W) {
                    var idx0 = map.i(x, iy0);
                    var idx1 = map.i(x, iy1);
                    if (map.d[idx0].getIndex() == Type.enumIndex(MTRock(0))
                        && map.d[idx1] == MTNone)
                    {
                        map.d[idx1] = map.d[idx0];
                        map.d[idx0] = MTNone;
                    }
                }
            }
        } else {
            rockfall_time--;
        }
        for (p in particle) { // particle simulation
            if (p.time > 0) {
                switch(p.program) { // run particle program
                    case Explosion:
                        p.sprite_image = 0;
                        if (p.time > EXPLODE_1) {
                            p.sprite_name = "explosion1";
                        }
                        else if (p.time > EXPLODE_2) {
                            p.sprite_name = "explosion2";
                        }
                        else if (p.time > EXPLODE_3) {
                            p.sprite_name = "explosion3";
                        }
                        else {
                            p.sprite_name = "explosion4";
                        }
                        p.y -= 0.2;
                }
                p.time -= 1;
            }
        }
    }
    
    public function bombCollision(idx : Int, p : Player) : Int {
        if (idx < 0 || idx > map.d.length) return 0;
        else switch(map.d[idx]) {
            case MTNone: return 0;
            case MTWall, MTWallTL, MTWallTR: return BOMB_HIT_TIMER;
            case MTRock(v): map.d[idx] = MTNone; 
                p.score += v;
                p.bomb.hit = true;
                spawnParticle(
                    map.x2p(map.x(idx)), 
                    map.y2p(map.y(idx)), Explosion);
                return 1;
        }
    }
    
    public function spawnParticle(x : Float, y : Float, program : ParticleProgram) {
        for (pi in 0...particle.length) {
            var p = particle[pi];
            if (p.time <= 0) {
                p.program = program;
                p.x = x;
                p.y = y;
                switch(program) {
                    case Explosion:
                        p.time = Std.int(EXPLODE_0 + Math.random() * 6);
                }
                return pi;
            }
        }
        return -1;
    }
    
    public function isBlimp(p : Plane) {
        return (Math.abs(p.vx) < IS_BLIMP_UNTIL_VX);
    }
    
    public function string(g, s, x : Float, y : Float, spacing) {
        sprite.string(
            g, 
            Std.int(x + 1),
            Std.int(y + 1),
            s,
            "alphabet2", spacing
        );
        sprite.string(
            g, 
            Std.int(x),
            Std.int(y),
            s,
            "alphabet1", spacing
        );
    }
    public function centerString(g, s, x : Float, y : Float, spacing) {
        sprite.string(
            g, 
            Std.int(x - sprite.stringWidth(s, "alphabet2", spacing) / 2 + 1),
            Std.int(y - sprite.stringHeight(s, "alphabet2") / 2 + 1),
            s,
            "alphabet2", spacing
        );
        sprite.string(
            g, 
            Std.int(x - sprite.stringWidth(s, "alphabet1", spacing) / 2),
            Std.int(y - sprite.stringHeight(s, "alphabet1") / 2),
            s,
            "alphabet1", spacing
        );
    }
    
    public function playRandom(ar : Array<String>) {
        return Audio.play(
            Reflect.field(Assets.sounds, (ar[Std.int(Math.random() * ar.length)])));
    }
    
}
