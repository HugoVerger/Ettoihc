/* source_search_flag : tags and macros */
#define MLTAG_VISIBLE_ONLY	((value)(-365153351*2+1))
#define MLTAG_TEXT_ONLY	((value)(-357645954*2+1))
#define MLTAG_CASE_INSENSITIVE	((value)(113105954*2+1))

extern const lookup_info ml_table_source_search_flag[];
#define Val_source_search_flag(data) ml_lookup_from_c (ml_table_source_search_flag, data)
#define Source_search_flag_val(key) ml_lookup_to_c (ml_table_source_search_flag, key)

