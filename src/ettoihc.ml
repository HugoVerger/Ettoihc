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



(* Boites de la fenêtre principale *)

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
  
let toolbar = GButton.toolbar  
	~orientation:`HORIZONTAL  
	~style:`BOTH
	~width:490
	~height:10
	~packing:(menubox#pack ~expand:false) ()

let volbox = GPack.hbox
	~width: 90
	~packing:(menubox#pack ~expand:false) ()
	
let infobar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:60
  ~packing:(menubox#pack ~expand:false) ()

let centerbox = 
  let box = GPack.hbox
    ~height: 20
    ~packing:(mainbox#pack ~expand:false) () in
  box#set_homogeneous false;
  box
    

let notebook =GPack.notebook
  ~packing: mainbox#add()
  
let page1box = GPack.hbox ()
let ajout_tab1 =
  let name1 = GMisc.label
    ~text:"En cours" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page1box#coerce

let page2box = GPack.vbox ()
let ajout_tab2 =
  let name1 = GMisc.label
    ~text:"Bibliotheque" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page2box#coerce

let page3box = GPack.vbox ()
let ajout_tab3 =
  let name1 = GMisc.label
    ~text:"Effets" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page3box#coerce 

let mixPage = GPack.vbox
  ~packing:page3box#add()

let mixFrame1 =GBin.frame
  ~width:800
  ~height:250
  ~border_width:0
  ~packing:mixPage#add ()

let mixFrame2 =GBin.frame
  ~width:800
  ~height:250
  ~border_width:0
  ~packing:mixPage#add ()
  
let firstLine =GPack.button_box `HORIZONTAL
  	~layout:`SPREAD
  	~packing:mixFrame1#add()
let secondLine =GPack.button_box `HORIZONTAL
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
