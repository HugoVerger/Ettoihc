                    (** Interface **)

(** Main Window **)

let window =
  ignore(GMain.init ());
  GWindow.window
    ~title:"Ettoihc"
    ~position:`CENTER
    ~resizable:false
    ~width:870
    ~height:500 ()

let mainbox =
  let box = GPack.vbox
    ~border_width:10
    ~packing:window#add () in
  box#set_homogeneous false;
  box

let header = GPack.vbox
  ~homogeneous: false
  ~height: 95
  ~border_width: 0
  ~packing:(mainbox#pack ~expand:false) ()

let core = GPack.notebook
  ~packing: mainbox#add()


(** Window Open **)

let openDlg () =
  let filter = GFile.filter
    ~name:"Music File"
    ~patterns:(["*.mp3";"*.m3u"]) () in
  let dlg = GWindow.file_chooser_dialog
    ~action: `OPEN
    ~parent: window
    ~position: `CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent: true () in
  dlg#set_filter filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `MEDIA_PLAY `MEDIA_PLAY;
  dlg#add_button_stock (`STOCK "Add Library") (`STOCK "Add Library");
  dlg


(** Window Save **)

let save () = 
  let dlg = GWindow.file_chooser_dialog
    ~action: `SAVE
    ~parent: window
    ~position: `CENTER_ON_PARENT
    ~title: "Save of the playlist"
    ~destroy_with_parent: true () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_select_button_stock `SAVE `SAVE;
  dlg

(** Window Search **)

let search () = 
  let music_filter = GFile.filter
    ~name: "Music File"
    ~patterns: (["*.mp3";"*.m3u"]) () in
  let dlg = GWindow.file_chooser_dialog
    ~action: `OPEN
    ~parent: window
    ~position: `CENTER_ON_PARENT
    ~title: "Select a music"
    ~destroy_with_parent: true () in
  dlg#set_filter music_filter;
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `OK `OK;
  dlg


(** Window Edition Tag **)

let tagViewList = ref []

let tag () =
  tagViewList := [];
  let dlg = GWindow.dialog
    ~parent: window
    ~destroy_with_parent: true
    ~title: "Edit Tag"
    ~show: true
    ~width: 300
    ~height: 400
    ~position: `CENTER_ON_PARENT () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `SAVE `SAVE;
  
  let names = [| "Number"; "Title"; "Artist"; "Album"; "Year"; "Genre"; "Comment" |] in

  for i = 0 to 6 do

    let b = GPack.hbox
      ~homogeneous: false
      ~height: 10
      ~border_width: 10
      ~packing: dlg#vbox#add () in
    ignore(GMisc.label
      ~width: 80
      ~height: 10
      ~text: names.(i)
      ~packing: b#add ());
    let view = GText.view
      ~width: 110
      ~editable: true
      ~cursor_visible: true
      ~packing: b#add () in
  tagViewList := view :: !tagViewList;

  done;
  tagViewList := List.rev !tagViewList;
  dlg


(** Window Properties **)

let properties () = 
  let dlg = GWindow.dialog
    ~parent: window
    ~destroy_with_parent: true
    ~show: true
    ~title: "Properties"
    ~width: 200
    ~height: 350
    ~position: `CENTER_ON_PARENT () in
  dlg#add_button_stock `CANCEL `CANCEL;
  dlg#add_button_stock `SAVE `SAVE;
  dlg

let frameButton dlg = 
  let frame = GBin.frame 
  ~label: "Library Columns"    
  ~packing: dlg#vbox#add () in
  let bbox = GPack.button_box `VERTICAL
    ~spacing: 10
    ~border_width: 5
    ~packing: frame#add () in

  let l = ref [] in

  let b = GButton.check_button
    ~label: "Title"
    ~packing: bbox#add () in
  l := b :: !l;
  let b = GButton.check_button
    ~label: "Artist"
    ~packing: bbox#add () in
  l := b :: !l;
  let b = GButton.check_button
    ~label: "Album"
    ~packing: bbox#add () in
  l := b :: !l;
  let b = GButton.check_button
    ~label: "Genre"
    ~packing: bbox#add () in
  l := b :: !l;
  let b = GButton.check_button
    ~label: "Path"
    ~packing: bbox#add () in
  l := b :: !l;
  !l

let frameColor dlg = 
  let frame = GBin.frame ~label:"Spectre colors"    
    ~packing:dlg#vbox#add () in
  let bbox = GPack.button_box `VERTICAL
    ~spacing:10
    ~border_width:5
    ~packing:frame#add () in

  let l = ref [] in

  let btn = GButton.button ~label:"Change Bars" ~packing:bbox#add () in
  ignore(GMisc.image ~stock:`COLOR_PICKER ~packing:btn#set_image ());
  l := btn :: !l ;

  let btn = GButton.button ~label:"Change Background" ~packing:bbox#add () in
  ignore(GMisc.image ~stock:`COLOR_PICKER ~packing:btn#set_image ());
  btn :: !l

let colorSelect () = GWindow.color_selection_dialog
  ~parent:window
  ~destroy_with_parent:true
  ~position:`CENTER_ON_PARENT ()


(** Window Warning : File Missing **)

let missing () = GWindow.message_dialog
  ~title: "File Not Found"
  ~message: "<b><big>File Not Found</big>\nDo you want to search it ?</b>\n"
  ~parent: window
  ~destroy_with_parent: true
  ~use_markup: true
  ~message_type: `ERROR
  ~position: `CENTER_ON_PARENT
  ~buttons: GWindow.Buttons.ok_cancel ()


(** Window About **)

let about = GWindow.about_dialog
  ~authors: ["Nablah"]
  ~version: "1.1"
  ~website: "http://ettoihc.wordpress.com/"
  ~website_label: "Ettoihc Website"
  ~position: `CENTER_ON_PARENT
  ~parent: window
  ~width: 400
  ~height: 150
  ~destroy_with_parent: true ()


(** Window Quit **)

let confirm () = GWindow.message_dialog
  ~message: "<b><big>Do you really want to quit ?</big></b>\n"
  ~parent: window
  ~destroy_with_parent: true
  ~use_markup: true
  ~message_type: `QUESTION
  ~position: `CENTER_ON_PARENT
  ~buttons: GWindow.Buttons.yes_no ()
