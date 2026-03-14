:- use_module(library(lists)).

% ------------------------------------------------------------------
% ground_by_name(+PredSpecs, +File)
% PredSpecs: list of Name/Arity terms, e.g., [top_left/7, bottom/7]
% File: output file to write all groundings
% ------------------------------------------------------------------
ground_by_name(PredSpecs, File) :-
    open(File, write, Stream),
    forall(
        member(Name/Arity, PredSpecs),
        ground_predicate_by_name(Name, Arity, Stream)
    ),
    close(Stream).

% ------------------------------------------------------------------
% ground_predicate_by_name(+Name, +Arity, +Stream)
% Generates a fresh term with given name/arity and writes all solutions
% ------------------------------------------------------------------
ground_predicate_by_name(Name, Arity, Stream) :-
    functor(Template, Name, Arity),        % create term with fresh vars
    findall(Template, call(Template), Solutions),
    write_solutions(Solutions, Stream).

% ------------------------------------------------------------------
% write_solutions(+Solutions, +Stream)
% Writes each solution to the file
% ------------------------------------------------------------------
write_solutions([], _).
write_solutions([S|Rest], Stream) :-
    write(Stream, S),
    write(Stream, '.'),
    nl(Stream),
    write_solutions(Rest, Stream).