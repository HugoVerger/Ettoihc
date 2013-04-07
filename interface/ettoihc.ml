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

let playlist =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing: lecturePage#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
    ~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(* Contenu onglet 2 *)

let biblioPage =
  let onglet2 = GPack.vbox () in
  let name1 = GMisc.label
    ~text:"Bibliotheque" () in
  ignore(notebook#insert_page 
    ~tab_label:name1#coerce onglet2#coerce);
  GPack.vbox
    ~packing:onglet2#add()

let biblioText =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing: biblioPage#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
    ~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(*
let biblioTable = 
  let scroll = GBin.scrolled_window
    ~height:200
    ~hpolicy:`ALWAYS
    ~vpolicy:`ALWAYS
    ~packing:biblioPage#add () in
  GPack.table
    ~row_spacings:1
    ~col_spacings:0
    ~border_width:1
    ~homogeneous:false
    ~packing:scroll#add_with_viewport ()*)

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
