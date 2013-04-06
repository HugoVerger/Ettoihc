let biblioForDisplay = ref ""	(*Bibliotheque*)
let biblioFile = ref [""]

let checkBiblio () =
  let filepath = !Current.filepath in
	let rec noExist = function
		|[] -> true
		|h::t when h = filepath -> false
		|_::t -> noExist t in
	if (noExist !biblioFile) then
  begin
	  biblioFile := !biblioFile @ [filepath];
		Ettoihc.biblioForSave := !Ettoihc.biblioForSave ^ filepath ^ "\n";
		if Meta.Id3v1.has_tag filepath then
		let t = Meta.Id3v1.read_file filepath in
			biblioForDisplay := !biblioForDisplay ^	Meta.Id3v1.getTitle t ^ 
									" - " ^ Meta.Id3v1.getArtist t ^ "\n"
			else
				biblioForDisplay := filepath
		end

let startBiblio () =
  Playlist.loadBiblio biblioForDisplay Ettoihc.biblioForSave biblioFile;
  Ettoihc.biblioText#buffer#set_text (!biblioForDisplay)
