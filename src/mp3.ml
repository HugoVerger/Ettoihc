let chop_whitespace str from =
  let i = ref (String.length str) in
  while !i > from &&
        (let c = str.[!i-1] in c = '\000' || c = ' ' || c = '\t')
  do decr i done;
  String.sub str from (!i - from)

module Id3v1 = struct

  type tag = { 
      mutable title: string; 
      mutable artist: string; 
      mutable album: string;
      mutable year:string; 
      mutable comment: string; 
      mutable tracknum: int; 
      mutable genre: int }

  let read_channel ic =
    let len = in_channel_length ic in
    if len < 128 then raise Not_found;
    seek_in ic (len - 128);
    let readstring len =
      let buf = String.create len in
      really_input ic buf 0 len;
      chop_whitespace buf 0 in
    if readstring 3 <> "TAG" then raise Not_found;
    let title = readstring 30 in
    let artist = readstring 30 in
    let album = readstring 30 in
    let year = readstring 4 in
    let comment = readstring 29 in
    let tracknum = input_byte ic in
    let genre = input_byte ic in
    { title = title; artist = artist; album = album; year = year;
      comment = comment; tracknum = tracknum; genre = genre }

  let read_file filename =
    let ic = open_in_bin filename in
    try
      let res = read_channel ic in
      close_in ic; res
    with x ->
      close_in ic; raise x

  let has_tag filename =
    let ic = open_in_bin filename in
    let len = in_channel_length ic in
    let res =
      if len < 128 then false else begin
        seek_in ic (len - 128);
        let buffer = String.create 3 in
        really_input ic buffer 0 3;
        buffer = "TAG"
      end in
    close_in ic;
    res

  let write_file filename tag =
    let oc = open_out_gen [Open_wronly; Open_binary] 0o666 filename in
    try
      let len = out_channel_length oc in
      if has_tag filename
      then seek_out oc (len - 128)
      else seek_out oc len;
      let put s len =
        let l = String.length s in
        for i = 0 to min l len - 1 do output_char oc s.[i] done;
        for i = l to len - 1 do output_byte oc 0 done in
      output_string oc "TAG";
      put tag.title 30;
      put tag.artist 30;
      put tag.album 30;
      put tag.year 4;
      put tag.comment 29;
      output_byte oc tag.tracknum;
      output_byte oc tag.genre;
      close_out oc
    with x ->
      close_out oc; raise x

  let merge t1 t2 =
    { title = if t2.title <> "" then t2.title else t1.title;
      artist = if t2.artist <> "" then t2.artist else t1.artist;
      album = if t2.album <> "" then t2.album else t1.album;
      year = if t2.year <> "" && t2.year <> "0" then t2.year else t1.year;
      comment = if t2.comment <> "" then t2.comment else t1.comment;
      tracknum = if t2.tracknum <> 0 then t2.tracknum else t1.tracknum;
      genre = if t2.genre <> 0xFF then t2.genre else t1.genre }

  let no_tag = {title = ""; artist = ""; album = ""; year = "";
                comment = ""; tracknum = 0; genre = 0xFF }
end

module Id3v2 = struct

  type tag = (string * string) list

  let unsynchronization = ref false
  let last_byte_read = ref 0

  let input_byte ic =
    let b = Pervasives.input_byte ic in
    let b =
      if b = 0 && !unsynchronization && !last_byte_read = 0xFF
      then Pervasives.input_byte ic
      else b in
    last_byte_read := b;
    b

  let input_buffer ic len =
    let buff = String.create len in
    for i = 0 to len - 1 do
      buff.[i] <- Char.chr (input_byte ic)
    done;
    buff

  let input_int4 ic =
    let b4 = input_byte ic in let b3 = input_byte ic in
    let b2 = input_byte ic in let b1 = input_byte ic in
    (b4 lsl 24) lor (b3 lsl 16) lor (b2 lsl 8) lor b1

  let input_int3 ic =
    let b3 = input_byte ic in
    let b2 = input_byte ic in let b1 = input_byte ic in
    (b3 lsl 16) lor (b2 lsl 8) lor b1

  let skip_bytes ic n =
    for i = 1 to n do ignore(input_byte ic) done

  let valid_header header =
       String.sub header 0 3 = "ID3"
    && (let v = Char.code header.[3] in v >= 2 && v <= 4)
    && Char.code header.[5] land 0b00111111 = 0
    && Char.code header.[6] land 0b10000000 = 0
    && Char.code header.[7] land 0b10000000 = 0
    && Char.code header.[8] land 0b10000000 = 0
    && Char.code header.[9] land 0b10000000 = 0

  let length_header header =
    ((Char.code header.[6] lsl 21) lor
     (Char.code header.[7] lsl 14) lor
     (Char.code header.[8] lsl 7) lor
     (Char.code header.[9]))

  let decode_framedata id data =
    if id = "TXXX" then begin
      if data.[0] <> '\000' then raise Not_found;
      let datapos = 1 + String.index_from data 1 '\000' in
      chop_whitespace data datapos
    end else if id.[0] = 'T' then begin
      if data.[0] <> '\000' then raise Not_found;
      chop_whitespace data 1
    end else
      data

  let valid_id_char c =
    (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')

  let tag_v2_to_v3 = [
     "BUF", "RBUF";     "CNT", "PCNT";
     "COM", "COMM";     "CRA", "AENC";
     "ETC", "ETCO";     "EQU", "EQUA";
     "GEO", "GEOB";     "IPL", "IPLS";
     "LNK", "LINK";     "MCI", "MCDI";
     "LLT", "MPEG";     "PIC", "APIC";
     "POP", "POPM";     "REV", "RVRB";
     "RVA", "RVAD";     "SLT", "SYLT";
     "STC", "SYTC";     "TAL", "TALB";
     "TBP", "TBPM";     "TCM", "TCOM";
     "TCO", "TCON";     "TCR", "TCOP";
     "TDA", "TDAT";     "TDY", "TDLY";
     "TEN", "TENC";     "TFT", "TFLT";
     "TIM", "TIME";     "TKE", "TKEY";
     "TLA", "TLAN";     "TLE", "TLEN";
     "TMT", "TMED";     "TOA", "TOPE";
     "TOF", "TOFN";     "TOL", "TOLY";
     "TOR", "TORY";     "TOT", "TOAL";
     "TP1", "TPE1";     "TP2", "TPE2";
     "TP3", "TPE3";     "TP4", "TPE4";
     "TPA", "TPOS";     "TPB", "TPUB";
     "SRC", "ISRC";     "TRD", "TRDA";
     "TRK", "TRCK";     "TSI", "TSIZ";
     "TSS", "TSSE";     "TT1", "TIT1";
     "TT2", "TIT2";     "TT3", "TIT3";
     "TXT", "TEXT";     "TXX", "TXXX";
     "TYE", "TYER";     "UFI", "UFID";
     "ULT", "USLT";     "WAF", "WOAF";
     "WAR", "WOAR";     "WAS", "WOAS";
     "WCM", "WCOM";     "WCP", "WCOP";
     "WPB", "WPUB";     "WXX", "WXXX"
  ]

  let input_frame_2 ic =
    let frameid = input_buffer ic 3 in
    if not (valid_id_char frameid.[0] &&
            valid_id_char frameid.[1] &&
            valid_id_char frameid.[2]) then raise Exit;
    let framelen = input_int3 ic in
    let framedata = input_buffer ic framelen in
    let frameid_v3 = 
      try List.assoc frameid tag_v2_to_v3 with Not_found -> "Z" ^ frameid in
    (frameid_v3, decode_framedata frameid_v3 framedata)

  let input_frame_3 ic =
    let frameid = input_buffer ic 4 in
    if not (valid_id_char frameid.[0] &&
            valid_id_char frameid.[1] &&
            valid_id_char frameid.[2] &&
            valid_id_char frameid.[3]) then raise Exit;
    let framelen = input_int4 ic in
    let flags1 = input_byte ic in
    let flags2 = input_byte ic in
    let framedata = input_buffer ic framelen in
    if flags1 land 0b00011111 = 0 && flags2 = 0
    then (frameid, decode_framedata frameid framedata)
    else raise Not_found

  let read_channel ic =
    let header = String.create 10 in
    really_input ic header 0 10;
    if not (valid_header header) then raise Not_found;
    let version = Char.code header.[3] in
    let len = length_header header in
    let startpos = pos_in ic in
    (* Record use of unsynchronization *)
    unsynchronization := ((Char.code header.[5] land 0b10000000) <> 0);
    last_byte_read := 0;
    (* Skip extended header if present *)
    if version >= 3 && Char.code header.[5] land 0b01000000 <> 0 then
      skip_bytes ic (input_int4 ic);
    (* Collect frames *)
    let tags = ref [] in
    begin try
      while pos_in ic < startpos + len do
        try
          let frameid_framedata =
            if version = 2 then input_frame_2 ic else input_frame_3 ic in
          tags := frameid_framedata :: !tags
        with Not_found ->
          ()
      done
    with Exit -> ()
    end;
    List.rev !tags

  let check_version ic =
    let header = String.create 10 in
    really_input ic header 0 10;
    if valid_header header
    then (Char.code header.[3], 10 + length_header header)
    else (-1, 0)

  let read_file filename =
    let ic = open_in_bin filename in
    try
      let res = read_channel ic in
      close_in ic; res
    with x ->
      close_in ic; raise x

  let last_byte_written = ref 0

  let output_byte oc b =
    if !last_byte_written = 0xFF then begin
      if b = 0 || b land 0b11100000 = 0b11100000 then
        Pervasives.output_byte oc 0
    end;
    Pervasives.output_byte oc b;
    last_byte_written := b

  let output_int4 oc n =
    output_byte oc (n lsr 24);
    output_byte oc (n lsr 16);
    output_byte oc (n lsr 8);
    output_byte oc n

  let output_encoded_int4 oc n =
    Pervasives.output_byte oc ((n lsr 21) land 0x7F);
    Pervasives.output_byte oc ((n lsr 14) land 0x7F);
    Pervasives.output_byte oc ((n lsr 7) land 0x7F);
    Pervasives.output_byte oc (n land 0x7F)

  let output_string oc s =
    for i = 0 to String.length s - 1 do output_byte oc (Char.code s.[i]) done

  let output_frame oc (name, data) =
    assert (String.length name = 4);
    if name = "TXXX" || name = "TXX" then begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data + 10); (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_byte oc 0;                         (* this is ISO Latin1 *)
      output_string oc "Comment";               (* dummy name *)
      output_byte oc 0;                         (* end of name *)
      output_string oc data;                    (* data *)
      output_byte oc 0                          (* termination *)
    end else if name.[0] = 'T' then begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data + 2);  (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_byte oc 0;                         (* this is ISO Latin1 *)
      output_string oc data;                    (* data *)
      output_byte oc 0                          (* termination *)
    end else begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data);      (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_string oc data                     (* raw data *)
    end

  let write_tag oc data =
    (* Output header *)
    output_string oc "ID3\003\000\128";
    let totalsize_pos = pos_out oc in
    output_encoded_int4 oc 0;
    last_byte_written := 0;
    (* Output frames *)
    List.iter (output_frame oc) data;
    (* Patch total size *)
    let end_pos = pos_out oc in
    seek_out oc totalsize_pos;
    output_encoded_int4 oc (end_pos - totalsize_pos - 4);
    seek_out oc end_pos

  let append_data oc filename =
    let ic = open_in_bin filename in
    try
      begin try
        let header = String.create 10 in
        really_input ic header 0 10;
        if not (valid_header header) then raise Not_found;
        seek_in ic (pos_in ic + length_header header)
      with Not_found | End_of_file ->
        seek_in ic 0
      end;
      let buffer = String.create 4096 in
      let rec copy_file () =
        let n = input ic buffer 0 (String.length buffer) in
        if n = 0 then () else begin output oc buffer 0 n; copy_file () end in
      copy_file ();
      close_in ic
    with x ->
      close_in ic; raise x

  let write_file ?src:srcname filename data =
    let origname =
      match srcname with
        None ->
          Sys.rename filename (filename ^ ".bak"); filename ^ ".bak"
      | Some s -> s in
    try
      let oc = open_out_bin filename in
      begin try
        write_tag oc data;
        append_data oc origname
      with x ->
        close_out oc; raise x
      end;
      close_out oc;
      begin match srcname with
        None -> Sys.remove origname
      | Some s -> ()
      end
    with x ->
      begin match srcname with
        None -> Sys.rename origname filename
      | Some s -> ()
      end;
      raise x

  let write_tag_to_file filename data =
    let oc = open_out_bin filename in
    begin try
      write_tag oc data
    with x ->
      close_out oc; raise x
    end;
    close_out oc

  let merge t1 t2 =
    t1 @ List.filter (fun (tag, data) -> not (List.mem_assoc tag t1)) t2
  
  let no_tag = []

end

let rec try_assoc_list tags list =
  match tags with
    [] -> ""
  | hd :: tl -> try List.assoc hd list with Not_found -> try_assoc_list tl list

let v2_to_v1 tags =
  { Id3v1.title = try_assoc_list ["TIT2"] tags;
    Id3v1.artist = try_assoc_list ["TPE1"; "TPE2"] tags;
    Id3v1.album = try_assoc_list ["TALB"] tags;
    Id3v1.year = try_assoc_list ["TYEA"] tags;
    Id3v1.comment = try_assoc_list ["TXXX"] tags;
    Id3v1.tracknum =
      (let s = try_assoc_list ["TRCK"] tags in
      try int_of_string s
      with _ -> 0
      );
    Id3v1.genre =
      (let s = try_assoc_list ["TCON"] tags in
       try int_of_string s
       with _ -> 0xFF)
  }

let v1_to_v2 t =
  let tags = ref [] in
  if t.Id3v1.genre <> 0xFF then
    tags := ("TCON", "(" ^ string_of_int t.Id3v1.genre ^ ")") :: !tags;
  if t.Id3v1.tracknum <> 0 then
    tags := ("TRCK", string_of_int t.Id3v1.tracknum) :: !tags;
  if t.Id3v1.comment <> "" then
    tags := ("TXXX", t.Id3v1.comment) :: !tags;
  if t.Id3v1.year <> "" && t.Id3v1.year <> "0" then
    tags := ("TYEA", t.Id3v1.year) :: !tags;
  if t.Id3v1.album <> "" then
    tags := ("TALB", t.Id3v1.album) :: !tags;
  if t.Id3v1.artist <> "" then
    tags := ("TPE1", t.Id3v1.artist) :: !tags;
  if t.Id3v1.title <> "" then
    tags := ("TIT2", t.Id3v1.title) :: !tags;
  !tags

let read_channel_both_v1 ic =
  let t2 =
    try v2_to_v1(Id3v2.read_channel ic) with Not_found -> Id3v1.no_tag in
  let t1 =
    try Id3v1.read_channel ic with Not_found -> Id3v1.no_tag in
  Id3v1.merge t2 t1

let read_channel_both_v2 ic =
  let t2 =
    try Id3v2.read_channel ic with Not_found -> Id3v2.no_tag in
  let t1 =
    try v1_to_v2(Id3v1.read_channel ic) with Not_found -> Id3v2.no_tag in
  Id3v2.merge t2 t1

let write_file_both_v1 ?src:srcname filename tag =
  Id3v2.write_file ?src:srcname filename (v1_to_v2 tag);
  Id3v1.write_file filename tag

let write_file_both_v2 ?src:srcname filename tag =
  Id3v2.write_file ?src:srcname filename tag;
  Id3v1.write_file filename (v2_to_v1 tag)
