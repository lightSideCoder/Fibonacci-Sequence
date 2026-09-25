default rel

section .data
	buf:	times 24 db 0		;wir reservieren 24 bytes
	newl:	db 0xa			;wir initialisieren 1 byte für new Line

section .text
global _start

_start:
	lea		rsi, [buf + 23]	;rsi zeigt aufs Ende des Buffers
	mov byte	[rsi], 0	;schreibt '\0' (1 byte)
	xor		r15, r15	;erste fibo-nummer ist 0
	mov		r14, 1		;zweite fibo-nummer ist 1

	mov		rdi, 10		;Vorbereitung für Division (itoa)

itoa: 					;macht aus Bytes eine Dezimalzahl.
;In:	rax = Zahl in Binär, rdi = 0
;Out:	rax = Ergebnis der Division, rdx = Rest der Division

	xor		rdx, rdx	;rdx muss 0 sein für eine korrekte Division
	div		rdi		;Ergebnis geht in rax, Rest geht in rdx
	add		rdx, 48		;addiert 48 (0x30) auf die Binärzahl. Lädt den Wert in rdx
	dec		rsi		;rsi zeigt auf eine Stelle weiter im Buffer
	mov byte	[rsi], dl	;lädt rdx (1 byte) in den Buffer
	cmp		rax, 0		;ist rax == 0 ?
	jne		itoa		;falls noch nicht fertig, gehe an den Anfang der Funktion

buflen:					;errechnet die Länge unserer ascii-Zahl, relativ zum '\0' am Ende
;In:	rsi = Bufferpointer
;Out:	r13 = Anzahl der Ziffern unserer ascii-Zahl

	mov		cl, [rsi]	;lädt den Byte, auf den rsi zeigt in rcx
	cmp		cl, 0		;ist dieser Byte '\0' ?
	je		print		;falls ja gehen wir zu 'print', falls nicht einfach weiter machen:
	inc		r13		;incrementet r13. Verfolgt wie viele 'nicht NULL-Bytes' wir zählen
	inc		rsi		;rsi zeigt auf die nächste Stelle im Buffer
	jmp		buflen		;geht an den Anfang der Funktion

print:					;ganz klassisch: schreibt unseren Buffer auf stdout
;In:	rsi = Bufferpointer, r13 = Anzahl der Bytes, die wir schreiben
;Out:	rax = Anzahl der geschriebenen Bytes

	sub		rsi, r13	;da rsi gerade aufs Ende zeigt ('\0'), addieren wir r13 > rsi zeigt auf Anfang des Buffers
	mov		rax, 1		;fd = stdout
	mov		rdi, 1		;sys write
	mov		rdx, r13	;Anzahl der Bytes
	syscall
	add		rsi, r13	;rsi zeigt aufs Ende des Buffers
	xor		r13, r13	;counter wieder auf 0

printNewL:				;schreibt 'Enter' ans Ende einer Dezimalzahl
;In:	rdi = sys write (1)
;Out:	rax = Anzahl der geschriebenen Bytes

	mov		rax, 1		;fd = stdout
	mov		rdx, 1		;Anzahl der zu schreibenden Bytes
	mov		r12, rsi	;temporäres Speichern der Bufferadresse in r12
	mov		rsi, newl	;rsi zeigt auf 'newl'-Buffer
	syscall
	mov		rsi, r12	;r12 wieder in rsi laden

calcFibo:				;hier errechnen wir die nächste Zahl der Fibonacci-Reihe, die letzten beiden Zahlen addiert ergeben die neue Zahl
;In:	r15 (a) = alte, hohe Zahl, r14 (b) = alte, niedrige Zahl
;Out:	r15 = neue, hohe Zahl, r14 = neue, niedrige Zahl

	mov		r11, r15	;c = a		> temp a in c speichern
	add		r15, r14	;a = a + b	> neue, hohe Zahl
	mov		r14, r11	;b = c		> neue, niedrige Zahl (alte, hohe Zahl)

evalProgress:				;wir evaluieren, wie viele Zahlen wir schon haben und setzen ein Maximum

	inc		r10		;zählt bereits geschriebene Zahlen
	cmp		r10, 50		;Wenn wir 50 Zahlen geschrieben haben:
	je		exit		;gehe zu 'exit', ansonsten einfach weiter machen:

	mov		rax, r15	;rax mit neuer Zahl füllen, Vorbereitung für itoa > buflen > print
	mov		rdi, 10		;Vorbereitung für Division
	jmp		itoa		;mit neuen Werten gehen wir wieder zu itoa

exit:
	mov		rax, 60
	mov		rdi, 0
	syscall

