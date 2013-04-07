let addSong filepath biblio =
  let rec checkExist = function
    |[] -> false
    |(_,_,file)::_ when file = filepath -> true
    |(_,_,_)::t -> checkExist t in
	if (checkExist !biblio) then () else
	begin
	  let artist = ref "" and song = ref "" in
	  if Meta.Id3v1.has_tag filepath then
        begin
		      let t = Meta.Id3v1.read_file filepath in
		    	artist := Meta.Id3v1.getArtist t;	
		    	song := Meta.Id3v1.getTitle t;
			  end;
    	biblio := !biblio @ [(!song,!artist,filepath)];
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
