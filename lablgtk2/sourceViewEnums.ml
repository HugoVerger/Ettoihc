(** sourceView enums *)

open Gpointer

type source_search_flag = [ `VISIBLE_ONLY | `TEXT_ONLY | `CASE_INSENSITIVE ]

(**/**)

external _get_tables : unit ->
    source_search_flag variant_table
  = "ml_source_view_get_tables"


let source_search_flag = _get_tables ()

let source_search_flag_conv = Gobject.Data.enum source_search_flag
