################### Tools #####################
BIN=bin/ettoihc
_DATE=${shell date +%Y-%m-%e_%p-%Ih%M}
BAKF=${_DATE}-Prog

################# C Compilation #################
CC= gcc
CFLAGS= -W -Wall -Werror -std=c99 -O2 -I  `ocamlc -where` -lfmodex64
CS= src/lecture.c src/spectre.c src/playlist.c
HS=${CS:.c=.h}
OS=${CS:.c=.o}
CO= lecture.o spectre.o playlist.o
.SUFFIXES: .c .h

############### Compilation OCaML ###############
OFLAGS= -I +lablgtk2 -I +sdl -I src
OLIB=-cclib -lfmodex64
OCOPT=ocamlopt
OCAMLC=ocamlc
CMXA= lablgtk.cmxa bigarray.cmxa sdl.cmxa sdlloader.cmxa
CMA=lablgtk.cma bigarray.cma sdl.cma sdlloader.cma
ML= src/meta.ml src/ettoihc.ml
MLI=${ML:.ml=.mli}
CMO=${ML:.ml=.cmo}
CMX=${ML:.ml=.cmx}
CMI=${MLI:.mli=.cmi}
CMA=${CMXA:.cmxa=.cma}

.SUFFIXES: .ml .mli .cmo .cmx .cmi .o .c

.ml.cmx:
	${OCOPT} -c ${OFLAGS} ${CMA} $<
.ml.cmo:
	${OCAMLC} -c ${OFLAGS} ${CMA} $<

.ml.mli:
	${OCAMLC} -i ${CMA} $< > $@
.c.o:
	${CC} -c  $<


################## Compilation Rules ###############################
all: Ettoihc

Ettoihc:
	${CC} ${CFLAGS} -c ${CS}
	${OCAMLC} -custom ${OFLAGS} -o ${BIN} ${CO} ${CMA} ${ML} ${OLIB}
	${OCAMLC} -custom ${OFLAGS} -o bin/spectre ${CO} ${CMA} src/spectre.ml ${OLIB}
	cd src && rm -f *.cm? *.o *~
	rm -f *.cm? *.o *~

depend: .depend
.depend: ${ML} ${MLI}
	rm -f .depend
	${OCAMLDEP} ${ML} ${MLI} > .depend

clean::
	rm -f *~ *# *.o *.cm? ${BIN}
