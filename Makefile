################### Tools #####################
BIN=bin/ettoihc
_DATE=${shell date +%Y-%m-%e_%p-%Ih%M}
BAKF=${_DATE}-Prog

################# C Compilation #################
CC= clang
CFLAGS= -W -Wall -Werror -pedantic -std=c99 -O2 -I  `ocamlc -where`
CS= src/wrap.c src/lecture.c src/effects.c src/playlist.c
HS=${CS:.c=.h}
OS=${CS:.c=.o}
CO=  wrap.o lecture.o effects.o playlist.o
.SUFFIXES: .c .h

############### Compilation OCaML ###############
OFLAGS= -I +lablgtk2 -I src -I fmod/inc -I fmod/lib
OLIB=-cclib -lfmodex64
OCOPT=ocamlopt
OCAMLC=ocamlc
CMXA= lablgtk.cmxa bigarray.cmxa
CMA=lablgtk.cma bigarray.cma 
ML= src/wrap.ml src/meta.ml src/playlist.ml src/ettoihc.ml src/interface.ml
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
	${CC} ${CFLAGS} -c  ${CS}
	${OCAMLC} -custom ${OFLAGS} -o ${BIN} ${CO} ${CMA} ${ML} -cclib fmod/lib/libfmodex64.so

depend: .depend
.depend: ${ML} ${MLI}
	rm -f .depend
	${OCAMLDEP} ${ML} ${MLI} > .depend

clean::
	cd src/ && rm -f *~ *# *.cm?
	rm -f *~ *# *.o *.cm? ${BIN}
