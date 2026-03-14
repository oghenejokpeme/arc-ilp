max_vars(6).
max_body(6).
head_pred(out_state, 4).
type(out_state, (ex, row_id, col_id, color)).

body_pred(in_state, 4).
type(in_state, (ex, row_id, col_id, color)).

body_pred(adj, 5).
body_pred(diag, 5).
body_pred(is_top_edge, 3).
body_pred(is_bottom_edge, 3).
body_pred(is_left_edge, 3).
body_pred(is_right_edge, 3).
body_pred(corner, 3).
body_pred(is_center, 3).
body_pred(on_main_diagonal, 3).
body_pred(on_anti_diagonal, 3).
body_pred(same_main_diagonal, 5).
body_pred(same_anti_diagonal, 5).
body_pred(even_row, 2).
body_pred(odd_row, 2).
body_pred(even_col, 2).
body_pred(odd_col, 2).
body_pred(above, 3).
body_pred(left_of, 3).
body_pred(complement_row, 3).
body_pred(complement_col, 3).
body_pred(transpose_color, 4).
body_pred(bg, 2).
body_pred(foreground, 3).
body_pred(minority_color, 2).
body_pred(obj_id, 4).
body_pred(row_color_count, 4).
body_pred(col_color_count, 4).
body_pred(color_count, 3).
body_pred(row_distinct_count, 3).
body_pred(col_distinct_count, 3).
body_pred(foreground_count_in_row, 3).
body_pred(foreground_count_in_col, 3).
body_pred(most_common_in_row, 3).
body_pred(most_common_in_col, 3).
body_pred(minority_color_in_row, 3).
body_pred(minority_color_in_col, 3).
body_pred(unique_in_row, 3).
body_pred(unique_in_col, 3).
body_pred(unique_in_grid, 3).
body_pred(uniform_row, 3).
body_pred(uniform_col, 3).
body_pred(same_row_content, 3).
body_pred(same_col_content, 3).
body_pred(rows_same_color_set, 3).
body_pred(row_symmetric, 2).
body_pred(col_symmetric, 2).
body_pred(row_signal_color, 3).
body_pred(col_signal_color, 3).
body_pred(same_color_adj_count, 4).
body_pred(count_neighbors_same_color, 4).
body_pred(count_neighbors_with_color, 5).
body_pred(object_border_cell, 3).
body_pred(between_horizontal, 4).
body_pred(between_vertical, 4).
body_pred(between_main_diagonal, 4).
body_pred(between_anti_diagonal, 4).
body_pred(orthogonally_surrounded_by, 4).
body_pred(fully_surrounded_by, 4).
body_pred(enclosed_by, 4).
body_pred(nearest_color_top, 5).
body_pred(nearest_color_down, 5).
body_pred(nearest_color_left, 5).
body_pred(nearest_color_right, 5).
body_pred(h_run_start, 4).
body_pred(h_run_end, 4).
body_pred(v_run_start, 4).
body_pred(v_run_end, 4).
body_pred(run_length_h, 5).
body_pred(run_length_v, 5).

type(adj, (ex, row_id, col_id, row_id, col_id)).
type(diag, (ex, row_id, col_id, row_id, col_id)).
type(is_top_edge, (ex, row_id, col_id)).
type(is_bottom_edge, (ex, row_id, col_id)).
type(is_left_edge, (ex, row_id, col_id)).
type(is_right_edge, (ex, row_id, col_id)).
type(corner, (ex, row_id, col_id)).
type(is_center, (ex, row_id, col_id)).
type(on_main_diagonal, (ex, row_id, col_id)).
type(on_anti_diagonal, (ex, row_id, col_id)).
type(same_main_diagonal, (ex, row_id, col_id, row_id, col_id)).
type(same_anti_diagonal, (ex, row_id, col_id, row_id, col_id)).
type(even_row, (ex, row_id)).
type(odd_row, (ex, row_id)).
type(even_col, (ex, col_id)).
type(odd_col, (ex, col_id)).
type(above, (ex, row_id, row_id)).
type(left_of, (ex, col_id, col_id)).
type(complement_row, (ex, row_id, row_id)).
type(complement_col, (ex, col_id, col_id)).
type(transpose_color, (ex, row_id, col_id, color)).
type(bg, (ex, color)).
type(foreground, (ex, row_id, col_id)).
type(minority_color, (ex, color)).
type(obj_id, (ex, row_id, col_id, obj_id)).
type(row_color_count, (ex, row_id, color, count)).
type(col_color_count, (ex, col_id, color, count)).
type(color_count, (ex, color, count)).
type(row_distinct_count, (ex, row_id, count)).
type(col_distinct_count, (ex, col_id, count)).
type(foreground_count_in_row, (ex, row_id, count)).
type(foreground_count_in_col, (ex, col_id, count)).
type(most_common_in_row, (ex, row_id, color)).
type(most_common_in_col, (ex, col_id, color)).
type(minority_color_in_row, (ex, row_id, color)).
type(minority_color_in_col, (ex, col_id, color)).
type(unique_in_row, (ex, row_id, col_id)).
type(unique_in_col, (ex, row_id, col_id)).
type(unique_in_grid, (ex, row_id, col_id)).
type(uniform_row, (ex, row_id, color)).
type(uniform_col, (ex, col_id, color)).
type(same_row_content, (ex, row_id, row_id)).
type(same_col_content, (ex, col_id, col_id)).
type(rows_same_color_set, (ex, row_id, row_id)).
type(row_symmetric, (ex, row_id)).
type(col_symmetric, (ex, col_id)).
type(row_signal_color, (ex, row_id, color)).
type(col_signal_color, (ex, col_id, color)).
type(same_color_adj_count, (ex, row_id, col_id, count)).
type(count_neighbors_same_color, (ex, row_id, col_id, count)).
type(count_neighbors_with_color, (ex, row_id, col_id, color, count)).
type(object_border_cell, (ex, row_id, col_id)).
type(between_horizontal, (ex, row_id, col_id, color)).
type(between_vertical, (ex, row_id, col_id, color)).
type(between_main_diagonal, (ex, row_id, col_id, color)).
type(between_anti_diagonal, (ex, row_id, col_id, color)).
type(orthogonally_surrounded_by, (ex, row_id, col_id, color)).
type(fully_surrounded_by, (ex, row_id, col_id, color)).
type(enclosed_by, (ex, row_id, col_id, color)).
type(nearest_color_top, (ex, row_id, col_id, color, row_id)).
type(nearest_color_down, (ex, row_id, col_id, color, row_id)).
type(nearest_color_left, (ex, row_id, col_id, color, col_id)).
type(nearest_color_right, (ex, row_id, col_id, color, col_id)).
type(h_run_start, (ex, row_id, col_id, color)).
type(h_run_end, (ex, row_id, col_id, color)).
type(v_run_start, (ex, row_id, col_id, color)).
type(v_run_end, (ex, row_id, col_id, color)).
type(run_length_h, (ex, row_id, col_id, color, length)).
type(run_length_v, (ex, row_id, col_id, color, length)).
body_pred(black, 1).
body_pred(blue, 1).
body_pred(red, 1).
body_pred(green, 1).
body_pred(yellow, 1).
body_pred(gray, 1).
body_pred(pink, 1).
body_pred(orange, 1).
body_pred(aqua, 1).
body_pred(maroon, 1).

type(black, (color,)).
type(blue, (color,)).
type(red, (color,)).
type(green, (color,)).
type(yellow, (color,)).
type(gray, (color,)).
type(pink, (color,)).
type(orange, (color,)).
type(aqua, (color,)).
type(maroon, (color,)).

%% BECAUSE WE DO NOT LEARN FROM INTERPRETATIONS
:-
    clause(C),
    #count{V : var_type(C,V,ex)} != 1.

