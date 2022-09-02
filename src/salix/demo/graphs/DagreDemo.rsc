module salix::demo::graphs::DagreDemo

import salix::App;
import salix::HTML;
import salix::Index;
import salix::lib::dagre::Dagre;
import util::Math;
import Set;
import List;

alias GModel = tuple[int clicks, rel[str, str] graph, str line, str shape, str word, real gold];

SalixApp[GModel] graphApp(str id = "graphDemo") 
  = makeApp(id, ginit, withIndex("Graph", id, gview, exts=[dagre()]), gupdate); 

App[GModel] graphWebApp() 
  = webApp(
      graphApp(), 
      |project://salix/src|
    );

GModel ginit() = <0, {<"a", "b">, <"b", "c">, <"a", "c">}, "cardinal", "rect", "", 19.30>;

data Msg
  = addNode()
  | click(str letter)
  | changeEdgeLine(str x)
  | changeShape(str x)
  ;


GModel gupdate(Msg msg, GModel m) {
  switch (msg) {
    case click(str l): {
      m.clicks += 1;
      m.word += l;
    }
  
    case addNode(): {
      str n1 = "abcdefghijklmnopqrstuvwxyz"[arbInt(26)];
      list[str] nodes = toList(m.graph<0> + m.graph<1>);
      str n2 = nodes[arbInt(size(nodes))];
      m.graph += {<n1, n2>}; 
    }
    
    case changeEdgeLine(str x):
      m.line = x;
      
    case changeShape(str x):
      m.shape = x;
    
  }
  return m;
}

// http://stackoverflow.com/questions/26348038/svg-foreignobjects-draw-over-all-other-elements-in-chrome?rq=1

void gview(GModel m) {
 style_(id("css"), "
	'text {
	'  font-weight: 300;
	'  font-family: \"Helvetica Neue\", Helvetica, Arial, sans-serf;
	'  font-size: 14px;
	'}
	'.node {
	'  stroke: #333;
	'  fill: #fff;
	'  stroke-width: 1.5px;
	'}
	'.edgePath path {
	'  stroke: #333;
	'  stroke-width: 1.5px;
	'}");

  div(class("container"), () {
    
    h2("Dagre graph demo with embedded HTML");
    
    h3("Clicks: <m.clicks>");
    h3("Word: <m.word>");
    
    button(onClick(addNode()), "Add a node!");
    
    h4("Line interpolation");
    button(onClick(changeEdgeLine("cardinal")), "Cardinal");
    button(onClick(changeEdgeLine("linear")), "Linear");
    button(onClick(changeEdgeLine("step")), "Step");
    button(onClick(changeEdgeLine("monotone")), "Monotone");

    h4("Shapes");
    button(onClick(changeShape("rect")), "Rectangle");
    button(onClick(changeShape("ellipse")), "Ellipse");
    button(onClick(changeShape("circle")), "Circle");
    button(onClick(changeShape("diamond")), "Diamond");
    
    h4("The graph");    
    
    dagre("mygraph", rankdir("LR"), width(960), height(600), (N n, E e) {
      for (str x <- m.graph<0> + m.graph<1>) {
        n(x, [shape(m.shape), () { 
          div(() {
	          h3("Here\'s node <x>");
	          p("A paragraph");
	                      
	          button(onClick(click(x)), "Click <x>");
	        });
        }]);
      }
      for (<str x, str y> <- m.graph) {
        e(x, y, [lineInterpolate(m.line)]);
      }
    });    
    
  });
}