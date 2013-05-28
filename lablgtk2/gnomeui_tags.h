/* edge_position : tags and macros */
#define MLTAG_START	((value)(33139778*2+1))
#define MLTAG_FINISH	((value)(956427347*2+1))
#define MLTAG_OTHER	((value)(879009456*2+1))

extern const lookup_info ml_table_edge_position[];
#define Val_edge_position(data) ml_lookup_from_c (ml_table_edge_position, data)
#define Edge_position_val(key) ml_lookup_to_c (ml_table_edge_position, key)

