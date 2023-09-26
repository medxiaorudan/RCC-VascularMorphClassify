all: point_alignments alignments2eps

point_alignments: point_alignments.c point_alignments.h point_alignments_cmd.c
	cc -O3 -o point_alignments point_alignments_cmd.c point_alignments.c -lm

alignments2eps: alignments2eps.c
	cc -o alignments2eps alignments2eps.c -lm

test:
	./point_alignments data.txt 1 1 out.txt
	./alignments2eps data.txt out.txt 1 1 500 1.75 2 1 1 8 out.eps
	pstopdf out.eps
	./alignments2eps data.txt out.txt 1 1 500 1.75 2 0 0 0 out_simple.eps
	pstopdf out_simple.eps

cleanall: clean clean_test

clean:
	rm point_alignments alignments2eps

clean_test:
	rm out.txt
	rm out.eps
	rm out.pdf
	rm out_simple.eps
	rm out_simple.pdf
