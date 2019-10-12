#!/usr/bin/python
#
# MBT 9/6/2016
#
# This module parses a hierarchical netlist output by ICC assuming a very restricted grammar.
# It finds the top-levels and then recursively expands them out in an
# CELL <hierarchical instance name>
# format.
#
# We use it for finding synchronizer flops in backend gate-level simulation.
#


import sys
import re

modules=[]
module_children={}

current_module="";

if len(sys.argv) == 2 :
    filename = sys.argv[1]
    print "// ## parsing file and traversing module hierarchy"
    with open(filename) as f:
        for line in f:
            m = re.search("module ([a-z_A-Z0-9]+)",line);
            if (m is None):
                m = re.search("^\s*([a-z_A-Z0-9]+)\s+([a-z_A-Z0-9]+)\s+\(",line);
                if not (m is None):
                    #print "adding child", m.group(1),m.group(2)
                    module_children[current_module].append([m.group(1),m.group(2)])
            else:
                current_module=m.group(1)
                #print "// Parsing module ",current_module
                modules.append(current_module)
                module_children[current_module] = [];
    f.close()

    print "// ## finding top-level module"
    # find top-level modules
    modules_copy = modules[:]   # shallow copy list
    for x in modules :
        for y in module_children[x] :
            [name, instance] = y;
            if name in modules_copy :
                modules_copy.remove(name)

print "// ## top level modules:", modules_copy
print "// ## expanding hierarchy"

def expand_hierarchy(hierarchy_string,module) :
    prefix = ((hierarchy_string + ".") if (hierarchy_string!="") else "")
    for x in module_children[module] :
        [name, instance] = x;
        if module_children.has_key(name) :
            expand_hierarchy(prefix + instance,name)
        else :
            print prefix+instance

for x in modules_copy:
    expand_hierarchy("",x)




