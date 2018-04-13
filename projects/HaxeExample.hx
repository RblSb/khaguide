package; // Package namespaces are organized by directory structure, supplemented with compiler options
import Std;
import Type;

class Test { // code must be contained inside classes

    public static function main() { // typical boilerplate for a "global" function

        trace("hello world"); // debug print
        
        var i = 100; // assign Int
        var f = 3.14; // assign Float
        var s = "50"; // assign String
        
        var si = Std.parseInt(s); // Std contains everyday type conversions
        
        if (i + si == 150) { // ECMA-style optional-brace syntax
           // print "100 + 50 = 150" two ways:
           
           // with concatenation
           trace(Std.string(i) + " + " + s + " = 150");
           // with string interpolation
           trace('$i + $s = ${i+si}');
        }
        
        var iar = [1,2,3]; // array assignment
        var iar2 = new Array<Int>(); // alternate method
        var iar3 : Array<Int> = []; // alternate method
        var iar4 : Array<Int>; // declare without assignment
        
        // assemble [1,2,3] in iar2
        iar2.push(iar[0]); // 0-indexing
        iar2.push(2);
        iar2.push(iar[iar.length-1]);
        
        for (idx in 0...iar.length) { // counting loop
            trace(iar[idx] == iar2[idx]);
        }
        for (n in iar) { // iterator loop
            trace(iar[n - 1] == n);
        }
        { // braces define a new variable scope
            var c = 0; // this will not live outside the braces
            while(c < iar.length) c+=1;
        }
        
        if (iar3 != null) { // null checks aren't "falsy"
            iar3 = iar.concat(iar2); // concat makes a copy
            trace(iar3.length == 6);
        }
        
        // instantiate a class and call some methods
        var q = new Inserter();
        q.insert(0);
        q.insert("hello world");
        q.insert(iar);
        trace(q.numberOfInts()==1);

    }

}

/* one file can contain multiple classes; import rules will default-import classes in the same namespace with the same filename. Additional classes will be hidden until the file is explicitly imported.
*/

class Inserter {

    public var a : Array<Dynamic>; // Haxe allows you to access dynamic typing (but it is considered bad style)
    public var count = 0; // default values can also be used

    public function new() { // all instantiated classes require a new()
        a = [];
    }
    
    public function insert(v : Dynamic) {
        a.push(v);
        count += 1;
    }
    
    public function numberOfInts() : Int {
        var result = 0;
        for (n in a) {
            if (Type.typeof(n)==TInt) // runtime type detection
                result += 1;
        }
        return result;
    }

}
