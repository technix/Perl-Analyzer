document.addEventListener("DOMContentLoaded", function(event) {

var tree_width =  (mlen * 7 + 100) * tdepth;
var tree_height = mchld * 45;
var tree_indent = mlen * 7 + 20;

var margin = {top: 20, right: tree_indent, bottom: 20, left: 20},
    width = tree_width - margin.right - margin.left,
    height = tree_height - margin.top - margin.bottom;

var tree = d3.layout.tree().size([height, width]);

var diagonal = d3.svg.diagonal().projection(function(d) { return [d.y, d.x]; });

var svg = d3.select("#inheritance_tree").append("svg")
    .attr("width", width + margin.right + margin.left)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var update = function (source) {
    var i = 0;
  // Compute the new tree layout.
  var nodes = tree.nodes(source).reverse(),
      links = tree.links(nodes);

  // Normalize for fixed-depth.
  nodes.forEach(function(d) { d.y = d.depth * tree_indent; });

  // Declare the nodes
  var node = svg.selectAll("g.node")
            .data(nodes, function(d) { return d.id || (d.id = ++i); });

  // Enter the nodes.
  var nodeEnter = node.enter().append("g")
    .attr("class", function(d) { return "node " + d.type; })
    .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

  nodeEnter.append("circle")
    .attr("r", 10);

  nodeEnter.append("text")
    .attr("x", 13)
//    .attr("x", function(d) { 
//        return d.children || d._children ? -13 : 13; })
    .attr("dy", ".35em")
    .attr("text-anchor", "start")
//    .attr("text-anchor", function(d) { 
//        return d.children || d._children ? "end" : "start"; })
    .text(function(d) { return d.name; })
    .style("fill-opacity", 1);

  // Declare the links…
  var link = svg.selectAll("path.link")
    .data(links, function(d) { return d.target.id; });

  // Enter the links.
  link.enter().insert("path", "g")
    .attr("class", "link")
    .attr("d", diagonal);
}

update(tree_data_json);
});