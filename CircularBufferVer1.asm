format PE console 6.0
entry main
include 'win32ax.inc'

BUFFER_SIZE = 11

struct Buffer
	pFront		dd	?
	pRear		dd	?
	bufferData	dd	BUFFER_SIZE	dup	?
ends

section '.code' code readable executable
main:
	
	ccall Main
	invoke ExitProcess,eax
	
	proc Main c
	local buffer:Buffer
	local adrBuffer:DWORD
		
		lea eax,[buffer]
		mov [adrBuffer],eax
		
		cinvoke printf,<'init...',13,10,0>
		ccall init,[adrBuffer]
		
		ccall print,[adrBuffer]
		
		cinvoke printf,<'putting some values in the buffer...',13,10,0>
		ccall put,[adrBuffer],1
		ccall put,[adrBuffer],2
		ccall put,[adrBuffer],3
		ccall put,[adrBuffer],4
		ccall put,[adrBuffer],5
		ccall put,[adrBuffer],6
		ccall put,[adrBuffer],7
		ccall put,[adrBuffer],8
		ccall put,[adrBuffer],9
		ccall put,[adrBuffer],10
		ccall print,[adrBuffer]
		
		cinvoke printf,<'ups...',13,10,0>
		ccall put,[adrBuffer],11
		
		cinvoke printf,<'get out 1. and 2. ...',13,10,0>
		ccall get,[adrBuffer]
		ccall get,[adrBuffer]
		
		cinvoke printf,<'what is left...',13,10,0>
		ccall print,[adrBuffer]
		
		cinvoke printf,<'add two more...',13,10,0>
		ccall put,[adrBuffer],11
		ccall put,[adrBuffer],12
		
		cinvoke printf,<'print the buffer...',13,10,0>
		ccall print,[adrBuffer]
		
		cinvoke printf,<'thats is it, Circular Buffer in the FASM...',13,10,0>
		cinvoke printf,<'exit...',13,10,0>
		xor eax,eax
		ret
	endp
	
	proc put c uses ebx esi edi,adrBuffer,value
		ccall isFull,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'The Buffer is Full...',13,10,0>
			jmp .out		
		.endif
		
		mov eax,[value]
		mov ebx,[adrBuffer]
		mov ecx,BUFFER_SIZE * 4
		lea edx,[ebx + Buffer.bufferData]
		mov edi,edx
		add edx,ecx
		mov esi,[ebx + Buffer.pRear]
		mov [esi],eax
		add esi,1 * 4
		.if esi = edx
			mov esi,edi
		.endif
		mov[ebx + Buffer.pRear],esi
		
		xor eax,eax
	.out:	
		ret
	endp
	
	proc get c uses ebx esi edi,adrBuffer
	local value:DWORD
		
		ccall isEmpty,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'The Buffer is Empty...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrBuffer]
		mov ecx,BUFFER_SIZE * 4
		lea edx,[ebx + Buffer.bufferData]
		mov edi,edx
		add edx,ecx
		mov esi,[ebx + Buffer.pFront]
		mov eax,[esi]
		mov [value],eax
		add esi,1 * 4
		.if esi = edx
			mov esi,edi
		.endif
		mov [ebx + Buffer.pFront],esi
		
		cinvoke printf,<'Element %d is out...',13,10,0>,[value]
		
		xor eax,eax
	.out:
		ret
	endp
	
	proc print c uses ebx esi edi,adrBuffer
		ccall isEmpty,[adrBuffer]
		.if eax = 1
			cinvoke printf,<'nothing to print, the buffer is empty...',13,10,0>
			jmp .out
		.endif
		
		mov ebx,[adrBuffer]
		mov esi,[ebx + Buffer.pFront]
		lea edi,[ebx + Buffer.bufferData]
		.repeat
			cinvoke printf,<'Element %d',13,10,0>,dword[esi]
			add esi,1 * 4
			mov ecx,BUFFER_SIZE * 4
			mov edx,edi
			add edx,ecx
			.if esi = edx
				mov esi,edi
			.endif
		.until esi = [ebx + Buffer.pRear]
	
	.out:	
		xor eax,eax
		ret
	endp
	
	proc isFull c uses ebx esi edi,adrBuffer
		mov ebx,[adrBuffer]
		mov esi,[ebx + Buffer.pFront]
		mov edi,[ebx + Buffer.pRear]
		add edi,1 * 4
		.if esi = edi
			mov eax,1
			jmp .out
		.endif
		
		sub edi,1 * 4
		lea edx,[ebx + Buffer.bufferData]
		mov eax,edx
		mov ecx,(BUFFER_SIZE - 1) * 4
		add edx,ecx
		.if edi = edx & esi = eax
			mov eax,1
			jmp .out
		.endif
		
		xor eax,eax
	.out:	
		ret
	endp
	
	proc isEmpty c uses ebx,adrBuffer
		mov ebx,[adrBuffer]
		mov edx,[ebx + Buffer.pFront]
		.if edx = [ebx + Buffer.pRear]
			mov eax,1
			jmp .out
		.endif
		
		xor eax,eax
	.out:	
		ret
	endp
	
	proc init c uses ebx,adrBuffer
		mov ebx,[adrBuffer]
		lea edx,[ebx + Buffer.bufferData]
		mov [ebx + Buffer.pFront],edx
		mov [ebx + Buffer.pRear],edx
		xor ecx,ecx
		.repeat
			mov dword[edx + ecx * 4],0
			inc ecx
		.until ecx = BUFFER_SIZE
		
		xor eax,eax
		ret
	endp
	
section '.data' data readable writeable
	nop

section '.idata' data import readable
	library kernel32,'kernel32.dll',\
			msvcrt,'msvcrt.dll'

	import kernel32,\
			ExitProcess,'ExitProcess'

	import msvcrt,\			
			printf,'printf'
			
