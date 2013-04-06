let biblioForDisplay = ref ""	(*Bibliotheque*)
let biblioFile = ref [""]


let addBiblio filepath =
  let name = ref filepath in
	biblioFile := !biblioFile @ [filepath];
  Ettoihc.biblioForSave := !Ettoihc.biblioForSave ^ filepath ^ "\n";
  (if Meta.Id3v1.has_tag filepath then
    (let t = Meta.Id3v1.read_file filepath in 
    name := Meta.Id3v1.getTitle t ^ " | " ^ Meta.Id3v1.getArtist t;
    biblioForDisplay := !biblioForDisplay ^ !name ^ "\n")
  else
    biblioForDisplay := filepath)


let checkBiblio () =
  let filepath = !Current.filepath in
	let rec noExist = function
		|[] -> true
		|h::t when h = filepath -> false
		|_::t -> noExist t in
	if (noExist !biblioFile) then
    addBiblio filepath

let startBiblio () =
  Playlist.loadBiblio biblioForDisplay Ettoihc.biblioForSave biblioFile;
  Ettoihc.biblioText#buffer#set_text (!biblioForDisplay)



(*
let numberFile = ref 0

  let button = GButton.button
    ~relief:`NONE 
    ~packing:(Ettoihc.biblioTable#attach ~expand:`X ~left: 0 ~top: !numberFile) ()
  and markup = Printf.sprintf "%s" !name in

  ignore (GMisc.label ~markup ~packing:button#add ());
  numberFile := !numberFile + 1*)
