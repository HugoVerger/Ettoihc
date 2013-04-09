let pause = ref true	
let biblioForSave = ref ""
let playListForSave = ref ""
let play = ref (fun () -> ())

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

let scrollPlaylist = GBin.scrolled_window
  ~hpolicy:`ALWAYS
  ~vpolicy:`ALWAYS
  ~packing:lecturePage#add ()

let colsPlaylist = new GTree.column_list
let nmbPlaylist = colsPlaylist#add Gobject.Data.int
let songPlaylist = colsPlaylist#add Gobject.Data.string
let artistPlaylist = colsPlaylist#add Gobject.Data.string
let pathPlaylist = colsPlaylist#add Gobject.Data.string

let storePlaylist = GTree.list_store colsPlaylist
  
let playlistView =
  let model = storePlaylist in
  let view = GTree.view ~model ~packing: scrollPlaylist#add () in
  let col = GTree.view_column
    ~renderer:(GTree.cell_renderer_text [], ["text", nmbPlaylist]) () in
  col#set_min_width 20;
  ignore (view#append_column col);
  let col = GTree.view_column 
    ~title:"Song"
    ~renderer:(GTree.cell_renderer_text [], ["text", songPlaylist]) () in
  col#set_min_width 150;
  ignore (view#append_column col);
  let col = GTree.view_column 
    ~title:"Artist"
    ~renderer:(GTree.cell_renderer_text [], ["text", artistPlaylist]) () in
  col#set_min_width 150;
  ignore (view#append_column col);
  let col = GTree.view_column 
    ~title:"Path"
    ~renderer:(GTree.cell_renderer_text [], ["text", pathPlaylist]) () in
  col#set_min_width 330;
  ignore (view#append_column col);
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

let scrollBiblio = GBin.scrolled_window
  ~hpolicy:`ALWAYS
  ~vpolicy:`ALWAYS
  ~packing:biblioPage#add ()

let colsBiblio = new GTree.column_list
let songBiblio = colsBiblio#add Gobject.Data.string
let artistBiblio = colsBiblio#add Gobject.Data.string
let pathBiblio = colsBiblio#add Gobject.Data.string

let storeBiblio = GTree.list_store colsBiblio
  
let biblioView =
  let model = storeBiblio in
  let view = GTree.view ~model ~packing: scrollBiblio#add () in
  let col = GTree.view_column 
    ~title:"Song"
    ~renderer:(GTree.cell_renderer_text [], ["text", songBiblio]) () in
  col#set_min_width 150;
  ignore (view#append_column col);
  let col = GTree.view_column 
    ~title:"Artist"
    ~renderer:(GTree.cell_renderer_text [], ["text", artistBiblio]) () in
  col#set_min_width 150;
  ignore (view#append_column col);
  let col = GTree.view_column 
    ~title:"Path"
    ~renderer:(GTree.cell_renderer_text [], ["text", pathBiblio]) () in
  col#set_min_width 360;
  ignore (view#append_column col);
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

let openDialog filepath signal = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Chargement d'une musique"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `MEDIA_PLAY `MEDIA_PLAY;
  dlg#add_button_stock (`STOCK "Add Biblio") (`STOCK "Add Biblio");
  let tmp = dlg#run () in
  if tmp = (`STOCK "Add Biblio") then
    begin
      filepath := str_op(dlg#filename);
      signal := "biblio"
    end
  else
    begin
      if tmp = `MEDIA_PLAY then
        begin
          filepath := str_op(dlg#filename);
          signal := "play";
        end
      else
        begin
          if tmp = `CANCEL then
            begin
              signal := "cancel"
            end;
        end;
    end;
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
