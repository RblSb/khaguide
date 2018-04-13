package;
import kha.Framebuffer;
import kha.Color;

class Empty {
    public function new() {
        
    }
    
    public function render(framebuffer: Framebuffer): Void {
        var nextcolor = [Color.White, Color.Red, Color.Blue, Color.Green, Color.Black][Std.int(Math.random() * 5)];
        var g = framebuffer.g1;
        g.begin();
        for (y in 0...framebuffer.height) {
        for (x in 0...framebuffer.width) {
        g.setPixel(x,y,nextcolor);
        }
        }
        g.end();
    }
    
    public function update(): Void {
        
    }
}
