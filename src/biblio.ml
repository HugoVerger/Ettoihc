let addSong filepath biblio =
  let rec checkExist = function
    |[] -> false
    |(_,_,file)::_ when file = filepath -> true
    |(_,_,_)::t -> checkExist t in
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
          genre := (string_of_int(t.Meta.Id3v1.genre));
        end;
      biblio := !biblio @ [(!title,!artist,filepath)];
      Ettoihc.biblioForSave := !Ettoihc.biblioForSave ^ filepath ^ "\n"
    end

let addPlaylist filepath biblio =
  let ic = open_in filepath in
  (try
    while true; do
      addSong (input_line ic) biblio;
    done;
  with End_of_file ->
    close_in ic);
