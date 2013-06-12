let sort_name = ref false
let sort_album = ref true
let sort_artist = ref false
let sort_genre = ref false

(** Library manipulations **)

let getGenre = function
  |0 -> "Blues"  |1 -> "Classic Rock"  |2 ->"Country"  |3 ->"Dance"
  |4 ->"Disco"  |5 ->"Funk"  |6 ->"Grunge"  |7 ->"Hip-Hop"
  |8 ->"Jazz"  |9 ->"Metal"  |10 ->"New Age"  |11 ->"Oldies"
  |12 ->"Other"  |13 -> "Pop"  |14 -> "R&B"  |15 -> "Rap"
  |16 -> "Reggae"  |17 -> "Rock"  |18 -> "Techno"  |19 -> "Industrial"
  |20 -> "Alternative"  |21 -> "Ska"  |22 -> "Death Metal"  |23 -> "Pranks"
  |24 -> "Soundtrack"  |25 -> "Euro-Techno"  |26 -> "Ambient"  |27 -> "Trip-Hop"
  |28 -> "Vocal"  |29 -> "Jazz+Funk"  |30 -> "Fusion"  |31 -> "Trance"
  |32 -> "Classical"  |33 -> "Instrumental"  |34 -> "Acid"  |35 -> "House"
  |36 -> "Game"  |37 -> "Sound Clip"  |38 -> "Gospel"  |39 -> "Noise"
  |40 -> "Alt. Rock"  |41 -> "Bass"  |42 -> "Soul"  |43 -> "Punk"
  |44 -> "Space"  |45 -> "Meditative"  |46 -> "Instrumental Pop"  |47 -> "Instrumental Rock"
  |48 -> "Ethnic"  |49 -> "Gothic"  |50 -> "Darkwave"  |51 -> "Techno-Industrial"
  |52 -> "Electronic"  |53 -> "Pop-Folk"  |54 -> "Eurodance"  |55 -> "Dream"
  |56 -> "Southern Rock"  |57 -> "Comedy"  |58 -> "Cult"  |59 -> "Gangsta Rap"
  |60 -> "Top 40"  |61 -> "Christian Rap"  |62 -> "Pop/Funk"  |63 -> "Jungle"
  |64 -> "Native American"  |65 -> "Cabaret"  |66 -> "New Wave"  |67 -> "Psychedelic"
  |68 -> "Rave"  |69 -> "Showtunes"  |70 -> "Trailer"  |71 -> "Lo-Fi"
  |72 -> "Tribal"  |73 -> "Acid Punk"  |74 -> "Acid Jazz"  |75 -> "Polka"
  |76 -> "Retro"  |77 -> "Musical"  |78 -> "Rock & Roll"  |79 -> "Hard Rock"
  |80 -> "Folk"  |81 -> "Folk/Rock"  |82 -> "National Folk"  |83 -> "Swing"
  |84 -> "Fast-Fusion"  |85 -> "Bebob"  |86 -> "Latin"  |87 -> "Revival"
  |88 -> "Celtic"  |89 -> "Bluegrass"  |90 -> "Avantgarde"  |91 -> "Gothic Rock"
  |92 -> "Progressive Rock"  |93 -> "Psychedelic Rock"  |94 -> "Symphonic Rock"  |95 -> "Slow Rock"
  |96 -> "Big Band"  |97 -> "Chorus"  |98 -> "Easy Listening"  |99 -> "Acoustic"
  |100 -> "Humour"  |101 -> "Speech"  |102 -> "Chanson"  |103 -> "Opera"
  |104 -> "Chamber Music"  |105 -> "Sonata"  |106 -> "Symphony"  |107 -> "Booty Bass"
  |108 -> "Primus"  |109 -> "Porn Groove"  |110 -> "Satire"  |111 -> "Slow Jam"
  |112 -> "Club"  |113 -> "Tango"  |114 -> "Samba"  |115 -> "Folklore"
  |116 -> "Ballad"  |117 -> "Power Ballad"  |118 -> "Rhythmic Soul"  |119 -> "Freestyle"
  |120 -> "Duet"  |121 -> "Punk Rock"  |122 -> "Drum Solo"  |123 -> "A Cappella"
  |124 -> "Euro-House"  |125 -> "Dance Hall"  |126 -> "Goa"  |127 -> "Drum & Bass"
  |128 -> "Club-House"  |129 -> "Hardcore"  |130 -> "Terror"  |131 -> "Indie"
  |132 -> "BritPop"  |133 -> "Negerpunk"  |134 -> "Polsk Punk"  |135 -> "Beat"
  |136 -> "Christian Gangsta Rap"  |137 -> "Heavy Metal"  |138 -> "Black Metal"  |139 -> "Crossover"
  |140 -> "Contemporary Christian"  |141 -> "Christian Rock"  |142 -> "Merengue"  |143 -> "Salsa"
  |144 -> "Thrash Metal"  |145 -> "Anime"  |146 -> "JPop"  |147 -> "Synthpop"
  |_ -> "Unknow"

let ext wanted s =
  if String.length s > 4 then
    begin
      let ext = String.sub s ((String.length s) - 4) 4 in
      match ext with
        |s when s = wanted -> true
        |_ -> false
    end
  else
    false

let rec checkExist file = function
  |n when n = !UiPage2.nbSong -> false
  |n ->
    begin
      let iter = UiPage2.store#iter_children ~nth:n None in
      let test = UiPage2.store#get ~row:iter ~column:UiPage2.path in
        if (test = file) then
          true
        else
          checkExist file (n + 1)
    end

let rec add file =
  try
    if (Sys.file_exists file ) && (Sys.is_directory file) then
      Array.iter (fun a -> add (file ^ "/" ^ a)) (Sys.readdir file)
    else if Sys.file_exists file 
         && ext ".mp3" file 
         && not(checkExist file 0) then
      begin
        let t = Meta.v1_of_v2 (Meta.read_both_as_v2 file) in
        let iter = UiPage2.store#append () in
        UiPage2.nbSong := !UiPage2.nbSong + 1;
        UiPage2.store#set ~row:iter ~column:UiPage2.title t.Meta.Id3v1.title;
        UiPage2.store#set ~row:iter ~column:UiPage2.artist t.Meta.Id3v1.artist;
        UiPage2.store#set ~row:iter ~column:UiPage2.album t.Meta.Id3v1.album;
        UiPage2.store#set ~row:iter 
          ~column:UiPage2.genre (getGenre t.Meta.Id3v1.genre);
        UiPage2.store#set ~row:iter ~column:UiPage2.path file
      end
    else if (Sys.file_exists file ) && (ext ".m3u" file) then
      begin
        let ic = open_in file in
        try
        while true do
          add (input_line ic)
        done;
        with End_of_file ->
          close_in ic
      end
  with Sys_error e -> () (* Catch Protected Files *)

let loadBiblio () =
  let ic = open_in "bin/biblio" in
  try
    while true; do
      add (input_line ic)
    done;
  with End_of_file ->
    close_in ic

let saveBiblio () =
  let oc = open_out "bin/biblio" in
  let store = UiPage2.store in
  let first = store#get_iter_first in
  begin
    match first with
    |Some iter ->
      Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage2.path);

      while store#iter_next iter do
        Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage2.path)
      done
    |None -> ()
  end;
  close_out oc

(** Sorting of columns **)

let compare a b =
  if a < b then -1
  else if a > b then 1
  else 0

let sort_by col (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:col in
  let name2 = model#get ~row:row2 ~column:col in
  compare name1 name2

let connectSort () =
  UiPage2.store#set_sort_func 0 (sort_by UiPage2.title);
  UiPage2.store#set_sort_func 1 (sort_by UiPage2.artist);
  UiPage2.store#set_sort_func 2 (sort_by UiPage2.album);
  UiPage2.store#set_sort_func 3 (sort_by UiPage2.genre);

  ignore(UiPage2.colName#connect#clicked (fun () -> 
    if !sort_name then
      UiPage2.store#set_sort_column_id 0 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 0 `ASCENDING;
    sort_name := not !sort_name; sort_artist := false; sort_album := false;
    sort_genre := false));

  ignore(UiPage2.colArtist#connect#clicked (fun () -> 
    if !sort_artist then
      UiPage2.store#set_sort_column_id 1 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 1 `ASCENDING;
    sort_artist := not !sort_artist; sort_name := false; sort_album := false;
    sort_genre := false));

  ignore(UiPage2.colAlbum#connect#clicked (fun () -> 
    if !sort_album then
      UiPage2.store#set_sort_column_id 2 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 2 `ASCENDING;
  sort_album := not !sort_album; sort_name := false; sort_artist := false;
  sort_genre := false));

  ignore(UiPage2.colGenre#connect#clicked (fun () -> 
    if !sort_genre then
      UiPage2.store#set_sort_column_id 3 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 3 `ASCENDING;
  sort_genre := not !sort_genre; sort_name := false; sort_artist := false;
  sort_album := false));

  UiPage2.store#set_sort_column_id 2 `ASCENDING

(** Handling Mouse Control **)

let doubleClickLeft (view:GTree.view) path column =
  let str_op = function
    |Some x -> x
    |_ -> failwith "Need a file" in

  let model = view#model in
  let row = model#get_iter path in
  let file = model#get ~row ~column:UiPage2.path in

  if (Sys.file_exists file) then
    Playlist.add file
  else if ((Ui.missing ())#run ()) = `OK then
      begin
        let dlg = Ui.search () in
        if (dlg#run ()) = `OK then
          begin
            let file = str_op(dlg#filename) in
            UiPage2.store#set ~row ~column:UiPage2.path file;
            Playlist.add file
          end;
        dlg#misc#hide ()
      end


let popupMenu treeview ev p =
  let menu = UiPage2.popup () in
  let items = menu#children in

  ignore((List.nth items 0)#connect#activate ~callback:(fun () ->
    let row = UiPage2.store#get_iter p in
    ignore(UiPage2.store#remove row);
    UiPage2.nbSong := !UiPage2.nbSong - 1));

  (*ignore((List.nth items 0)#connect#activate ~callback:(fun () ->
    let row = UiPage2.store#get_iter p in
    let path = UiPage2.store#get ~row ~column:UiPage2.path in
    Ettoihc.tagW path;
    removeSong p;
    Biblio.addSong path biblio;
    addBiblio (List.length !biblio - 1)));*)
  menu#popup
    ~button:(GdkEvent.Button.button ev)
    ~time:(GdkEvent.Button.time ev)

let clickRight treeview ev =
  if GdkEvent.Button.button ev = 3 then
    begin
      let selection = treeview#selection in
      if selection#count_selected_rows <= 1 then
        begin
          let x = int_of_float (GdkEvent.Button.x ev) in
          let y = int_of_float (GdkEvent.Button.y ev) in
          match treeview#get_path_at_pos ~x ~y  with
            |Some(p,_,_,_) ->
              begin
                selection#unselect_all ();
                selection#select_path p;
                popupMenu treeview ev p;
              end
            |None -> ()
        end;
      true
    end
  else
    false

let connectUI () =
  ignore(UiPage2.view#connect#row_activated
            ~callback: (doubleClickLeft UiPage2.view));
  ignore(UiPage2.view#event#connect#button_press
            ~callback: (clickRight UiPage2.view));
