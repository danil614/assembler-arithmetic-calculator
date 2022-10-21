.MODEL SMALL
.STACK 100h
.CODE

getNumber proc
	xor bx, bx
	xor cx, cx ; флаг знака
	
	mov ah, 01h ; функция ввода нового символа
	int 21h	
	cmp al, '-' ; если нажали -, то это число отрицательное
	jne notNegative
	mov cx, 1
	jmp inNextNum
	
	inNextNum:
		mov ah, 01h ; функция ввода нового символа
		int 21h

		cmp al, 2Fh ; если нажали enter, то это конец числа 
		jl endNumber

	notNegative:
		sub al, 30h ; делаем из введенного символа число
		xor ah, ah ; ah := 0
		xchg ax, bx ; (ax, bx) := (bx, ax)
		mov dx, 0Ah ; dx := 10
		mul dx ; умножаем на основание системы счисления = 10, dx:ax := dx * ax
		
		jo notNumber ; переполнение
		
		add bx, ax ; прибавляем новое число, bx := bx + ax

		jmp inNextNum
	
	endNumber:
		cmp cx, 1
		je negativeEnd
		ret
	
	negativeEnd:
		neg bx ; смена знака числа
		ret
	
	notNumber:
		mov ah, 02h
		mov dl, 'X'
		int 21h
		mov ax, 4c00h ; выход
		int 21h
		ret
getNumber endp

printNumber proc ; INPUT: AX
; Проверяем число на знак.
	test ax, ax ; == and, но без изменения
	jns notNegativeNum ; результат неотрицательный => notNegativeNum

; Если оно отрицательное, выведем минус и оставим его модуль.
	mov cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	neg ax ; смена знака числа

notNegativeNum:
	xor cx,cx ; cx=0, счетчик
	mov bx, 0Ah ; перевод в 10-ую сс

outNextNum:
		xor dx, dx ; dx = 0
		div bx ; ax mod bx -> dx, ax div bx -> ax
		push dx ; в стек
		inc cx ; +1
		and ax, ax
		jnz outNextNum ; переход по не равно нулю
		
	printNumberFromStack:
		mov ah, 02h ; функция вывода символа
		pop dx
		add dl, 30h
		int 21h
		dec cx ; -1
		jnz printNumberFromStack
		ret
printNumber endp

main:
	call getNumber
	push bx
	call getNumber
	push bx
	call getNumber
	push bx

	pop cx
	pop bx
	pop ax
	
	add bx, cx ; bx := bx + cx = b + c
	shl bx, 1 ; сдвиг влево => bx := bx * 2 = (b + c) * 2

	shl ax, 1 ; сдвиг влево => ax := ax * 2 = a * 2
	shl ax, 1 ; сдвиг влево => ax := ax * 2 = a * 4

	sub ax, bx ; ax := ax - bx = a * 4 - (b + c) * 2
	
	call printNumber
	
	mov ax, 4c00h ; выход
	int 21h
end main