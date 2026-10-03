# A terminal calculator
#
# Reads a line of input, interprets it as a simple arithmetic expression,
# and prints the result. The input format is
# <long_integer> <operation> <long_integer>

# Make `main` accessible outside of this module
.global main

# Start of the code section
.text

main:
  # Function prologue
  enter $0, $0

  # Use scanf to retrieve and process a line of input
  # This block implements the following line of C code:
  #   scanf("%ld %c %ld", &a, &op, &b);
  # Take a look at the man page for scanf and ask questions. You can also look
  # at scanf_example.c
  movq $scanf_fmt, %rdi
  movq $a, %rsi
  movq $op, %rdx
  movq $b, %rcx
  xorb %al, %al
  call scanf

  movb op, %r8b # load the operation for comparisons
  movq a, %rax  # and the LHS

  # Analyze operation and execute
  cmpb $'+', %r8b
  je add_op

  cmpb $'-', %r8b
  je sub_op

  cmpb $'*', %r8b
  je mul_op

  cmpb $'/', %r8b
  je div_op

  # none matched
  jmp unknown_op

  add_op:
    # result = a + b
    addq b, %rax
    jmp print_result
  
  sub_op:
    # result = a - b
    subq b, %rax
    jmp print_result
  
  mul_op:
    # result = a * b
    imulq b, %rax
    jmp print_result
  
  div_op:
    # check for dividing by 0
    cmpq $0, b
    je division_error

    # result = a / b
    cqto
    idivq b
    jmp print_result
  
  # Print result
  print_result:
    # printf("%ld\n", result);
    movq %rax, %rsi
    movq $output_fmt, %rdi
    xorb %al, %al
    call printf

    # return 0 for success
    movl $0, %eax
    jmp done

  # Print error if operation cannot be (safely) performed
  unknown_op:
    # unknown operation
    movq $unknown_msg, %rdi
    xorb %al, %al
    call printf

    # return 1 for error
    movl $1, %eax
    jmp done

  division_error:
    # division by 0 error
    movq $division_msg, %rdi
    xorb %al, %al
    call printf

    # return 1 for error
    movl $1, %eax

  # Function epilogue
  done:
    leave
    ret


# Start of the data section
.data

output_fmt:
  .asciz "%ld\n"
scanf_fmt:
  .asciz "%ld %c %ld"
unknown_msg:
  .asciz "Unknown operation\n"
division_msg:
  .asciz "Division by zero\n"

# "Slots" for scanf
a:  .quad 0
b:  .quad 0
op: .byte 0

