let quit _ =
  let dlg = Ui.confirm () in
  let tmp = dlg#run () = `NO in
  dlg#destroy ();
  tmp

let openFun () =
  let str_op = function
    |Some x -> x
    |_ -> failwith "Need a file" in

  let dlg = Ui.openDlg () in

  let tmp = dlg#run () in
  if tmp = (`STOCK "Add Library") then
    Biblio.add (str_op(dlg#filename));
  if tmp = `MEDIA_PLAY then 
    Playlist.add (str_op(dlg#filename));

  dlg#destroy ()


let timer = GMain.Timeout.add ~ms:10 ~callback:(fun () ->
  if not (!Header.pause) then
    begin
      Header.actTimeLine ();
      Draw.reset ();
      Draw.drawSpectre ()
    end;
  if (!Header.length = !Header.time) then
    Header.next ();
  true)

let _ =
  (* Initialisation *)
  Random.init 42;
  Wrap.init_sound();
  Effects.startEqualizer ();
  Biblio.loadBiblio ();

  ignore(Ui.window#connect#destroy GMain.quit);
  ignore(Ui.window#event#connect#delete quit);
  ignore(UiHeader.openB#connect#clicked openFun);
  Header.connectUI ();
  Playlist.connectSort ();
  Playlist.connectUI ();
  Biblio.connectSort ();
  Biblio.connectUI ();
  Effects.connectUI ();

  Ui.window#show ();
  GMain.main ();

  (* End of the program *)
  Effects.printEqualizer ();
  Biblio.saveBiblio ();
  Wrap.destroy_sound ()
