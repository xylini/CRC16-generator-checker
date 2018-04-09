;Jakub Pajor WIEiT 2017
;CRC16 generator and checker
;sample input: [programname] [file_input_name] [file_output_name]
;ex.: CRC16generator.exe FILETOHASH.txt FILEWITHHASH.txt

.286
data segment
	argv db 200 dup ('$')
	argb db 10 dup ('$') 	;przechowuje ilosc znakow wraz z poczatkowa spacja
	args db 10 dup ('$')	;przechowuje w kolejnych bitach dlugosci argumentow
	args_il db 3 dup ('$')	;przechowuje ilosc argumentow
	
	zle_arg_1 db 	'Podano zly format argumentow.',13,10,
					'Prawidlowe formaty:',13,10,
					'nazwa_programu [input] [output] - dla obliczenia CRC',13,10,
					'nazwa_programu -v [input1] [input2] - dla sprawdzenia CRC intput1 i porownania z input2','$'
					
	plik_error db 	'Blad podczas przetwarzania plikow','$'
	
	to_samo_CRC db 'CRC sie zgadza','$'
	nie_to_samo_CRC db 'CRC sie rozni','$'
	
	file_name db 'plik.txt',0
	input1_CRC16 dw 0
	input2_CRC16 db 5 dup (0)
	
	input1_CRC16_string db 4 dup (?),0
	
	buffor db 64 dup (?)
	buffor_ile_wczytanych dw 0
	buffor_ktory_wczytany dw 0
	
	flaga_konca_pliku db 0
	
	uchwyt dw ?
	uchwyt_otwierany dw ?
	
	input1 db 127 dup ('$')		;tutaj zawsze input1
	input2 db 127 dup ('$') 	;jezeli dwa argumenty to to jest output, dla trzech input2
	
	
	;ponizej CRC dla kazdego znaku od 0 do 255 generowane przy uzyciu wielomianu 0x8005 czyli x^16 + x^15 + x^2 + 1, wartosc startowa 0x0000
	_0_255CRC	dw 	00000h, 0C0C1h, 0C181h, 00140h, 0C301h, 003C0h, 00280h, 0C241h, 0C601h, 006C0h, 00780h, 0C741h, 00500h, 0C5C1h, 0C481h, 00440h
				dw	0CC01h, 00CC0h, 00D80h, 0CD41h, 00F00h, 0CFC1h, 0CE81h, 00E40h, 00A00h, 0CAC1h, 0CB81h, 00B40h, 0C901h, 009C0h, 00880h, 0C841h
				dw	0D801h, 018C0h, 01980h, 0D941h, 01B00h, 0DBC1h, 0DA81h, 01A40h, 01E00h, 0DEC1h, 0DF81h, 01F40h, 0DD01h, 01DC0h, 01C80h, 0DC41h
				dw	01400h, 0D4C1h, 0D581h, 01540h, 0D701h, 017C0h, 01680h, 0D641h, 0D201h, 012C0h, 01380h, 0D341h, 01100h, 0D1C1h, 0D081h, 01040h
				dw	0F001h, 030C0h, 03180h, 0F141h, 03300h, 0F3C1h, 0F281h, 03240h, 03600h, 0F6C1h, 0F781h, 03740h, 0F501h, 035C0h, 03480h, 0F441h
				dw	03C00h, 0FCC1h, 0FD81h, 03D40h, 0FF01h, 03FC0h, 03E80h, 0FE41h, 0FA01h, 03AC0h, 03B80h, 0FB41h, 03900h, 0F9C1h, 0F881h, 03840h
				dw	02800h, 0E8C1h, 0E981h, 02940h, 0EB01h, 02BC0h, 02A80h, 0EA41h, 0EE01h, 02EC0h, 02F80h, 0EF41h, 02D00h, 0EDC1h, 0EC81h, 02C40h
				dw	0E401h, 024C0h, 02580h, 0E541h, 02700h, 0E7C1h, 0E681h, 02640h, 02200h, 0E2C1h, 0E381h, 02340h, 0E101h, 021C0h, 02080h, 0E041h
 				dw	0A001h, 060C0h, 06180h, 0A141h, 06300h, 0A3C1h, 0A281h, 06240h, 06600h, 0A6C1h, 0A781h, 06740h, 0A501h, 065C0h, 06480h, 0A441h
				dw	06C00h, 0ACC1h, 0AD81h, 06D40h, 0AF01h, 06FC0h, 06E80h, 0AE41h, 0AA01h, 06AC0h, 06B80h, 0AB41h, 06900h, 0A9C1h, 0A881h, 06840h
				dw	07800h, 0B8C1h, 0B981h, 07940h, 0BB01h, 07BC0h, 07A80h, 0BA41h, 0BE01h, 07EC0h, 07F80h, 0BF41h, 07D00h, 0BDC1h, 0BC81h, 07C40h
				dw	0B401h, 074C0h, 07580h, 0B541h, 07700h, 0B7C1h, 0B681h, 07640h, 07200h, 0B2C1h, 0B381h, 07340h, 0B101h, 071C0h, 07080h, 0B041h
				dw	05000h, 090C1h, 09181h, 05140h, 09301h, 053C0h, 05280h, 09241h, 09601h, 056C0h, 05780h, 09741h, 05500h, 095C1h, 09481h, 05440h
				dw	09C01h, 05CC0h, 05D80h, 09D41h, 05F00h, 09FC1h, 09E81h, 05E40h, 05A00h, 09AC1h, 09B81h, 05B40h, 09901h, 059C0h, 05880h, 09841h
				dw	08801h, 048C0h, 04980h, 08941h, 04B00h, 08BC1h, 08A81h, 04A40h, 04E00h, 08EC1h, 08F81h, 04F40h, 08D01h, 04DC0h, 04C80h, 08C41h
				dw	04400h, 084C1h, 08581h, 04540h, 08701h, 047C0h, 04680h, 08641h, 08201h, 042C0h, 04380h, 08341h, 04100h, 081C1h, 08081h, 04040h
				
	bytes       db "0123456789ABCDEF"
	
data ends

code segment

parse proc
	
	pusha
	
	mov bx,80h
	mov ch,[bx] 				;wrzucam ilosc bitów (PYTANIE: CZY JEST ICH RAZEM ZE SPACJA CZY MNIEJ XD)
	
	mov bx,82h   				;do bx'a wrzucam adres do pierwszego znaku z lini komend
	
	mov ax,seg data				;zapisuje do argb ilosc bitow w psp
	mov es,ax
	mov di,offset argb
	

	mov byte ptr es:[di],ch
	
	mov di,offset argv 			;es:di - argv[0]

	mov cl,1					;w cl mam licznik bialego znaku, na początek ustawiam 1, to zagwarantuje, że pominie te spacje przed argumentami
	
	wypisuj:
		mov dl,[bx]				;pobieram znak z lini
		
		cmp ch,0  			;sprawdzam czy to już nie koniec argumentow
		je koniec				;jeżeli tak to koniec roboty
		dec ch					;zmniejszam ilosc arg do wczytywania
		
		
		cmp dl,' '				;sprawdzam czy znak jest spacją
		je zjedz_biale
		
		cmp dl,'	' 			;sprawdzam czy znak jest tabem
		je zjedz_biale
		
		xor cl,cl				;skoro wypisywanie tutaj doszło, to znak nie jest spacją/tabem, więc zeruję licznik spacji
		mov byte ptr es:[di],dl ;wpisuję znak do tablicy
		
		inc di					;przesuwam adres na kolejny element w argv
		inc bx					;przesuwam adres na kolejny znak w argumentach
		
		jmp wypisuj				 ;powtarzam aż znajdzie koniec lini
		
	zjedz_biale:
		cmp cl,0 				;jeżeli spacja jest pierwszą jaka się pojawiła
		je newline				;to daję nową linię
		inc bx					;w przeciwnym wypadku przesuwam adres na kolejny znak w argumentach
		jmp wypisuj				;oraz zaczynam wypisuwanie od nowa
		
	newline:					;wrzuca do tablicy znak nowej linii i powrót do początku Dh i Ah
		mov byte ptr es:[di],'!';po każdym argumencje daje znak '!'
		inc di		
		
		inc cl					;zwiększam licznik spacji, gdyż pierwsza się już pojawiła
		inc bx					;kolejny adres w psp
		
		jmp wypisuj 			;wracam do wypisywania
	
	koniec:
	dec di
		mov byte ptr es:[di],'!'
		popa
		ret
			
parse endp


wypisz_args proc
		pusha
		mov	ax,seg data
		mov	ds,ax
		mov dx,offset input1_CRC16_string
		
		mov	ah,9  				; wypisz na ekran to co jest w ds:dx
		int	21h
		mov al,0
		popa
		ret
wypisz_args endp


policz_argumenty proc			;przechodzi przez argv, jest licznik cl który zlicza ilość znaków do '!', potem wpisuje do args, zeruje się i leci od nowa aż do znaku '$'
	pusha						;dodatkowo zlicza ich ilosc

	mov ax,seg data				;
	mov es,ax
	mov di,offset argv			;es:di - start argv	
	mov si,offset args			;es:si - start args
		
	xor cl,cl					;licznik dlugosci argumentow
	xor ch,ch					;licznik ilosci argumentow
	
	petla:
	mov dl,byte ptr es:[di]		;pobieram pierwszy znak z tablicy
	cmp dl,'$'
	je koniec_p
	
	cmp dl,'!'					;spra
	jne dodaj_licznik
	
	cmp dl,'!'
	je zapisz_dlugosc
	
	koniec_p:
	xor di,di
	mov di,offset args_il
	mov byte ptr es:[di], ch
	
	popa
	ret
	
	dodaj_licznik:
	inc cl
	inc di
	jmp petla
	
	zapisz_dlugosc:
	mov byte ptr es:[si],cl
	inc si
	inc di
	inc ch
	xor cl,cl
	jmp petla
	
policz_argumenty endp

sprawdz_argumenty proc
	pusha
	
	mov ax,seg data	
	mov es,ax
	
	sprawdz_czy_poprawne_3_arg:
		mov di,offset args_il	
		cmp byte ptr es:[di],3
		jne sprawdz_czy_dwa_arg
		
		mov di,offset argv
		cmp byte ptr es:[di],'-'
		jne zla_ilosc
		cmp byte ptr es:[di+1],'v'
		jne zla_ilosc
		jmp argumenty_ok
	
	sprawdz_czy_dwa_arg:
		mov di,offset args_il
		cmp byte ptr es:[di],2		;sprawdzam ilość podanych argumentów
		jne zla_ilosc
		
	argumenty_ok:
		jmp okej
	
	
zla_ilosc:
	mov	ax,seg data
	mov	ds,ax
	mov dx,offset zle_arg_1
	jmp message
	
okej:
	jmp koniec_m	

message:
	mov	ah,9  				; wypisz na ekran to co jest w ds:dx
	int	21h
	mov al,0
	call Ender

koniec_m:
	popa
	ret
	
sprawdz_argumenty endp

pobierz_nazwy_plikow proc		;zapisuje nazwy plikow z wszystkich argumentow do odpowiednich zmiennych
	push ax
	push cx
	push dx
	push es
	push di
	push si
	
	mov ax, seg data
	mov es, ax
	mov di,offset argv
	mov si,offset args_il
	cmp byte ptr es:[si],3							;sprawdzam czy mamy do czynienia z trzeba arg w psp, w innym wypadku musi byc ich dwa
	je	trzy_argumenty
	jmp dwa_argumenty
	
	
	koniec:											;koniec roboty
	pop si
	pop di
	pop es
	pop dx
	pop cx
	pop ax
	ret
	
	trzy_argumenty:
		pierwsza:
		add di,3									;jezeli wywoluje dla 3 argumentow to dodatkowo na start dodaje 3 aby trafic na poczatek pierwszego inputu
	dwa_argumenty:									;to sie wywol dla 2 arg w psp
		mov si,offset input1
		jmp wczytaj_zmienna_1
		
		druga:										;tym zapisuje drugi input/output
		inc di
		mov si,offset input2
		jmp wczytaj_zmienna_2		
		
		
		
		
	wczytaj_zmienna_1:								;wczytuje nazwe pliku do adresu w es:[si]
			mov dl,byte ptr es:[di]					;wczytuje znak z argv
			cmp dl,'!'								;sprawdzam czy nie koniec arg
			je zamknij_zmienna_1
			mov byte ptr es:[si],dl					;przepisuje znak do input1
			inc di									;dla kolejnego znaku w argv
			inc si									;dla kolejnego znaku w input1
			jmp wczytaj_zmienna_1					;powtarzam az napotka '!'
		
			zamknij_zmienna_1:
				inc si								;przesuwam input1 o 1 miejsce i dodaje na koniec NULL
				mov byte ptr es:[si],0
				jmp druga

	wczytaj_zmienna_2:								;wczytuje nazwe pliku do adresu w es:[si]
			mov dl,byte ptr es:[di]					;wczytuje znak drugiego adresu z argv
			cmp dl,'!'								;sprawdzam czy nie koniec arg
			je zamknij_zmienna_2	
			mov byte ptr es:[si],dl					;przepisuje znak do input2
			inc di									;kolejny z argv
			inc si									;kolejny do input2
			jmp wczytaj_zmienna_2					;powtarzam az napotka '!'
		
			zamknij_zmienna_2:
				inc si								;przesuwam input2 o 1 miejsce i dodaje na koniec NULL
				mov byte ptr es:[si],0
				jmp koniec
	
pobierz_nazwy_plikow endp


Ender proc					;konczy program
	mov ah,4ch
	int 21h
	ret
Ender endp

file_error proc				;wywolywane gdy niepowiodla sie praca z plikiem: zapis,odczyt,tworzenie - wiadomosc + koniec programu
	push ax
	push ds
	push dx
	
	mov	ax,seg data
	mov	ds,ax
	mov dx,offset plik_error
	
	mov	ah,9  				; wypisz na ekran to co jest w ds:dx
	int	21h
	mov al,0
	call Ender
	
	pop dx
	pop ds
	pop ax

	ret
file_error endp

utworz_plik proc	;tworzy plik o nawzie która jest w ds:dx // chyba prawo do odczytu
	push ax
	push ds
	push dx
	push cx
	
	mov ax,seg data				
	mov ds,ax
	mov dx,offset input2		;ds:dx nazwa tworzonego pliku, niby nazwa input ale 
	mov cx,0					;atrybut pliku, 0 - tylko do odczytu
	mov ah,3ch					;funkcja zapisu, nawet gdy plik o takiej nazwie już istnieje
	;mov ah,5bh					;funkcja zapisu, nie zapisuje gdy plik już istnieje - kod błędu (jeżeli plik istnieje w ax - kod: 80)
	int 21h
	jc file_error				;jeżeli wystąpił błąd przy pracy z plikiem to w CF będzie jedynka wiec zakonczy sie dzialanie errorem
	
	push ax
	mov ax, seg data
	mov es,ax
	pop ax
	mov di,offset uchwyt		;w uchwyt przechowuję uchwyt do tworzonego pliku
	mov word ptr es:[di],ax		;przekazuję uchwyt
	
	pop cx
	pop dx
	pop ds
	pop ax
	ret
utworz_plik endp

wczytaj_porcje_pliku proc						;zwraca kolejny znak w al badz wczytuje do buffora paczki danych 

	push bx
	push cx
	push es
	push di
	push si

wczytywanie_pliku_input1:	
	mov ax,seg data								;wczytuje segment danych
	mov ds,ax
	
	mov di, offset buffor_ile_wczytanych		
	mov si, offset buffor_ktory_wczytany
	mov ax, word ptr ds:[di]
	cmp word ptr ds:[si], ax					;sprawdzam czy nie przeszedlem buffora
	jb pobieranie_z_buffora_do_al				;jezeli nie to pobieram kolejny znak z buffora, w innym wypadku pobieram nowa porcje danych
	
	pobieranie_do_buffora:
	mov di,offset uchwyt_otwierany
	mov bx,word ptr ds:[di]
	mov cx, 64									;
	mov dx, offset buffor
	mov ah,3Fh
	int 21h
	jc file_error
	
	mov di, offset buffor_ile_wczytanych
	mov word ptr ds:[di],ax
	
	mov si, offset buffor_ktory_wczytany
	mov word ptr ds:[si],0
	
	cmp ax,0
	je ustaw_flage_konca_pliku
	
	
	pobieranie_z_buffora_do_al:
		mov di,word ptr ds:[buffor_ktory_wczytany]
		mov al,byte ptr ds:[buffor + di]
		inc word ptr ds:[buffor_ktory_wczytany]
		
	koniec_wczytywania:	

	pop si
	pop di
	pop es
	pop cx
	pop bx
	ret
		
	ustaw_flage_konca_pliku:
		mov di,offset flaga_konca_pliku
		mov byte ptr ds:[di],1
		jmp koniec_wczytywania
			
wczytaj_porcje_pliku endp

zamknij_plik proc
	push ax
	push bx
	
	mov di,offset uchwyt_otwierany
	mov bx, word ptr ds:[di]
	mov ah,3eh
	int 21h
	jc file_error			;jeżeli wystąpił błąd przy pracy z plikiem to w CF będzie jedynka wiec zakonczy sie dzialanie errorem	
	
	
	pop bx
	pop ax
	ret
zamknij_plik endp

otworz_plik proc
	push ax
	push bx
	push dx
	push ds
	
	mov ax,seg data
	mov ds,ax
	mov ax, 0
	mov dx,offset input1
	mov ah,3Dh
	int 21h
	jc file_error
	
	mov di,offset uchwyt_otwierany
	mov word ptr ds:[di],ax
	
	pop ds
	pop dx
	pop bx
	pop ax
	ret

otworz_plik endp

zapisz_do_pliku proc			;zapisuje dane ze stringa "info" do pliku którego uchwyt w stringu "uchwyt"
	push ax
	push ds
	push dx
	push cx
	
	mov ax, seg data
	mov ds,ax
	mov dx, offset input1_CRC16_string
	mov es,ax
	mov di,offset uchwyt
	mov ax,word ptr es:[di]
	mov bx,ax
	mov cx,4				;ilość zapisywanych znaków
	mov ah,40h				;numer funkcji - zapis
	int 21h
	jc file_error			;jeżeli wystąpił błąd przy pracy z plikiem to w CF będzie jedynka wiec zakonczy sie dzialanie errorem

	pop cx
	pop dx
	pop ds
	pop ax
	ret
zapisz_do_pliku endp



wczytaj_plik_z_CRC proc						;wczytuje dane z intput2 do input2_CRC16 jezeli byly 3 argumenty
	push ax
	push bx
	push dx
	push ds
	
	mov ax,seg data
	mov ds,ax
	
	mov di,offset args_il
	cmp byte ptr ds:[di],2
	je koniec_sprawdzania_CRC
	
	otwieranie_pliku_z_CRC:	
	mov ax, 0
	mov dx,offset input2
	mov ah,3Dh
	int 21h
	jc file_error
	
	
	
	mov di,offset uchwyt_otwierany
	mov word ptr ds:[di],ax
	
wczytywanie_pliku_z_CRC:
	mov bx,word ptr ds:[di]
	mov cx, 4
	mov dx, offset input2_CRC16
	mov ah,3Fh
	int 21h
	jc file_error

	
zamykanie_pliku_z_CRC:
	
	mov di,offset uchwyt_otwierany
	mov bx, word ptr ds:[di]
	mov ah,3Eh
	int 21h
	jc file_error			;jeżeli wystąpił błąd przy pracy z plikiem to w CF będzie jedynka wiec zakonczy sie dzialanie errorem

	
	call porownaj_CRC
	koniec_sprawdzania_CRC:
	pop ds
	pop dx
	pop bx
	pop ax
	ret
wczytaj_plik_z_CRC endp

porownaj_CRC proc
	push ax
	push dx
	push cx
	push es
	push di
	
		xor cx,cx
		mov ax, seg data
		mov ds,ax
		mov di,offset input2_CRC16
		mov si,offset input1_CRC16_string
	
	porownuj:
		cmp cx,4
		je to_samo
		
		mov al,byte ptr ds:[di]
		cmp byte ptr ds:[si],al
		jne nie_to_samo
		
		inc cx
		inc di
		inc si
		
		jmp porownuj
	
	
	
	zakoncz_porownywanie:
	mov	ah,9  				; wypisz na ekran to co jest w ds:dx
	int	21h
	mov al,0
		
	pop di
	pop es
	pop cx
	pop dx
	pop ax
	ret
	
	nie_to_samo:
		mov dx,offset nie_to_samo_CRC
		jmp zakoncz_porownywanie
	
	to_samo:
		mov dx,offset to_samo_CRC
		jmp zakoncz_porownywanie
porownaj_CRC endp

calculate_crc proc
      push  bx
      push  cx
      push  dx
      xor   ah,ah
	  call otworz_plik
      crc_loop:
            call  wczytaj_porcje_pliku
            mov dl,byte ptr ds:[flaga_konca_pliku]
			cmp dl,1
            je  exit_crc_loop

            mov   bx,word ptr ds:[input1_CRC16]
            xor   bx,ax
            and   bx,0FFh
            shl   bx,1
            mov   dx,word ptr ds:[_0_255CRC + bx]
            mov   ax,word ptr ds:[input1_CRC16]
            mov   cl,8
            shr   ax,cl
            xor   ax,dx
            mov   word ptr ds:[input1_CRC16],ax
            jmp   crc_loop

      exit_crc_loop:
	  call zamknij_plik
	  call save_crc
      pop   dx
      pop   cx
      pop   bx
      ret
calculate_crc endp

save_crc proc
      push  bx
      push  cx
      push  dx
      push  es
      push  di
      push  si
	  
      mov   si,offset input1_CRC16

      mov   ax,seg input1_CRC16_string
      mov   es,ax
      lea   di,ds:[input1_CRC16_string+3]
      std
      mov   cx,4
      save_crc_loop:
            mov   bx,word ptr ds:[input1_CRC16]
            mov   ax,4
            sub   ax,cx ;w ax nr znaku heksowego
            push  cx
            mov   cl,2  ; mnozenie ax * 4
            shl   ax,cl ;w ax ilosc bitow do przesuniecia
            mov   cx,ax
            shr   bx,cl
            pop   cx

            and   bx,000Fh
            mov   al,ds:[bytes + bx]
            stosb
            loop  save_crc_loop      

      cld
	  
      pop   si
      pop   di
      pop   es
      pop   dx
      pop   cx
      pop   bx
      ret
save_crc endp


utworz_plik_output proc
	pusha
	mov ax,seg data
	mov ds,ax
	mov di,offset args_il
	cmp byte ptr ds:[di],3
	je zakoncz_tworzenie_pliku
	
	
	call utworz_plik
	call zapisz_do_pliku
	
	mov di,offset uchwyt			;zamknij plik
	mov bx, word ptr ds:[di]
	mov ah,3eh
	int 21h
	jc file_error
	
	
	zakoncz_tworzenie_pliku:
	popa
	ret 
utworz_plik_output endp






start:
call parse
call policz_argumenty
call sprawdz_argumenty
call pobierz_nazwy_plikow
call calculate_crc
call wczytaj_plik_z_CRC
call utworz_plik_output

call Ender

	
code ends


stos1	segment stack
		dw	3FFh dup(?)
		db 3FFh dup(?)
top1	dw	?
stos1	ends
end start

