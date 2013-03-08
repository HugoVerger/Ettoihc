# DEBUT

PRG= ettoihc

OCAML=ocamlopt
OCAMLFLAGS= -I +sdl -I +lablgtk2
OCAMLLD= lablgtk.cmxa

ML= main.ml

CMX=${ML:.ml=.cmx}

main: main.ml
	${OCAML} ${OCAMLFLAGS} ${OCAMLLD} -o ${PRG} ${ML}

clean:
	rm -f *~ *.o *.cm? main

# FIN
