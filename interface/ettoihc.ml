let pause = ref true	
let biblioForSave = ref ""
let playListForSave = ref ""

let str_op = function
  | Some x -> x
  | _ -> failwith "Need a file"

(* Fenêtre principale *)

let window =
  ignore(GMain.init ());
  let wnd = GWindow.window
    ~title:"Ettoihc"
    ~position:`CENTER
    ~resizable:true
    ~width:660 
    ~height:420 () in
  ignore(wnd#connect#destroy GMain.quit);
  wnd

(* Composants de la fenêtre principale *)

let mainbox = 
  let box = GPack.vbox
    ~border_width:10
    ~packing:window#add () in
  box#set_homogeneous false;
  box  
  
let menubox = 
	let box = GPack.hbox
  		~height: 60
  		~packing:(mainbox#pack ~expand:false) () in
  	box#set_homogeneous false;
  	box
let soundbox = 
    let box = GPack.hbox
      ~height: 20
      ~packing:(mainbox#pack ~expand:false) () in
    box#set_homogeneous false;
  box
let notebook = GPack.notebook
  ~packing: mainbox#add()


(* Contenu onglet 1 *)

let lecturePage = 
  let onglet1 = GPack.hbox () in
  let name1 = GMisc.label
    ~text:"En cours" () in
  ignore(notebook#insert_page 
    ~tab_label:name1#coerce onglet1#coerce);
  GPack.vbox
    ~packing:onglet1#add()

let colsPlaylist = new GTree.column_list
let songPlaylist = colsPlaylist#add Gobject.Data.string
let artistPlaylist = colsPlaylist#add Gobject.Data.string
let pathPlaylist = colsPlaylist#add Gobject.Data.string

let storePlaylist = GTree.list_store colsPlaylist
  
let playlistView =
  let model = storePlaylist in
  let view = GTree.view ~model ~packing: lecturePage#add () in
  view

(* Contenu onglet 2 *)

let biblioPage =
  let onglet2 = GPack.vbox () in
  let name1 = GMisc.label
    ~text:"Bibliotheque" () in
  ignore(notebook#insert_page 
    ~tab_label:name1#coerce onglet2#coerce);
  GPack.vbox
    ~packing:onglet2#add()

let colsBiblio = new GTree.column_list
let songBiblio = colsBiblio#add Gobject.Data.string
let artistBiblio = colsBiblio#add Gobject.Data.string
let pathBiblio = colsBiblio#add Gobject.Data.string

let storeBiblio = GTree.list_store colsPlaylist
  
let biblioView =
  let model = storePlaylist in
  let view = GTree.view ~model ~packing: lecturePage#add () in
  view

(* Contenu onglet 3 *)

let mixPage = 
  let onglet3 = GPack.vbox () in
  let name1 = GMisc.label
    ~text:"Effets" () in
  ignore(notebook#insert_page 
    ~tab_label:name1#coerce onglet3#coerce);
  GPack.vbox
    ~packing:onglet3#add()

let firstLine =
  let mixFrame1 =GBin.frame
    ~width:800
    ~height:250
    ~border_width:0
    ~packing:mixPage#add () in
  GPack.button_box `HORIZONTAL
  	~layout:`SPREAD
  	~packing:mixFrame1#add()

let secondLine =
  let mixFrame2 =GBin.frame
    ~width:800
    ~height:250
    ~border_width:0
    ~packing:mixPage#add () in
  GPack.button_box `HORIZONTAL
    ~layout:`SPREAD
    ~packing:mixFrame2#add()


(* Fenêtre d'ouverture *)

let music_filter = GFile.filter
  ~name:"Music File"
  ~patterns:(["*.mp3";"*.m3u"]) ()

let openDialog filepath = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Chargement d'une musique"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `OPEN `OPEN;    
  if dlg#run () = `OPEN then
    	filepath := str_op(dlg#filename);
  dlg#misc#hide ()

(* Fenêtre de sauvegarde *)

let saveDialog () = 
  let dlg =
  GWindow.file_chooser_dialog
    ~action:`SAVE
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title:"Sauvegarde de la playlist"
    ~destroy_with_parent:true () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `SAVE `SAVE;
  if  (dlg#run () == `SAVE) then 
      (Wrap.playlistSave (str_op(dlg#filename)) !playListForSave);
  dlg#misc#hide ()

(* Fenêtre de confirmation de sortie *)

let confirm _ =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>Voulez-vous vraiment quitter ?</big></b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  Wrap.biblioSave !biblioForSave;
  res
  
let get_extension s =
	let ext = String.sub s ((String.length s) - 4) 4 in
	match ext with
		|".mp3"-> true
		|_ -> false
