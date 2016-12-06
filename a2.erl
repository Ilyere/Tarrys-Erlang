-module(a2).
-compile(export_all).
	
createnodes(List) ->
	[Head | Tail] = List,
	% Head is initiator
	% Get first element in each string
	Nodenames = [lists:sublist(Id, 1, 1) || Id <- Tail],
	% Get all neighbours
	Neighbours = [lists:droplast(lists:reverse(Id)) || Id <- Tail],
	% Spawn processes for each node
	Pids = [spawn(a2, test, [Id, Id =:= Head]) || Id <- Nodenames],
	% Zip together node names and their process ids
	Nodeids = lists:zip(Nodenames, Pids),
	% Assign process ids to neighbours list
	NeighbourIds = [findneighbours(Nodeids, N) || N <- Neighbours],
	% Send messages to all nodes confirming their neighbours
	Sendstuff = [Pid ! {NeighbourId} || {Pid, NeighbourId} <- lists:zip(Pids , NeighbourIds)].
	
% Helper function to find corresponding process ids for each neighbour
findneighbours(Nodeids, Neighbours) ->
	Out = lists:foldl(fun(X, Acc) -> 
		{Y, Z} = X,
		case lists:member(Y, string:tokens(Neighbours, " ")) 
			of true -> 
				lists:append(Acc, [Z]);
			false ->
				Acc end end, [], Nodeids).
	
% Test function to print out confirmation of node connections
test(Id, Flag) ->
	receive
		{X} ->
			io:format("Node ~p got: ~p, is initiator ~s~n", [self(), X, Flag]),
			tarrys(Id, X, Flag);
		X ->             
			io:format("Node ~p got bad message: ~p~n", [self(), X])
	end.

% Tarrys algorithm follows two rules
% A process never forwards a token through the same channel twice
% A process only forwards a token to its parent when there is no other option
tarrys(Nodeid, Neighbourids, Initiatorflag) ->
	% Permute neighbours
	Perms = [X||{_,X} <- lists:sort([ {rand:uniform(), N} || N <- Neighbourids])],
	io:format("~c~n", Nodeid).
	%if Initiatorflag ->
	%	Token = [Nodeid],
	% 	(Head | Tail) = Perms,
	%	Head ! Token
				
	%receive ->
	%	Newtoken = lists:append(Token, Nodeid),
	%Parent - pop off last item in token
	%Already sent to: List comprehension
	
	%do stuff
	
% Begin execution by calling main()
main() ->
	% Hard-coded for now,
    File = "input.txt",
    {ok, Bin} = file:read_file(File),
	List = string:tokens(binary_to_list(Bin), "\r\n"), %Windows only
    %List = string:tokens(In, "\n"), %Linux only
	createnodes(List).
	
%spawn/3 is module-function-argumentlist form
%foldl is function-accumulator-argumentlist form
%receiver ! itembeingsent