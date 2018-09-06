package;

import kha.Scheduler;
import kha.Framebuffer;
import kha.Window;
import kha.System;

class Main {
    public static function main() : Void {
        System.start({title:"Empty", width:640, height:480}, initialized);
    }

    private static function initialized(window : Window) : Void {
        var game = new Empty();
        System.notifyOnFrames(
            function(fbs : Array<Framebuffer>) {
                game.render(fbs[0]);
            }
        );
        Scheduler.addTimeTask(game.update, 0, 1 / 60);
    }
}
