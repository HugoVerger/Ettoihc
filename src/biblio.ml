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

let addSong filepath biblio =
  let rec checkExist = function
    |[] -> false
    |(_,_,_,_,file)::_ when file = filepath -> true
    |(_,_,_,_,_)::t -> checkExist t in
  if (checkExist !biblio) then () else
    begin
      let title = ref "" and album = ref "" and year = ref "" in
      let comment = ref "" and genre = ref "" and artist = ref "" in
      let tracknum = ref "" in
      if Meta.Id3v1.has_tag filepath then
        begin
          let t = Meta.v1_of_v2 (Meta.read_both_as_v2 filepath) in
          title := t.Meta.Id3v1.title ;
          artist := t.Meta.Id3v1.artist ;
          album := t.Meta.Id3v1.album ;
          year := t.Meta.Id3v1.year ;
          comment := t.Meta.Id3v1.comment ;
          tracknum := (string_of_int(t.Meta.Id3v1.tracknum));
          genre := getGenre(t.Meta.Id3v1.genre);
        end;
      biblio := !biblio @ [(!title,!artist,!album,!genre,filepath)]
    end

let addPlaylist filepath biblio =
  let ic = open_in filepath in
  (try
    while true; do
      addSong (input_line ic) biblio;
    done;
  with End_of_file ->
    close_in ic)
    
let saveBiblio () =
  let oc = open_out "bin/biblio" in
  let store = Ettoihc.storeBiblio in
  let first = store#get_iter_first in
  begin
  match first with
  |Some iter ->
    Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:Ettoihc.pathBiblio);

    while store#iter_next iter do
      Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:Ettoihc.pathBiblio)
    done
  |None -> ()
  end;
  close_out oc
