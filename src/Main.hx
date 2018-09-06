package;

import haxe.Template;
import sys.io.File;
using StringTools;

class Main {

	var data:String;

	static function main():Void {
		new Main();
	}

	function new() {
		data = File.getContent("book.md");
		var output = new Template(data).execute({}, this);
		File.saveContent("../docs/book.md", output);
	}

	function include(resolve:String->Dynamic, link:String):String {
		return File.getContent("../" + link);
	}

	function tableOfContents(resolve:String->Dynamic):String {
		var data = this.data;
		var start = data.indexOf("$$tableOfContents");
		if (start != -1) data = data.substr(start);
		var table = "";
		var arr = ~/\r?\n/g.split(data);
		var isCodeBlock = false;
		for (id in 0...arr.length) {
			var line = arr[id];

			if (line.startsWith("```")) {
				isCodeBlock = !isCodeBlock;
				continue;
			}
			if (isCodeBlock) continue;

			if (!~/^#+/.match(line)) continue;
			if (!~/^#+ /.match(line)) {
				trace('Warning: $line does not have space after #');
			}
			//count content level
			var indent = "";
			for (i in 1...line.length) {
				if (line.charAt(i) == "#") indent += "  ";
				else break;
			}
			//remove "# " block
			var name = ~/^#+ ?/.replace(line, "");

			//make link without punctuation chars
			var link = ~/[^A-z0-9 _-]/g.replace(name, "");
			//replace spaces with dashes
			var link = ~/ /g.replace(link, "-");
			link = link.toLowerCase();

			//add "-Num" postfix for repeated links
			var ereg = new EReg("(#" + link + ")", "");
			var matches = getMatches(ereg, table);
			if (matches.length > 0) link += "-" + matches.length;

			table += '$indent- [$name](#$link)\n';
		}
		//remove latest line break
		table = table.substr(0, table.length - 1);
		return table;
	}

	function getMatches(ereg:EReg, input:String, index = 0):Array<String> {
		var matches = [];
		while (ereg.match(input)) {
			matches.push(ereg.matched(index));
			input = ereg.matchedRight();
		}
		return matches;
	}

}
