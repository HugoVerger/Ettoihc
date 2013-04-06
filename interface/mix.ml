let distortion =
  let dbut = GButton.button
    ~show:true
    ~label:"Distorsion"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(dbut#connect#clicked ~callback:Wrap.distortion_sound);
  dbut

let amelioration =
  let abut = GButton.button
    ~show:true
    ~label:"Amélioration du son"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(abut#connect#clicked ~callback:Wrap.amelio_sound);
  abut

let flange=
  let fbut = GButton.button
    ~show:true
    ~label:"Flange"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(fbut#connect#clicked ~callback:Wrap.flange_sound);
  fbut

let chorus =
  let cbut = GButton.button
    ~show:true
    ~label:"Chorus"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(cbut#connect#clicked ~callback:Wrap.chorus_sound);
  cbut

let echo =
  let ebut = GButton.button
    ~show:true
    ~label:"Echo"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(ebut#connect#clicked ~callback:Wrap.echo_sound);
  ebut

let lowpass=
  let lbut = GButton.button
    ~show:true
    ~label:"Low Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(lbut#connect#clicked ~callback:Wrap.lpasse_sound);
  lbut

let highpass=
  let hbut = GButton.button
    ~show:true
    ~label:"High Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(hbut#connect#clicked ~callback:Wrap.hpasse_sound);
  hbut
