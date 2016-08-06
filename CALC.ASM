model small
stack 256
.386
dataseg
	str db "╔═╤══════════╗",10,13,"║+│          ║",10,13,"╟─┴──────────╢",10,13,"║┌──┬──┬──┬─┐║",10,13,"║│ 7│ 8│ 9│/│║",10,13,"║├──┼──┼──┼─┤║",10,13,"║│ 4│ 5│ 6│*│║",10,13,"║├──┼──┼──┼─┤║",10,13,"║│ 1│ 2│ 3│-│║",10,13,"║├──┴─┬┴──┼─┤║",10,13,"║│  0 │ = │+│║",10,13,"║└────┴───┴─┘║",10,13,"╚════════════╝$",10,13
	about db "Calc for dos version 0.1 beta.",10,13,"Developers: Kushnir A.V. (Avenger)",10,13,"            Shinkoreckiy A.N. (NEO)$"
	chislo dd 00000000h;для цыкла набора
	mem_chislo dd (?)	; число на экране
	cur db 0		;текущий символ
	O_N dd 1234		;аргумент процедуры
	Cur_x db (?)		;положение курсора
	O_ost db (?)		;остаток
	O_Ch dd (?)		;частное
	O_NC db (?)		;количество чисел
	Mem dd (?)		;число в памяти
	Oper db (?)		;операцыя
	FALSE equ 00h		;	
	bbs db (?)		;разрешение бекспэйса
	bel db (?)		;многократное нажатие =
	Oper_prev db (?)	;предыдущая операция
	cur_oper db (?)		;аргумент процедуры
	bOper_Func db (?)	;флаг многократного нажатия управляющих клавиш
codeseg
ORG 100h
start:
;иниц
mov bel,0
mov mem_chislo,0
mov Oper,0
mov mem,0
mov ax,@data
mov ds,ax
mov cx,8
mov O_NC,0
mov chislo,00000000h
mov ah,00h     ;отчистка экрана
mov al,03h     ;параметры экрана
int 10h
mov ah,01h
mov ch,20h
int 10h
;рисование
mov ah,2
mov dh,0
mov dl,0
int 10h
lea dx,str
mov ah,09h
int 21h
;начало главного цикла
mov eax,chislo
mov O_N,eax
call output

M_C2:
push cx

nsim:
mov ah,0h
int 16h
;Проверка эскейпа
cmp al,27
je en
;Проверка цыфр
cmp al,'1'
je sim
cmp al,'2'
je sim
cmp al,'3'
je sim
cmp al,'4'
je sim
cmp al,'5'
je sim
cmp al,'6'
je sim
cmp al,'7'
je sim
cmp al,'8'
je sim
cmp al,'9'
je sim
cmp al,'0'
je sim
;Проверка действий
cmp al,9
jne metka
jmp start
metka:
cmp al,'+'
je Ma
jmp nmA
MA:
mov cur_oper,1
call Oper_Add
nmA:
cmp al,'-'
je MS
jmp nms
Ms:
mov cur_oper,2
call Oper_add
nms:
cmp al,'*'
je Mm
jmp nmm
Mm:
mov cur_oper,3
call Oper_add
nmm:
cmp al,'/'
je Md
jmp nmd
Md:
mov cur_oper,4
call Oper_add
nmd:
cmp al,13
je Me
jmp nme
Me:
call Oper_EQU
nme:
;**************************************************
;Проверка бэкспейса
;**************************************************
cmp al,8
je BS
jmp nsim
;нажатие цыфры
sim:
cmp oper,5
jne metka2
mov chislo,0
mov mem,0
mov mem_chislo,0
mov oper,0
metka2:
mov bbs,1
cmp O_NC,9
jae E_V_C

mov cur,al
jmp nm1
M_C: jmp  M_C2 
nm1:
push eax
push edx
sub cur,'0'
mov eax,chislo
mov ebx,10
mul ebx
mov bl,cur
add eax,ebx
mov chislo,eax
mov mem_chislo,eax
jmp NM2
BS:
cmp bbs,1
jne met1
CALL BACk
NM2:
mov bOper_func,0
mov eax,chislo
mov O_N,eax
Call Output
met1:
pop edx
pop eax
pop cx
jmp NM3
E_V_C:
mov ah,2
mov dl,7
int 21h
NM3:



jmp M_C
rrr:
mov ah,0
int 16h
cmp al,27
jne rrr
mov eax,chislo
en:

mov ah,2
mov dh,20
mov dl,0
int 10h
lea dx,about
mov ah,9
int 21h

 mov ah,4ch
 int 21h

;процедуры






Output proc near
push eax
push ebx
push ecx
push edx
;очисткa

xor ebx,ebx
mov ah,02h
mov dh,1
mov dl,3
int 10h
mov ah,0ah
mov al,' '
mov cx,9
int 10h	

;инициализацыя
mov cur_x,12
mov eax,O_N
mov O_NC,0

;деление
beg:
xor edx,edx
mov ebx,0000000ah
idiv ebx
mov O_ost,dl
mov O_ch,eax


;вывод
mov ah,02h
mov dh,1
mov dl,Cur_x
int 10h
dec cur_x
add O_ost,'0'
mov ah,0ah
mov al,O_ost
mov cx,1
int 10h

;проверка
inc O_NC
mov eax,O_ch
cmp O_ch,0
ja beg
mov ah,2
mov dl,12
mov dh,1
int 10h
pop edx
pop ecx
pop ebx
pop eax
ret
Output endp



Back proc near
Push eax
push ebx
push ecx
push edx
xor edx,edx
cmp bbs,1
jne en1
mov eax,chislo
mov ebx,10
div ebx
mov chislo,eax
en1:
pop edx
pop ecx
pop ebx
pop eax

ret
Back endp


Oper_Add proc
Push eax
push ebx
push ecx
push edx
cmp bOper_func,1
je M_beg
mov bOper_func,1
;********************
;No Oper
;********************
cmp oper,0
jne M_A_N
mov eax,mem_chislo
mov mem,eax
mov mem_chislo,eax
m_A_N:
;*****************
;Add oper
;*****************
cmp oper,1
jne M_A_A
;cmp oper_flag,0
;jne M_A_A
mov eax,mem_chislo
add mem,eax
mov eax,mem
mov mem_chislo,eax
mov O_N,eax
call output

M_A_A:
;*****************
;Equ Oper
;*****************
cmp oper,5
jne M_A_E
mov chislo,0
M_A_E:
;*****************
;sub Oper
;*****************
cmp oper,2
jne M_A_S
mov eax,mem_chislo
sub mem,eax
mov eax,mem
mov mem_chislo,eax
mov O_N,eax
call output

M_A_S:
;*****************
;mull Oper
;*****************
cmp oper,3
JNE M_A_M
mov eax,mem_chislo
mov ebx,mem
mul ebx
mov mem,eax
mov mem_chislo,eax
mov O_N,eax
call output

M_A_M:
;*****************
;div Oper
;*****************
cmp oper,4
jne M_A_D

mov ebx,mem_chislo
mov eax,mem
xor edx,edx
div ebx
mov mem,eax
mov mem_chislo,eax
mov O_N,eax
call output


M_A_D:
;*****************
mov chislo,0
mov bbs,false
mov O_NC,0
m_BEG:
mov bl,cur_oper
mov oper,bl
;mov oper_flag,1
mov bel,0
pop edx
pop ecx
pop ebx
pop eax
ret
Oper_add endp

Oper_EQU proc
Push eax
push ebx
push ecx
push edx
cmp oper,0
je E_End
cmp bel,1
jne NM_E
mov al,oper_prev
mov oper,al
NM_E:
cmp oper,1
jne M_E_A
mov eax,mem_chislo
add mem,eax
M_E_A:
cmp oper,2
jne M_E_S
mov eax,mem
sub eax,mem_chislo
mov mem,eax
M_E_S:
cmp oper,3
jne M_E_M
mov eax,mem
mov ebx,mem_chislo
mul ebx
mov mem,eax
M_E_M:
cmp oper,4
jne M_E_D

mov eax,mem
mov ebx,mem_chislo
xor edx,edx
div ebx
mov mem,eax
M_E_D:

mov eax,mem
;mov mem_chislo,eax
mov O_N,eax
call output
mov O_NC,0
mov bbs,false
;mov oper_flag,0
mov al,oper
mov OPer_prev,al
mov bel,1
mov oper,5
mov bOper_Func,0
E_END:
pop edx
pop ecx
pop ebx
pop eax
ret
Oper_EQU endp

; code ends
 end start
