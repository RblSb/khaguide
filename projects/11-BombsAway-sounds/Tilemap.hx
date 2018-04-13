package;

class Tilemap<T> {
    
    /* width */         public var w : Int;
    /* height */        public var h : Int;
    /* tile width */    public var tw : Int;
    /* tile height */   public var th : Int;
    public var d : Array<T>;
    
    public function new(w, h, tw, th, v) {
        this.w = w;
        this.h = h;
        this.tw = tw;
        this.th = th;
        this.d = [for (i in 0...w * h) v];
    }
    
    public inline function x(idx : Int) : Int {
        return idx % w;
    }
    
    public inline function y(idx : Int) : Int {
        return Std.int(idx / w);
    }
    
    public inline function i(x : Int, y : Int) : Int {
        if (x < 0) return -1;
        else if (x >= w) return -1;
        else if (y < 0) return -1;
        else if (y >= h) return -1;
        else return y * w + x;
    }

    // tile -> pixel
    public inline function x2p(x : Float) : Float {
        return x * tw;
    }
    
    public inline function y2p(y : Float) : Float {
        return y * th;
    }
    
    // pixel -> tile
    public inline function p2x(p : Float) : Float {
        return p / tw;
    }
    
    public inline function p2y(p : Float) : Float {
        return p / th;
    }
    
    public inline function p2i(x : Float, y : Float) : Int {
        var tx = Std.int(x / tw);
        var ty = Std.int(y / th);
        return i(tx, ty);
    }
    
}
