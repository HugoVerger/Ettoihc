let biblio = ref []

let checkBiblio () =
  let filepath = !Current.filepath in
  if (Ettoihc.get_extension filepath) then
    Biblio.addSong filepath biblio
  else
    begin
      Biblio.addPlaylist filepath biblio
    end

let loadBiblio () =
   	let ic = open_in "biblio" in
   	try
  		while true; do
    		 Biblio.addSong (input_line ic) biblio;
  		done;
	with End_of_file ->
  	close_in ic

let startBiblio () =
  loadBiblio ()
