package;

import haxe.Template;
import sys.io.File;

class Main {
	
	static function main():Void {
		new Main();
	}
	
	function new() {
		var data = File.getContent('book.md');
		var output = new Template(data).execute({}, this);
		File.saveContent('../docs/book.md', output);
	}
	
	function include(resolve:String->Dynamic, link:String):String {
		return File.getContent("../" + link);
	}
	
}
