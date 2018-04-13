package;
import haxe.Json;
import kha.FastFloat;
import kha.graphics2.Graphics;
import kha.Image;

class BoundsImage {
    public var names : Array<String>;
    public var rects : Array<Array<Int>>;
    public var names_map : Map<String, Int>;
    public var image_relative : String;
    public var image_absolute : String;
    public function new() {
        
    }
    public function updateCache() {
        names_map = new Map();
        for (i0 in 0...names.length) {
            names_map.set(names[i0], i0);
        }
    }
    public inline function nameToRect(name : String, ?offset : Int=0) {
        return rects[names_map.get(name)+offset];
    }   
}

class BoundsData {
    public var images : Array<BoundsImage>;
    public var palette : Array<Array<Int>>;
    
    public function new(data : String)
    {
        var jd = Json.parse(data);
        this.palette = jd.palette;
        this.images = [];
        for (img in cast(jd.images,Array<Dynamic>)) {
            var rimg = new BoundsImage();
            rimg.names = img.names;
            rimg.rects = img.rects;
            rimg.image_relative = img.image_relative;
            rimg.image_absolute = img.image_absolute;
            rimg.updateCache();
            this.images.push(rimg);
        }
    }
}

typedef FontData = {
    font_name : String,
    image_idx : Int, sprite_name:String, characters:String,
    whitespace : Int
};

class KhaBoundsData {
    public var boundsdata : BoundsData;
    public var images : Array<Image>;
    public var fonts : Map<String, FontData>;
    public var font_cache : Map<String, Map<Int, Int>>;
    public function new( data : String, images : Array<Image>,
        fonts : Array<FontData>) {
        this.boundsdata = new BoundsData(data);
        this.images = images;
        this.fonts = new Map();
        for (n in fonts) this.fonts.set(n.font_name, n);
        this.font_cache = new Map();
        for (f0 in fonts) {
            var f1 = new Map<Int, Int>();
            for (o in 0...f0.characters.length) {
                var dest = o;
                var src = f0.characters.charCodeAt(o);
                f1.set(src, 
                boundsdata.images[f0.image_idx].names_map.get(
                    f0.sprite_name) + dest);                
            }
            font_cache.set(f0.font_name, f1);
        }
    }
    public inline function draw(g2 : Graphics, x : FastFloat, y : FastFloat, 
        image_idx : Int, sprite_name : String, ?sprite_offset : Int=0)
    {
        var bound = get(image_idx, sprite_name, sprite_offset);
        g2.drawSubImage(images[image_idx], 
            x, y, bound[0], bound[1], bound[2], bound[3]);
    }
    public inline function drawCenter(g2 : Graphics, 
        x : FastFloat, y : FastFloat,
        w : FastFloat, h : FastFloat,
        image_idx : Int, sprite_name : String, ?sprite_offset : Int = 0)
    {
        var bound = get(image_idx, sprite_name, sprite_offset);
        var cx = x + w / 2 - bound[2] / 2;
        var cy = y + h / 2 - bound[3] / 2;
        g2.drawSubImage(images[image_idx], 
            cx, cy, bound[0], bound[1], bound[2], bound[3]);
    }
    public inline function drawCenterScaled(g2 : Graphics, 
        x : FastFloat, y : FastFloat,
        w : FastFloat, h : FastFloat,
        sw : FastFloat, sh : FastFloat,
        image_idx : Int, sprite_name : String, ?sprite_offset : Int = 0)
    {
        var bound = get(image_idx, sprite_name, sprite_offset);
        var dw = bound[2] * sw;
        var dh = bound[3] * sh;
        var cx = x + w / 2 - dw / 2;
        var cy = y + h / 2 - dh / 2;
        g2.drawScaledSubImage(images[image_idx], 
            bound[0], bound[1], bound[2], bound[3], cx, cy, 
            dw, dh);
    }
    public inline function get(image_idx : Int, sprite_name : String, 
        ?sprite_offset : Int=0)
    {
        return boundsdata.images[image_idx].nameToRect(sprite_name, 
            sprite_offset);
    }
    public inline function stringWidth(text : String, font : String,
        spacing : Int) {
        var f0 = fonts.get(font);
        var f1 = font_cache.get(font);
        var result = 0;
        for (i0 in 0...text.length) {
            var c = text.charCodeAt(i0);
            if (f1.exists(c)) {
                var bd = boundsdata.images[f0.image_idx].rects[f1.get(c)];
                result += bd[2];
            } else if (c == ' '.charCodeAt(0)) {
                result += f0.whitespace;
            }
            if (i0 < text.length-1)
                result += spacing;
        }
        return result;
    }
    public inline function stringHeight(text : String, font : String) {
        var f0 = fonts.get(font);
        var f1 = font_cache.get(font);
        var result = 0;
        for (i0 in 0...text.length) {
            var c = text.charCodeAt(i0);
            if (f1.exists(c)) {
                var bd = boundsdata.images[f0.image_idx].rects[f1.get(c)];
                if (bd[3] > result) result = bd[3];
            }
        }
        return result;
    }
    public inline function string(g2 : Graphics, x : Int, y : Int,
        text : String, font : String,
        spacing : Int) {
        var f0 = fonts.get(font);
        var f1 = font_cache.get(font);
        for (i0 in 0...text.length) {
            var c = text.charCodeAt(i0);
            if (f1.exists(c)) {
                var bd = boundsdata.images[f0.image_idx].rects[f1.get(c)];
                var img = images[f0.image_idx];
                g2.drawSubImage(img, x, y, bd[0], bd[1], bd[2], bd[3]); 
                x += bd[2];
            } else if (c == ' '.charCodeAt(0)) {
                x += f0.whitespace;
            }
            if (i0 < text.length-1)
                x += spacing;
        }
    }   
}
