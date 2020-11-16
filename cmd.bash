dot -Tpng myfile.dot >myfile.png
digraph g {
rankdir="LR";
node[style="rounded",shape="box"]
edge[splines="curved"]
  init [style="rounded,filled",fillcolor="gray"]p1 -> p2 [label="go"];
p2 -> p3 [label="go"];
