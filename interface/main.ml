let timer = GMain.Timeout.add ~ms:10 ~callback:(fun () -> 
  if (!Header.timeSet) then
    Header.actTimeLine ();
  Current.reset_draw ();
  if not (!Ettoihc.pause) then
    Current.set_draw ();
  if (!Header.lengthSong = !Header.timeSong) then
    Header.suivant ();
  true)

let _ =
  Wrap.init_sound();
  ignore(Ettoihc.window#event#connect#delete Ettoihc.confirm);
  ignore(Ettoihc.playlistView#connect#row_activated
            ~callback: (Current.on_row_activated Ettoihc.playlistView));
  ignore(Ettoihc.playlistView#event#connect#button_press
            ~callback:(Current.on_button_pressed Ettoihc.playlistView));
  ignore(Ettoihc.biblioView#connect#row_activated
            ~callback: (Database.on_row_activated Ettoihc.biblioView));
  ignore(Ettoihc.biblioView#event#connect#button_press
            ~callback:(Database.on_button_pressed Ettoihc.biblioView));
  Header.connectMenu ();
  Header.btnpause#misc#hide ();
  Database.startBiblio ();
  Mix.startEqualizer ();
  Ettoihc.window#show ();
  GMain.main ();
  Mix.printEqualizer ();
  Biblio.saveBiblio ();
  Wrap.destroy_sound ()
