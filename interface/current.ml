let filepath = ref ""
let indexSong = ref 0
let playListForDisplay = ref ""
let playListFile = ref []

let play () =
  if (List.length !playListFile != 0 && 
  	(!Ettoihc.pause || (!filepath != List.nth !playListFile !indexSong))) then
      filepath := List.nth !playListFile !indexSong

let launchPlaylist filedisplay =
  Ettoihc.openDialog filepath;
  if (Playlist.get_extension !filepath) then
    Playlist.addSong !filepath filedisplay playListForDisplay
                      Ettoihc.playListForSave playListFile
  else
    begin
      Playlist.cleanPlaylist playListForDisplay Ettoihc.playListForSave
                             playListFile indexSong;
      Wrap.stop_sound();
    	Playlist.addPlaylist !filepath filedisplay playListForDisplay
    	                      Ettoihc.playListForSave playListFile
    end;
  Ettoihc.playlist#buffer#set_text (!playListForDisplay)
