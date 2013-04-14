let _ =
  Wrap.init_sound();
  ignore(Ettoihc.window#event#connect#delete Ettoihc.confirm);
  ignore(Header.btnpause#connect#clicked
    (fun () -> Header.btnplay#misc#show (); Header.btnpause#misc#hide ();
               Ettoihc.pause := true; Wrap.pause_sound ()));
  ignore(Header.btnplay#connect#clicked
  	(fun () -> if (!Current.filepath = "") then () else
          begin
            Header.btnpause#misc#show (); Header.btnplay#misc#hide ();
            Current.play (); Header.play ()
          end));
  ignore(Ettoihc.playlistView#connect#row_activated
            ~callback: (Current.on_row_activated Ettoihc.playlistView));
  ignore(Ettoihc.playlistView#event#connect#button_press
            ~callback:(Current.on_button_pressed Ettoihc.playlistView));
  ignore(Ettoihc.biblioView#connect#row_activated
            ~callback: (Database.on_row_activated Ettoihc.biblioView));
  Ettoihc.play := (fun () ->
    Header.btnpause#misc#show (); Header.btnplay#misc#hide (); Header.play ());
  Ettoihc.stop := (fun () ->
    Header.btnpause#misc#hide (); 
    Header.btnplay#misc#show (); 
    Header.actDisplay "");
  Header.btnpause#misc#hide ();
  Database.startBiblio ();
  Ettoihc.window#show ();
  GMain.main ();
  Wrap.destroy_sound ()
