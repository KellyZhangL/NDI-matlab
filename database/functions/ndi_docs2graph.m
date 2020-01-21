function [G,nodes,mdigraph] = ndi_docs2graph(ndi_document_obj)
% NDI_DOCS2GRAPH - create a directed graph from a cell array of NDI_DOCUMENT objects
% 
% [G,NODES,MDIGRAPH] = NDI_DOCS2GRAPH(NDI_DOCUMENT_OBJ)
%
% Given a cell array of NDI_DOCUMENT objects, this function creates a directed graph with the 
% 'depends_on' relationships. If an object A 'depends on' another object B, there will be an edge from B to A.
% The adjacency matrix G, the node names (document ids) NODES, and the Matlab directed graph object MDIGRAPH are
% all returned.
%
% See also: DIGRAPH
%
%

nodes = {};

for i=1:numel(ndi_document_obj),
	nodes{i} = ndi_document_obj{i}.document_properties.ndi_document.id;
end;

 % now we have all the nodes, build adjacency matrix

G = sparse(numel(nodes),numel(nodes));

for i=1:numel(ndi_document_obj),
	here = i;
	if isfield(ndi_document_obj{i}.document_properties,'depends_on'),
		for j=1:numel(ndi_document_obj{i}.document_properties.depends_on),
			there = find(strcmp(ndi_document_obj{i}.document_properties.depends_on(j).value, nodes));
			G(here,there) = 1;
		end;
	end;
end;

mdigraph = digraph(G, nodes);


