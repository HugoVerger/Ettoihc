(** Read **)

let unsynchronization = ref false
let last_byte_read = ref 0

let chop_whitespace str from =
  let i = ref (String.length str) in
  while !i > from &&
        (let c = str.[!i-1] in c = '\000' || c = ' ' || c = '\t')
  do decr i done;
  String.sub str from (!i - from)

let valid_id_char c =
  (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')

let hasV2 ic =
  let len = in_channel_length ic in
  if len < 10 then
    false
  else
    begin  
      let header = String.create 10 in
      really_input ic header 0 10;
      String.sub header 0 3 = "ID3"
        && (let v = Char.code header.[3] in v >= 2 && v <= 4)
        && Char.code header.[5] land 0b00111111 = 0
        && Char.code header.[6] land 0b10000000 = 0
        && Char.code header.[7] land 0b10000000 = 0
        && Char.code header.[8] land 0b10000000 = 0
        && Char.code header.[9] land 0b10000000 = 0
    end

let hasV1 ic =
  let len = in_channel_length ic in
  if len < 128 then 
    false
  else
    begin
      seek_in ic (len - 128);
      let buffer = String.create 3 in
      really_input ic buffer 0 3;
      buffer = "TAG"
    end

let length_header header =
  ((Char.code header.[6] lsl 21) lor
    (Char.code header.[7] lsl 14) lor
    (Char.code header.[8] lsl 7) lor
    (Char.code header.[9]))

let input_byte ic =
  let b = Pervasives.input_byte ic in
  let b =
    if b = 0 && !unsynchronization && !last_byte_read = 0xFF then
      Pervasives.input_byte ic
    else
      b in
  last_byte_read := b;
  b

let input_buffer ic len =
  let buff = String.create len in
  for i = 0 to len - 1 do
    buff.[i] <- Char.chr (input_byte ic)
  done;
  buff

let input_int3 ic =
  let b3 = input_byte ic and b2 = input_byte ic and b1 = input_byte ic in
   (b3 lsl 16) lor (b2 lsl 8) lor b1

let input_int4 ic =
  let b4 = input_byte ic and b3 = input_byte ic in
  let b2 = input_byte ic and b1 = input_byte ic in
  (b4 lsl 24) lor (b3 lsl 16) lor (b2 lsl 8) lor b1

let skip_bytes ic n =
  for i = 1 to n do ignore(input_byte ic) done

let tag_v2_to_v3 = [
 "BUF", "RBUF";   "CNT", "PCNT";   "COM", "COMM";   "CRA", "AENC";
 "ETC", "ETCO";   "EQU", "EQUA";   "GEO", "GEOB";   "IPL", "IPLS";
 "LNK", "LINK";   "MCI", "MCDI";   "LLT", "MPEG";   "PIC", "APIC";
 "POP", "POPM";   "REV", "RVRB";   "RVA", "RVAD";   "SLT", "SYLT";
 "STC", "SYTC";   "TAL", "TALB";   "TBP", "TBPM";   "TCM", "TCOM";
 "TCO", "TCON";   "TCR", "TCOP";   "TDA", "TDAT";   "TDY", "TDLY";
 "TEN", "TENC";   "TFT", "TFLT";   "TIM", "TIME";   "TKE", "TKEY";
 "TLA", "TLAN";   "TLE", "TLEN";   "TMT", "TMED";   "TOA", "TOPE";
 "TOF", "TOFN";   "TOL", "TOLY";   "TOR", "TORY";   "TOT", "TOAL";
 "TP1", "TPE1";   "TP2", "TPE2";   "TP3", "TPE3";   "TP4", "TPE4";
 "TPA", "TPOS";   "TPB", "TPUB";   "SRC", "ISRC";   "TRD", "TRDA";
 "TRK", "TRCK";   "TSI", "TSIZ";   "TSS", "TSSE";   "TT1", "TIT1";
 "TT2", "TIT2";   "TT3", "TIT3";   "TXT", "TEXT";   "TXX", "TXXX";
 "TYE", "TYER";   "UFI", "UFID";   "ULT", "USLT";   "WAF", "WOAF";
 "WAR", "WOAR";   "WAS", "WOAS";   "WCM", "WCOM";   "WCP", "WCOP";
 "WPB", "WPUB";   "WXX", "WXXX"]

let decode_framedata id data =
  if id = "TXXX" then
    begin
      if data.[0] <> '\000' then
        raise Not_found;
      let datapos = 1 + String.index_from data 1 '\000' in
      chop_whitespace data datapos
    end
  else if id.[0] = 'T' then
    begin
      if data.[0] <> '\000' then raise Not_found;
      chop_whitespace data 1
    end
  else
    data

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
  if flags1 land 0b00011111 = 0 && flags2 = 0 then
    (frameid, decode_framedata frameid framedata)
  else
   raise Not_found

let readv2 ic =
  seek_in ic 0;
  let header = String.create 10 in
  really_input ic header 0 10;
  let version = Char.code header.[3] in
  let len = length_header header in
  let startpos = pos_in ic in
  if version >= 3 && Char.code header.[5] land 0b01000000 <> 0 then
    skip_bytes ic (input_int4 ic);
  let tags = ref [] in
  try
    while pos_in ic < startpos + len do
      try
        let frameid_framedata =
          if version = 2 then input_frame_2 ic else input_frame_3 ic in
        tags := frameid_framedata :: !tags
      with Not_found -> ()
    done;
    !tags
  with Exit -> []

let genreExtension = function
  |"(80)" -> "Folk"         |"(81)" -> "Folk/Rock"    |"(82)" ->"National Folk"
  |"(83)" -> "Swing"        |"(84)" -> "Fast-Fusion"  |"(85)" -> "Bebob"
  |"(86)" -> "Latin"        |"(87)" -> "Revival"      |"(88)" -> "Celtic"
  |"(89)" -> "Bluegrass"    |"(90)"->"Avantgarde"     |"(91)"->"Gothic Rock"
  |"(92)" -> "Progressive Rock"                   |"(93)" -> "Psychedelic Rock"
  |"(94)" ->"Symphonic Rock"|"(95)" -> "Slow Rock"    |"(96)" -> "Big Band"
  |"(97)" -> "Chorus"       |"(98)"->"Easy Listening" |"(99)" -> "Acoustic"
  |"(100)" -> "Humour"      |"(101)" -> "Speech"      |"(102)" -> "Chanson"
  |"(103)" -> "Opera"       |"(104)"->"Chamber Music" |"(105)" -> "Sonata"
  |"(106)" -> "Symphony"    |"(107)" -> "Booty Bass"  |"(108)" -> "Primus"
  |"(109)" -> "Porn Groove" |"(110)" -> "Satire"      |"(111)" -> "Slow Jam"
  |"(112)" -> "Club"        |"(113)" -> "Tango"       |"(114)" -> "Samba"
  |"(115)" -> "Folklore"    |"(116)" -> "Ballad"      |"(117)" ->"Power Ballad"
  |"(118)" ->"Rhythmic Soul"|"(119)" -> "Freestyle"   |"(120)" -> "Duet"
  |"(121)" -> "Punk Rock"   |"(122)" -> "Drum Solo"   |"(123)" -> "A Cappella"
  |"(124)" -> "Euro-House"  |"(125)" -> "Dance Hall"  |"(126)" -> "Goa"
  |"(127)" -> "Drum & Bass" |"(128)" -> "Club-House"  |"(129)" -> "Hardcore"
  |"(130)" -> "Terror"      |"(131)" -> "Indie"       |"(132)" -> "BritPop"
  |"(133)" -> "Negerpunk"   |"(134)" -> "Polsk Punk"  |"(135)" ->"Beat"
  |"(136)" -> "Christian Gangsta Rap"                 |"(137)"-> "Heavy Metal"
  |"(138)" -> "Black Metal" |"(139)" -> "Crossover"   |"(143)" -> "Salsa"
  |"(140)" -> "Contemporary Christian"               |"(141)"->"Christian Rock"
  |"(142)" -> "Merengue"    |"(144)" -> "Thrash Metal"|"(145)" -> "Anime"
  |"(146)" -> "JPop"        |"(147)" -> "Synthpop"    |_ -> ""

let getGenre = function
  |"(0)" -> "Blues"         |"(1)" -> "Classic Rock"  |"(2)" ->"Country"
  |"(3)" ->"Dance"          |"(4)" ->"Disco"          |"(5)" ->"Funk"  
  |"(6)" ->"Grunge"         |"(7)" ->"Hip-Hop"        |"(8)" ->"Jazz"
  |"(9)" ->"Metal"          |"(10)" ->"New Age"       |"(11)" ->"Oldies"
  |"(12)" ->"Other"         |"(13)" -> "Pop"          |"(14)" -> "R&B"  
  |"(15)" -> "Rap"          |("16") -> "Reggae"       |"(17)" -> "Rock"
  |"(18)" -> "Techno"       |"(19)" -> "Industrial"   |"(20)" -> "Alternative"
  |"(21)" -> "Ska"          |"(22)" -> "Death Metal"  |"(23)" -> "Pranks"
  |"(24)" -> "Soundtrack"   |"(25)" -> "Euro-Techno"  |"(26)" -> "Ambient"
  |"(27)" -> "Trip-Hop"     |"(28)" -> "Vocal"        |"(29)" -> "Jazz+Funk"
  |"(30)" -> "Fusion"       |"(31)" -> "Trance"       |"(32)" -> "Classical" 
  |"(33)" -> "Instrumental" |"(34)" -> "Acid"         |"(35)" -> "House"
  |"(36)" -> "Game"         |"(37)" -> "Sound Clip"   |"(38)" -> "Gospel"
  |"(39)" -> "Noise"        |"(40)" -> "Alt. Rock"    |"(41)" -> "Bass"  
  |"(42)" -> "Soul"         |"(43)" -> "Punk"         |"(44)" -> "Space"
  |"(45)"->"Meditative"|"(46)"->"Instrumental Pop"|"(47)"->"Instrumental Rock"
  |"(48)" -> "Ethnic"       |"(49)" -> "Gothic"       |"(50)" -> "Darkwave"
  |"(51)"->"Techno-Industrial"|"(52)" -> "Electronic" |"(53)" -> "Pop-Folk" 
  |"(54)" -> "Eurodance"    |"(55)" -> "Dream"       |"(56)" -> "Southern Rock"
  |"(57)" -> "Comedy"       |"(58)" -> "Cult"         |"(59)" -> "Gangsta Rap"
  |"(60)" -> "Top 40"       |"(61)" -> "Christian Rap"|"(62)" -> "Pop/Funk"
  |"(63)" -> "Jungle"       |"(64)"->"Native American"|"(65)" -> "Cabaret"
  |"(66)" -> "New Wave"     |"(67)" -> "Psychedelic"  |"(68)" -> "Rave" 
  |"(69)" -> "Showtunes"    |"(70)" -> "Trailer"      |"(71)" -> "Lo-Fi"
  |"(72)" -> "Tribal"       |"(73)" -> "Acid Punk"    |"(74)" -> "Acid Jazz" 
  |"(75)" -> "Polka"        |"(76)" -> "Retro"        |"(77)" -> "Musical"
  |"(78)" -> "Rock & Roll"  |"(79)" -> "Hard Rock"    |a -> genreExtension a

let readV1 ic =
  let len = in_channel_length ic in
  seek_in ic (len - 125);
  let readstring len =
  let buf = String.create len in
    really_input ic buf 0 len;
    chop_whitespace buf 0 in
  let title = readstring 30 in
  let artist = readstring 30 in
  let album = readstring 30 in
  let year = readstring 4 in
  let comment = readstring 29 in
  let tracknum = readstring 1 in
  let genre = readstring 1 in
  [("TIT2",title); ("TPE1",artist); ("TALB",album); ("TDOR",year);
   ("COMM",comment); ("TRCK",tracknum); ("TCON", getGenre (genre))]

let read file =
  let ic = open_in_bin file in
  let res = ref [] in
  if hasV2 ic then
    res := readv2 ic
  else 
    begin
      if hasV1 ic then
        res := readV1 ic
    end;
  close_in ic;
  !res


(** Write **)


let last_byte_written = ref 0

let output_byte oc b =
  if !last_byte_written = 0xFF then
    begin
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
  for i = 0 to String.length s - 1 do
    output_byte oc (Char.code s.[i]) done

let output_frame oc (name, data) =
  assert (String.length name = 4);
  if name = "TXXX" || name = "TXX" then
    begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data + 10); (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_byte oc 0;                         (* this is ISO Latin1 *)
      output_string oc "Comment";               (* dummy name *)
      output_byte oc 0;                         (* end of name *)
      output_string oc data;                    (* data *)
      output_byte oc 0                          (* termination *)
    end
  else if name.[0] = 'T' then
    begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data + 2);  (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_byte oc 0;                         (* this is ISO Latin1 *)
      output_string oc data;                    (* data *)
      output_byte oc 0                          (* termination *)
    end
  else
    begin
      output_string oc name;                    (* tag *)
      output_int4 oc (String.length data);      (* length *)
      output_byte oc 0; output_byte oc 0;       (* null flags *)
      output_string oc data                     (* raw data *)
    end

let append_data oc filename =
  let ic = open_in_bin filename in
  try
    begin
      try
        let header = String.create 10 in
        really_input ic header 0 10;
        if not (hasV2 ic) then
          raise Not_found;
        seek_in ic (pos_in ic + length_header header)
      with Not_found | End_of_file ->
        seek_in ic 0
    end;
    let buffer = String.create 4096 in
    let rec copy_file () =
      let n = input ic buffer 0 (String.length buffer) in
      if n = 0 then
        ()
      else
        begin
          output oc buffer 0 n;
          copy_file ()
        end in
    copy_file ();
    close_in ic
  with x ->
    close_in ic; raise x

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

let write ?src:srcname filename data =
  let origname =
    match srcname with
      |None ->
        Sys.rename filename (filename ^ ".bak"); filename ^ ".bak"
      |Some s -> s in
  try
    let oc = open_out_bin filename in
    begin
      try
        write_tag oc data;
        append_data oc origname
      with x ->
        close_out oc; raise x
    end;
    close_out oc;
    begin
      match srcname with
        |None -> Sys.remove origname
        |Some s -> ()
    end
  with x ->
    begin
      match srcname with
        |None -> Sys.rename origname filename
        |Some s -> ()
    end;
    raise x
