:- table max_row/2.
:- table max_col/2.
:- table bg/2.
:- table minority_color/2.
:- table row_color_count/4.
:- table col_color_count/4.
:- table color_count/3.
:- table row_distinct_count/3.
:- table col_distinct_count/3.
:- table most_common_in_row/3.
:- table most_common_in_col/3.
:- table minority_color_in_row/3.
:- table minority_color_in_col/3.
:- table foreground_count_in_row/3.
:- table foreground_count_in_col/3.
:- table row_symmetric/2.
:- table col_symmetric/2.
:- table row_signal_color/3.
:- table col_signal_color/3.
:- table rows_same_color_set/3.
:- table count_neighbors_same_color/4.
:- table count_neighbors_with_color/5.
:- table connected/5.
:- table h_run_start_/5.
:- table h_run_end_/5.
:- table v_run_start_/5.
:- table v_run_end_/5.
:- table nearest_color_top/5.
:- table nearest_color_down/5.
:- table nearest_color_left/5.
:- table nearest_color_right/5.
:- table even_row/2.
:- table odd_row/2.
:- table even_col/2.
:- table odd_col/2.

max_row(Example, MR) :-
    in_state(Example, _, _, _),
    aggregate_all(max(R), in_state(Example, R, _, _), MR).

max_col(Example, MC) :-
    in_state(Example, _, _, _),
    aggregate_all(max(C), in_state(Example, _, C, _), MC).

connected(Example, R1, C1, R2, C2) :-
    foreground(Example, R1, C1),
    foreground(Example, R2, C2),
    in_state(Example, R1, C1, V),
    in_state(Example, R2, C2, V),
    adj(Example, R1, C1, R2, C2).
connected(Example, R1, C1, R2, C2) :-
    connected(Example, R1, C1, RM, CM),
    in_state(Example, R1, C1, V),
    in_state(Example, R2, C2, V),
    adj(Example, RM, CM, R2, C2),
    foreground(Example, R2, C2).

h_run_start_(Example, R, C, Color, C) :-
    in_state(Example, R, C, Color),
    LC is C - 1,
    \+ in_state(Example, R, LC, Color).
h_run_start_(Example, R, C, Color, Start) :-
    in_state(Example, R, C, Color),
    LC is C - 1,
    in_state(Example, R, LC, Color),
    h_run_start_(Example, R, LC, Color, Start).

h_run_end_(Example, R, C, Color, C) :-
    in_state(Example, R, C, Color),
    RC is C + 1,
    \+ in_state(Example, R, RC, Color).
h_run_end_(Example, R, C, Color, End) :-
    in_state(Example, R, C, Color),
    RC is C + 1,
    in_state(Example, R, RC, Color),
    h_run_end_(Example, R, RC, Color, End).

v_run_start_(Example, R, C, Color, R) :-
    in_state(Example, R, C, Color),
    UR is R - 1,
    \+ in_state(Example, UR, C, Color).
v_run_start_(Example, R, C, Color, Start) :-
    in_state(Example, R, C, Color),
    UR is R - 1,
    in_state(Example, UR, C, Color),
    v_run_start_(Example, UR, C, Color, Start).

v_run_end_(Example, R, C, Color, R) :-
    in_state(Example, R, C, Color),
    DR is R + 1,
    \+ in_state(Example, DR, C, Color).
v_run_end_(Example, R, C, Color, End) :-
    in_state(Example, R, C, Color),
    DR is R + 1,
    in_state(Example, DR, C, Color),
    v_run_end_(Example, DR, C, Color, End).

%%  1. adj/5 — orthogonal adjacency (4-connectivity)
adj(Example, R, C, NR, C) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, C, _),
    NR is R + 1.
adj(Example, R, C, NR, C) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, C, _),
    NR is R - 1.
adj(Example, R, C, R, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, R, NC, _),
    NC is C + 1.
adj(Example, R, C, R, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, R, NC, _),
    NC is C - 1.

%%  2. diag/5 — diagonal adjacency (4 diagonal directions)
diag(Example, R, C, NR, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, NC, _),
    NR is R + 1, NC is C + 1.
diag(Example, R, C, NR, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, NC, _),
    NR is R + 1, NC is C - 1.
diag(Example, R, C, NR, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, NC, _),
    NR is R - 1, NC is C + 1.
diag(Example, R, C, NR, NC) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R, C, _),
    in_state(Example, NR, NC, _),
    NR is R - 1, NC is C - 1.

%%  3. is_top_edge/3 — cell on top row
is_top_edge(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    R =:= 0.

%%  4. is_bottom_edge/3 — cell on bottom row
is_bottom_edge(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    max_row(Example, R).

%%  5. is_left_edge/3 — cell on leftmost column
is_left_edge(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    C =:= 0.

%%  6. is_right_edge/3 — cell on rightmost column
is_right_edge(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    max_col(Example, C).

%%  7. corner/3 — cell on two borders simultaneously
corner(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    (R =:= 0 ; max_row(Example, R)),
    (C =:= 0 ; max_col(Example, C)).

%%  8. is_center/3 — cell not on any border
is_center(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    R > 0,
    C > 0,
    max_row(Example, MR), R < MR,
    max_col(Example, MC), C < MC.

%%  9. on_main_diagonal/3 — cell where row equals column
on_main_diagonal(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    R =:= C.

%% 10. on_anti_diagonal/3 — cell where R + C equals max index
on_anti_diagonal(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, _),
    max_col(Example, MC),
    R + C =:= MC.

%% 11. same_main_diagonal/5 — two cells on same \ diagonal
same_main_diagonal(Example, R1, C1, R2, C2) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R1, C1, _),
    in_state(Example, R2, C2, _),
    (R1 \= R2 ; C1 \= C2),
    R1 - C1 =:= R2 - C2.

%% 12. same_anti_diagonal/5 — two cells on same / diagonal
same_anti_diagonal(Example, R1, C1, R2, C2) :- % ex, row_id, col_id, row_id, col_id
    in_state(Example, R1, C1, _),
    in_state(Example, R2, C2, _),
    (R1 \= R2 ; C1 \= C2),
    R1 + C1 =:= R2 + C2.

%% 13. even_row/2 — row index is even (0, 2, 4, ...)
even_row(Example, R) :- % ex, row_id
    in_state(Example, R, _, _),
    R =:= 0.
even_row(Example, R) :- % ex, row_id
    in_state(Example, R, _, _),
    R2 is R - 2,
    R2 >= 0,
    even_row(Example, R2).

%% 14. odd_row/2 — row index is odd (1, 3, 5, ...)
odd_row(Example, R) :- % ex, row_id
    in_state(Example, R, _, _),
    R =:= 1.
odd_row(Example, R) :- % ex, row_id
    in_state(Example, R, _, _),
    R2 is R - 2,
    R2 >= 0,
    odd_row(Example, R2).

%% 15. even_col/2 — column index is even (0, 2, 4, ...)
even_col(Example, C) :- % ex, col_id
    in_state(Example, _, C, _),
    C =:= 0.
even_col(Example, C) :- % ex, col_id
    in_state(Example, _, C, _),
    C2 is C - 2,
    C2 >= 0,
    even_col(Example, C2).

%% 16. odd_col/2 — column index is odd (1, 3, 5, ...)
odd_col(Example, C) :- % ex, col_id
    in_state(Example, _, C, _),
    C =:= 1.
odd_col(Example, C) :- % ex, col_id
    in_state(Example, _, C, _),
    C2 is C - 2,
    C2 >= 0,
    odd_col(Example, C2).

%% 17. above/3 — R1 is strictly above R2 (R1 < R2)
above(Example, R1, R2) :- % ex, row_id, row_id
    setof(R, C^V^in_state(Example, R, C, V), Rows),
    member(R1, Rows),
    member(R2, Rows),
    R1 < R2.

%% 18. left_of/3 — C1 is strictly left of C2 (C1 < C2)
left_of(Example, C1, C2) :- % ex, col_id, col_id
    setof(C, R^V^in_state(Example, R, C, V), Cols),
    member(C1, Cols),
    member(C2, Cols),
    C1 < C2.

%% 19. complement_row/3 — horizontal reflection pairing
%%     R2 is the mirror of R1 about the horizontal axis.
complement_row(Example, R1, R2) :- % ex, row_id, row_id
    in_state(Example, R1, _, _),
    max_row(Example, MR),
    R2 is MR - R1,
    in_state(Example, R2, _, _).

%% 20. complement_col/3 — vertical reflection pairing
%%     C2 is the mirror of C1 about the vertical axis.
complement_col(Example, C1, C2) :- % ex, col_id, col_id
    in_state(Example, _, C1, _),
    max_col(Example, MC),
    C2 is MC - C1,
    in_state(Example, _, C2, _).

%% 21. transpose_color/4 — color at transposed position (R,C -> C,R)
%%     Genuinely new mapping not derivable from complement_row/col.
%%     Only produces facts where both (R,C) and (C,R) exist.
transpose_color(Example, R, C, TColor) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    in_state(Example, C, R, TColor).

%% 22. bg/2 — background color (most frequent input color)
bg(Example, V) :- % ex, color
    in_state(Example, _, _, _),
    aggregate_all(bag(Color), in_state(Example, _, _, Color), Bag),
    msort(Bag, Sorted),
    clumped(Sorted, Pairs),
    pairs_values(Pairs, Counts),
    max_list(Counts, Max),
    member(V-Max, Pairs).

%% 23. foreground/3 — cell is not background color
foreground(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, V),
    bg(Example, BG),
    V \= BG.

%% 24. minority_color/2 — rarest color in the grid globally
%%     Engine cannot compute argmin over counts.
minority_color(Example, Color) :- % ex, color
    color_count(Example, Color, Count),
    \+ (color_count(Example, Other, OCount),
        Other \= Color,
        OCount < Count).

%% 25. obj_id/4 — 4-connected same-color foreground component label
%%     O is the minimum row-major index of any cell in the component.
%%     Deterministic: same component always gets same label.
%%     Requires connected/5 (tabled) to be available.
obj_id(Example, R, C, O) :- % ex, row_id, col_id, obj_id
    foreground(Example, R, C),
    max_col(Example, MC),
    Width is MC + 1,
    aggregate_all(min(Enc),
        (   (R2 = R, C2 = C ; connected(Example, R, C, R2, C2)),
            Enc is R2 * Width + C2
        ),
        O).

%% 26. row_color_count/4 — count of color V in row R
row_color_count(Example, R, V, N) :- % ex, row_id, color, count
    in_state(Example, R, _, V),
    aggregate_all(count, in_state(Example, R, _, V), N).

%% 27. col_color_count/4 — count of color V in column C
col_color_count(Example, C, V, N) :- % ex, col_id, color, count
    in_state(Example, _, C, V),
    aggregate_all(count, in_state(Example, _, C, V), N).

%% 28. color_count/3 — total occurrences of color in the grid
color_count(Example, V, N) :- % ex, color, count
    in_state(Example, _, _, V),
    aggregate_all(count, in_state(Example, _, _, V), N).

%% 29. row_distinct_count/3 — number of distinct colors in row
row_distinct_count(Example, R, N) :- % ex, row_id, count
    in_state(Example, R, _, _),
    aggregate_all(set(V), in_state(Example, R, _, V), Colors),
    length(Colors, N).

%% 30. col_distinct_count/3 — number of distinct colors in column
col_distinct_count(Example, C, N) :- % ex, col_id, count
    in_state(Example, _, C, _),
    aggregate_all(set(V), in_state(Example, _, C, V), Colors),
    length(Colors, N).

%% 31. foreground_count_in_row/3 — number of non-bg cells in row
%%     Engine cannot count with inequality filter.
foreground_count_in_row(Example, R, N) :- % ex, row_id, count
    in_state(Example, R, _, _),
    bg(Example, BG),
    aggregate_all(count,
        (in_state(Example, R, _, V), V \= BG),
        N).

%% 32. foreground_count_in_col/3 — number of non-bg cells in column
foreground_count_in_col(Example, C, N) :- % ex, col_id, count
    in_state(Example, _, C, _),
    bg(Example, BG),
    aggregate_all(count,
        (in_state(Example, _, C, V), V \= BG),
        N).

%% 33. most_common_in_row/3 — dominant color in row
most_common_in_row(Example, R, V) :- % ex, row_id, color
    in_state(Example, R, _, _),
    aggregate_all(max(N, V2),
        row_color_count(Example, R, V2, N),
        max(_, V)).

%% 34. most_common_in_col/3 — dominant color in column
most_common_in_col(Example, C, V) :- % ex, col_id, color
    in_state(Example, _, C, _),
    aggregate_all(max(N, V2),
        col_color_count(Example, C, V2, N),
        max(_, V)).

%% 35. minority_color_in_row/3 — least common color in row
%%     Engine cannot compute argmin.
minority_color_in_row(Example, R, Color) :- % ex, row_id, color
    row_color_count(Example, R, Color, Count),
    \+ (row_color_count(Example, R, Other, OCount),
        Other \= Color,
        OCount < Count).

%% 36. minority_color_in_col/3 — least common color in column
minority_color_in_col(Example, C, Color) :- % ex, col_id, color
    col_color_count(Example, C, Color, Count),
    \+ (col_color_count(Example, C, Other, OCount),
        Other \= Color,
        OCount < Count).

%% 37. unique_in_row/3 — cell whose color appears exactly once in its row
unique_in_row(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, V),
    row_color_count(Example, R, V, 1).

%% 38. unique_in_col/3 — cell whose color appears exactly once in its column
unique_in_col(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, V),
    col_color_count(Example, C, V, 1).

%% 39. unique_in_grid/3 — cell whose color appears exactly once in the grid
unique_in_grid(Example, R, C) :- % ex, row_id, col_id
    in_state(Example, R, C, V),
    color_count(Example, V, 1).

%% 40. uniform_row/3 — every cell in row has the same color
uniform_row(Example, R, V) :- % ex, row_id, color
    in_state(Example, R, _, V),
    \+ (in_state(Example, R, _, V2), V2 \= V).

%% 41. uniform_col/3 — every cell in column has the same color
uniform_col(Example, C, V) :- % ex, col_id, color
    in_state(Example, _, C, V),
    \+ (in_state(Example, _, C, V2), V2 \= V).

%% 42. same_row_content/3 — two rows with identical color sequences
%%     Engine cannot derive universal pairwise equality across columns.
same_row_content(Example, R1, R2) :- % ex, row_id, row_id
    in_state(Example, R1, _, _),
    in_state(Example, R2, _, _),
    R1 \= R2,
    \+ (in_state(Example, R1, C, V1),
        in_state(Example, R2, C, V2),
        V1 \= V2).

%% 43. same_col_content/3 — two columns with identical color sequences
same_col_content(Example, C1, C2) :- % ex, col_id, col_id
    in_state(Example, _, C1, _),
    in_state(Example, _, C2, _),
    C1 \= C2,
    \+ (in_state(Example, R, C1, V1),
        in_state(Example, R, C2, V2),
        V1 \= V2).

%% 44. rows_same_color_set/3 — two rows with identical color multisets
%%     Differs from same_row_content: {1,2,1} matches {2,1,1}.
%%     Detects permuted/reordered rows.
rows_same_color_set(Example, R1, R2) :- % ex, row_id, row_id
    in_state(Example, R1, _, _),
    in_state(Example, R2, _, _),
    R1 \= R2,
    findall(Color, in_state(Example, R1, _, Color), C1s),
    findall(Color, in_state(Example, R2, _, Color), C2s),
    msort(C1s, Sorted),
    msort(C2s, Sorted).

%% 45. row_symmetric/2 — row is a palindrome (color sequence)
%%     Engine cannot derive universal mirror equality.
row_symmetric(Example, R) :- % ex, row_id
    in_state(Example, R, _, _),
    max_col(Example, MC),
    \+ (in_state(Example, R, C, Color),
        MirrorC is MC - C,
        in_state(Example, R, MirrorC, Other),
        Color \= Other).

%% 46. col_symmetric/2 — column is a palindrome (color sequence)
col_symmetric(Example, C) :- % ex, col_id
    in_state(Example, _, C, _),
    max_row(Example, MR),
    \+ (in_state(Example, R, C, Color),
        MirrorR is MR - R,
        in_state(Example, MirrorR, C, Other),
        Color \= Other).

%% 47. row_signal_color/3 — the single non-background color in a row
%%     Detects "key" or "marker" rows with exactly one foreground color.
%%     Engine cannot derive "exactly one distinct non-bg color."
row_signal_color(Example, R, Color) :- % ex, row_id, color
    bg(Example, BG),
    in_state(Example, R, _, Color),
    Color \= BG,
    \+ (in_state(Example, R, _, Other), Other \= BG, Other \= Color).

%% 48. col_signal_color/3 — the single non-background color in a column
col_signal_color(Example, C, Color) :- % ex, col_id, color
    bg(Example, BG),
    in_state(Example, _, C, Color),
    Color \= BG,
    \+ (in_state(Example, _, C, Other), Other \= BG, Other \= Color).

%% 49. same_color_adj_count/4 — orthogonal (4-connected) neighbors
%%     with the same color as the cell.
%%     0=isolated, 1=endpoint, 2=line/corner, 3=T-junction, 4=interior
same_color_adj_count(Example, R, C, N) :- % ex, row_id, col_id, count
    in_state(Example, R, C, V),
    aggregate_all(count,
        (adj(Example, R, C, NR, NC), in_state(Example, NR, NC, V)),
        N).

%% 50. count_neighbors_same_color/4 — 8-connected neighbors with same color
%%     Uses adj + diag instead of abs for 8-connectivity.
count_neighbors_same_color(Example, R, C, Count) :- % ex, row_id, col_id, count
    in_state(Example, R, C, Color),
    aggregate_all(count,
        (   (adj(Example, R, C, NR, NC) ; diag(Example, R, C, NR, NC)),
            in_state(Example, NR, NC, Color)
        ),
        Count).

%% 51. count_neighbors_with_color/5 — 8-connected neighbors with
%%     a specific color (not necessarily the cell's own color).
%%     Uses adj + diag instead of abs for 8-connectivity.
count_neighbors_with_color(Example, R, C, Color, Count) :- % ex, row_id, col_id, color, count
    in_state(Example, R, C, _),
    in_state(Example, _, _, Color),
    aggregate_all(count,
        (   (adj(Example, R, C, NR, NC) ; diag(Example, R, C, NR, NC)),
            in_state(Example, NR, NC, Color)
        ),
        Count).

%% 52. object_border_cell/3 — foreground cell adjacent to a cell
%%     of different color or to the grid boundary.
%%     Identifies the perimeter of objects.
object_border_cell(Example, R, C) :- % ex, row_id, col_id
    foreground(Example, R, C),
    in_state(Example, R, C, Color),
    adj(Example, R, C, NR, NC),
    in_state(Example, NR, NC, NColor),
    NColor \= Color.
object_border_cell(Example, R, C) :- % ex, row_id, col_id
    foreground(Example, R, C),
    is_top_edge(Example, R, C).
object_border_cell(Example, R, C) :- % ex, row_id, col_id
    foreground(Example, R, C),
    is_bottom_edge(Example, R, C).
object_border_cell(Example, R, C) :- % ex, row_id, col_id
    foreground(Example, R, C),
    is_left_edge(Example, R, C).
object_border_cell(Example, R, C) :- % ex, row_id, col_id
    foreground(Example, R, C),
    is_right_edge(Example, R, C).

%% 57. between_horizontal/4 — cell is between two cells of Color
%%     in the same row.
between_horizontal(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    in_state(Example, R, C1, Color),
    in_state(Example, R, C2, Color),
    C1 < C,
    C < C2.

%% 58. between_vertical/4 — cell is between two cells of Color
%%     in the same column.
between_vertical(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    in_state(Example, R1, C, Color),
    in_state(Example, R2, C, Color),
    R1 < R,
    R < R2.

%% 59. between_main_diagonal/4 — cell is between two cells of Color
%%     along the same \ diagonal.
between_main_diagonal(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    in_state(Example, R1, C1, Color),
    in_state(Example, R2, C2, Color),
    R1 - C1 =:= R - C,
    R2 - C2 =:= R - C,
    R1 < R,
    R < R2.

%% 60. between_anti_diagonal/4 — cell is between two cells of Color
%%     along the same / diagonal.
between_anti_diagonal(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    in_state(Example, R1, C1, Color),
    in_state(Example, R2, C2, Color),
    R1 + C1 =:= R + C,
    R2 + C2 =:= R + C,
    R1 < R,
    R < R2.

%% 61. orthogonally_surrounded_by/4 — all 4 orthogonal neighbors
%%     have the specified color.
orthogonally_surrounded_by(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    TR is R - 1, in_state(Example, TR, C, Color),
    BR is R + 1, in_state(Example, BR, C, Color),
    LC is C - 1, in_state(Example, R, LC, Color),
    RC is C + 1, in_state(Example, R, RC, Color).

%% 62. fully_surrounded_by/4 — all 8 neighbors have the specified color.
%%     Different from orthogonal: includes diagonals.
%%     Uses adj + diag instead of abs for 8-connectivity.
fully_surrounded_by(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    (   adj(Example, R, C, NR0, NC0), in_state(Example, NR0, NC0, Color)
    ;   diag(Example, R, C, NR0, NC0), in_state(Example, NR0, NC0, Color)
    ),
    \+ (   (adj(Example, R, C, NR, NC) ; diag(Example, R, C, NR, NC)),
           in_state(Example, NR, NC, OtherColor),
           OtherColor \= Color
       ).

%% 63. enclosed_by/4 — nearest cell in each cardinal direction
%%     has the specified color (ray-cast enclosure).
%%     More powerful than orthogonally_surrounded_by: the enclosing
%%     cells need not be immediate neighbors.
enclosed_by(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, _),
    nearest_color_top(Example, R, C, Color, _),
    nearest_color_down(Example, R, C, Color, _),
    nearest_color_left(Example, R, C, Color, _),
    nearest_color_right(Example, R, C, Color, _).

%% 64–67. nearest_color_*/5 — nearest cell of a given color in
%%         each cardinal direction. Engine cannot compute "nearest."
nearest_color_top(Example, R, C, Color, NR) :- % ex, row_id, col_id, color, row_id
    in_state(Example, R, C, _),
    in_state(Example, NR, C, Color),
    NR < R,
    \+ (in_state(Example, Mid, C, Color), Mid > NR, Mid < R).

nearest_color_down(Example, R, C, Color, NR) :- % ex, row_id, col_id, color, row_id
    in_state(Example, R, C, _),
    in_state(Example, NR, C, Color),
    NR > R,
    \+ (in_state(Example, Mid, C, Color), Mid < NR, Mid > R).

nearest_color_left(Example, R, C, Color, NC) :- % ex, row_id, col_id, color, col_id
    in_state(Example, R, C, _),
    in_state(Example, R, NC, Color),
    NC < C,
    \+ (in_state(Example, R, Mid, Color), Mid > NC, Mid < C).

nearest_color_right(Example, R, C, Color, NC) :- % ex, row_id, col_id, color, col_id
    in_state(Example, R, C, _),
    in_state(Example, R, NC, Color),
    NC > C,
    \+ (in_state(Example, R, Mid, Color), Mid < NC, Mid > C).

%% 68. h_run_start/4 — cell is the leftmost cell of a horizontal
%%     run of its color (no same-color cell to its left).
h_run_start(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, Color),
    LC is C - 1,
    \+ in_state(Example, R, LC, Color).

%% 69. h_run_end/4 — cell is the rightmost cell of a horizontal
%%     run of its color.
h_run_end(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, Color),
    RC is C + 1,
    \+ in_state(Example, R, RC, Color).

%% 70. v_run_start/4 — cell is the topmost cell of a vertical
%%     run of its color.
v_run_start(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, Color),
    UR is R - 1,
    \+ in_state(Example, UR, C, Color).

%% 71. v_run_end/4 — cell is the bottommost cell of a vertical
%%     run of its color.
v_run_end(Example, R, C, Color) :- % ex, row_id, col_id, color
    in_state(Example, R, C, Color),
    DR is R + 1,
    \+ in_state(Example, DR, C, Color).

%% 72. run_length_h/5 — length of horizontal run through cell.
%%     Uses recursive helpers (tabled) to find true start and end.
run_length_h(Example, R, C, Color, Len) :- % ex, row_id, col_id, color, length
    in_state(Example, R, C, Color),
    h_run_start_(Example, R, C, Color, Start),
    h_run_end_(Example, R, C, Color, End),
    Len is End - Start + 1.

%% 73. run_length_v/5 — length of vertical run through cell.
run_length_v(Example, R, C, Color, Len) :- % ex, row_id, col_id, color, length
    in_state(Example, R, C, Color),
    v_run_start_(Example, R, C, Color, Start),
    v_run_end_(Example, R, C, Color, End),
    Len is End - Start + 1.


