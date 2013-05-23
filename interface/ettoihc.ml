let pause = ref true
let random = ref false
let biblioForSave = ref ""
let playListForSave = ref ""
let play = ref (fun () -> ())
let stop = ref (fun () -> ())

let str_op = function
  | Some x -> x
  | _ -> failwith "Need a file"

(* Fenêtre principale *)

let window =
  ignore(GMain.init ());
  let wnd = GWindow.window
    ~title:"Ettoihc"
    ~position:`CENTER
    ~resizable:false
    ~width:800
    ~height:500 () in
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

let timeLinebox =
  let box = GPack.hbox
    ~height: 15
    ~packing:(mainbox#pack ~expand:false) () in
  box#set_homogeneous false;
  box

let notebook = GPack.notebook
  ~packing: mainbox#add()


(* Contenu onglet 1 *)

let lecturePage =
  let onglet1 = GPack.hbox () in
  let name1 = GMisc.label
    ~text:"Now Playing" () in
  ignore(notebook#insert_page
    ~tab_label:name1#coerce onglet1#coerce);
  GPack.hbox
    ~packing:onglet1#add()

let scrollPlaylist = GBin.scrolled_window
  ~hpolicy:`ALWAYS
  ~vpolicy:`ALWAYS
  ~packing:lecturePage#add ()

let colsPlaylist = new GTree.column_list
let nmbPlaylist = colsPlaylist#add Gobject.Data.int
let randomPlaylist = colsPlaylist#add Gobject.Data.int
let songPlaylist = colsPlaylist#add Gobject.Data.string
let artistPlaylist = colsPlaylist#add Gobject.Data.string
let pathPlaylist = colsPlaylist#add Gobject.Data.string

let storePlaylist = GTree.list_store colsPlaylist

let playlistNmb =
  let col = GTree.view_column
    ~renderer:(GTree.cell_renderer_text [], ["text", nmbPlaylist]) () in
  col#set_min_width 20;
  col
let playlistRandom =
  let col = GTree.view_column
    ~renderer:(GTree.cell_renderer_text [], ["text", randomPlaylist]) () in
  col#set_min_width 20;
  col
let playlistView =
  let model = storePlaylist in
  let view = GTree.view 
    ~model
    ~height:350
    ~width:350 
    ~packing: scrollPlaylist#add () in
  ignore (view#append_column playlistNmb);
  playlistRandom#set_visible false;
  ignore (view#append_column playlistRandom);
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
  ignore(GTree.view_column
    ~title:"Path"
    ~renderer:(GTree.cell_renderer_text [], ["text", pathPlaylist]) ());
  view

let drawing_area =
  GMisc.drawing_area
    ~width:512
    ~height:350
    ~packing: lecturePage#add ()

(* Contenu onglet 2 *)

let biblioPage =
  let onglet2 = GPack.vbox () in
  let name1 = GMisc.label
    ~text:"Library" () in
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
let albumBiblio = colsBiblio#add Gobject.Data.string
let genreBiblio = colsBiblio#add Gobject.Data.string
let pathBiblio = colsBiblio#add Gobject.Data.string

let storeBiblio = GTree.list_store colsBiblio

let colName =
  let col = GTree.view_column
    ~title:"Song"
    ~renderer:(GTree.cell_renderer_text [], ["text", songBiblio]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col
let colArtist =
  let col = GTree.view_column
    ~title:"Artist"
    ~renderer:(GTree.cell_renderer_text [], ["text", artistBiblio]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col
let colAlbum =
  let col = GTree.view_column
    ~title:"Album"
    ~renderer:(GTree.cell_renderer_text [], ["text", albumBiblio]) () in
  col#set_min_width 150;
  col#set_clickable true;
  col
let colGenre =
  let col = GTree.view_column
    ~title:"Genre"
    ~renderer:(GTree.cell_renderer_text [], ["text", genreBiblio]) () in
  col#set_min_width 50;
  col#set_clickable true;
  col
let colPath =
  let col = GTree.view_column
    ~title:"Path"
    ~renderer:(GTree.cell_renderer_text [], ["text", pathBiblio]) () in
  col#set_min_width 290;
  col#set_clickable true;
  col
let biblioView =
  let model = storeBiblio in
  let view = GTree.view ~model ~packing: scrollBiblio#add () in
  ignore (view#append_column colName);
  ignore (view#append_column colArtist);
  ignore (view#append_column colAlbum);
  ignore (view#append_column colGenre);
  ignore (view#append_column colPath);
  view

(* Contenu onglet 3 *)

let mixPage =
  let onglet3 = GPack.vbox () in
  let name1 = GMisc.label
    ~text:"Effects" () in
  ignore(notebook#insert_page
    ~tab_label:name1#coerce onglet3#coerce);
  GPack.vbox
    ~homogeneous:false
    ~packing:onglet3#add()

let boxLine1 =
  GPack.hbox ~packing:mixPage#add ()

let firstLineBox1 =
  let mixFrame1 = GBin.frame
    ~width:80
    ~height:260
    ~border_width:0
    ~packing:boxLine1#add () in
  GPack.button_box `HORIZONTAL
    ~layout:`SPREAD
    ~packing:mixFrame1#add()

let mixFrame1 =GBin.frame
  ~height:260
  ~width:420
  ~border_width:0
  ~packing:boxLine1#add ()

let firstLineBox2Vbox = GPack.vbox
  ~homogeneous:false
  ~packing:mixFrame1#add()

let boxMenuMix = GPack.hbox
  ~homogeneous:false
  ~height:15
  ~packing:firstLineBox2Vbox#add ()

let boxEqualizerMix = GPack.hbox
    ~spacing:5
    ~border_width:10
    ~packing:firstLineBox2Vbox#add()

let secondLine =
  let mixFrame2 =GBin.frame
    ~width:300
    ~height:100
    ~border_width:0
    ~packing:mixPage#add () in
  let bb = GPack.button_box `HORIZONTAL
    ~layout:`SPREAD
    ~packing:mixFrame2#add() in
  bb#set_homogeneous false;
  bb

(* Fenêtre d'ouverture *)

let music_filter = GFile.filter
  ~name:"Music File"
  ~patterns:(["*.mp3";"*.m3u"]) ()

let openDialog filepath signal = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `MEDIA_PLAY `MEDIA_PLAY;
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
    ~title:"Save of the playlist"
    ~destroy_with_parent:true () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `SAVE `SAVE;
  if  (dlg#run () = `SAVE) then
       Wrap.playlistSave (str_op(dlg#filename)) !playListForSave;
  dlg#misc#hide ()

(* Fenêtre de préférence *)

let pref () =
  let dlg = GWindow.dialog
    ~parent:window
    ~destroy_with_parent:true
    ~title:"Properties"
    ~show:true
    ~width:200
    ~height:300
    ~position:`CENTER_ON_PARENT () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `SAVE `SAVE;
  let frame_horz = GBin.frame ~label:"Library Columns"    
    ~packing:dlg#vbox#add () in
  let bbox = GPack.button_box `VERTICAL
    ~spacing:10
    ~border_width:5
    ~packing:frame_horz#add () in
  let titlebtn = GButton.check_button 
    ~active:colName#visible
    ~label:"Title"
    ~packing:bbox#add () in
  let artistbtn = GButton.check_button 
    ~active:colArtist#visible
    ~label:"Artist"
    ~packing:bbox#add () in
  let albumbtn = GButton.check_button 
    ~active:colAlbum#visible
    ~label:"Album"
    ~packing:bbox#add () in
  let genrebtn = GButton.check_button 
    ~active:colGenre#visible
    ~label:"Genre"
    ~packing:bbox#add () in
  let pathbtn = GButton.check_button 
    ~active:colPath#visible
    ~label:"Path"
    ~packing:bbox#add () in
  let tmp = dlg#run () in
  if (tmp = `SAVE) then
    begin
      colName#set_visible (titlebtn#active);
      colArtist#set_visible (artistbtn#active);
      colAlbum#set_visible (albumbtn#active);
      colGenre#set_visible (genrebtn#active);
      colPath#set_visible (pathbtn#active);
    end;
    dlg#misc#hide ();
  ()

(* Fenêtre de confirmation de sortie *)

let confirm _ =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>Do you really want to quit ?</big></b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  if not res then
    Wrap.biblioSave !biblioForSave;
  res

(* Fenêtre de problème biblio/playlist *)

let prob () =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>File Not Found</big>\nDo you want to search it ?</b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`ERROR
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.ok_cancel () in
  let res = dlg#run () = `CANCEL in
  dlg#destroy ();
  res

(* Fenêtre de recherche *)

let searchDialog () = 
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent:true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `OK `OK;
  let tmp = dlg#run () in
  dlg#misc#hide ();
  if tmp = `OK then
    ("ok", str_op(dlg#filename))
  else
    ("", "")

(* Fenêtre About *)

let about = GWindow.about_dialog
    ~authors:["Nablah"]
    ~version:"1.1"
    ~website:"http://ettoihc.wordpress.com/"
    ~website_label:"Ettoihc Website"
    ~position:`CENTER_ON_PARENT
    ~parent:window
    ~width: 400
    ~height: 150
    ~destroy_with_parent:true ()

let get_extension s =
  let ext = String.sub s ((String.length s) - 4) 4 in
  match ext with
    |".mp3"-> true
    |_ -> false
