(*let openFun () =
  let signal = ref "cancel" in
  Ettoihc.openDialog Current.filepath signal;
  if not (!signal = "cancel") then
    begin
      if !signal = "biblio" then*)
        if not (Sys.is_directory !Current.filepath) then
          (*Database.checkBiblio ()*)
        else
          begin
            let tmp = !Current.filepath in
            Array.iter (fun a -> Current.filepath := tmp ^"/"^ a;
                                 Database.checkBiblio ())
                       (Sys.readdir !Current.filepath);
          end
      else
        (*begin
          if !signal = "play" then
            begin
              if not (Sys.is_directory !Current.filepath) then
                begin
                  Current.indexSong := !Playlist.nbSong - 1;
                  Current.launchPlaylist ();
                  Current.indexSong := !Current.indexSong + 1;
                  Current.play();
                  !Ettoihc.play ()
                end
              else
                begin
                  let tmp = !Current.filepath in
                  Current.indexSong := !Playlist.nbSong - 1;
                  Array.iter (fun a -> Current.filepath := tmp ^"/"^ a;
                                       Current.launchPlaylist ())
                             (Sys.readdir !Current.filepath);
                  if not (!Current.indexSong = !Playlist.nbSong - 1) then
                    begin
                      Current.indexSong := !Current.indexSong + 1;
                      Current.play();
                      !Ettoihc.play ()
                    end
                end
            end
        end*)
    end
