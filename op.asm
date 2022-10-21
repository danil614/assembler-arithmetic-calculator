.MODEL SMALL
.STACK 100h
.CODE

getNumber proc
	xor bx, bx
	xor cx, cx ; ���� �����
	
	mov ah, 01h ; ������� ����� ������ �������
	int 21h	
	cmp al, '-' ; ���� ������ -, �� ��� ����� �������������
	jne notNegative
	mov cx, 1
	jmp inNextNum
	
	inNextNum:
		mov ah, 01h ; ������� ����� ������ �������
		int 21h

		cmp al, 2Fh ; ���� ������ enter, �� ��� ����� ����� 
		jl endNumber

	notNegative:
		sub al, 30h ; ������ �� ���������� ������� �����
		xor ah, ah ; ah := 0
		xchg ax, bx ; (ax, bx) := (bx, ax)
		mov dx, 0Ah ; dx := 10
		mul dx ; �������� �� ��������� ������� ��������� = 10, dx:ax := dx * ax
		
		jo notNumber ; ������������
		
		add bx, ax ; ���������� ����� �����, bx := bx + ax

		jmp inNextNum
	
	endNumber:
		cmp cx, 1
		je negativeEnd
		ret
	
	negativeEnd:
		neg bx ; ����� ����� �����
		ret
	
	notNumber:
		mov ah, 02h
		mov dl, 'X'
		int 21h
		mov ax, 4c00h ; �����
		int 21h
		ret
getNumber endp

printNumber proc ; INPUT: AX
; ��������� ����� �� ����.
	test ax, ax ; == and, �� ��� ���������
	jns notNegativeNum ; ��������� ��������������� => notNegativeNum

; ���� ��� �������������, ������� ����� � ������� ��� ������.
	mov cx, ax
	mov ah, 02h
	mov dl, '-'
	int 21h
	mov ax, cx
	neg ax ; ����� ����� �����

notNegativeNum:
	xor cx,cx ; cx=0, �������
	mov bx, 0Ah ; ������� � 10-�� ��

outNextNum:
		xor dx, dx ; dx = 0
		div bx ; ax mod bx -> dx, ax div bx -> ax
		push dx ; � ����
		inc cx ; +1
		and ax, ax
		jnz outNextNum ; ������� �� �� ����� ����
		
	printNumberFromStack:
		mov ah, 02h ; ������� ������ �������
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
	shl bx, 1 ; ����� ����� => bx := bx * 2 = (b + c) * 2

	shl ax, 1 ; ����� ����� => ax := ax * 2 = a * 2
	shl ax, 1 ; ����� ����� => ax := ax * 2 = a * 4

	sub ax, bx ; ax := ax - bx = a * 4 - (b + c) * 2
	
	call printNumber
	
	mov ax, 4c00h ; �����
	int 21h
end main