#include <unistd.h>

typedef unsigned char byte;

int read_command(byte *buffer);
int write_command(byte *buffer, int length);
int read_exact(byte *buffer, int length);
int write_exact(byte *buffer, int length);

// The actual functions doing work for us
int add_one(int first_number);
int multiply_by_two(int first_number);

int main(void)
{
    int function_to_call = 0;
    int argument = 0;
    int response = 0;

    byte buffer[100];

    while (read_command(buffer) > 0)
    {

        function_to_call = buffer[0];
        argument = buffer[1];

        if (function_to_call == 1)
        {
            response = add_one(argument);
        }
        else if (function_to_call == 2)
        {
            response = multiply_by_two(argument);
        }

        buffer[0] = response;
        write_command(buffer, 1);
    }
}

// --------------------------------------------------------------
// --------------------------------------------------------------

int read_command(byte *buffer)
{
    int length;

    if (read_exact(buffer, 2) != 2) {
        return -1;
    }

    // Not sure about this part...
    // Why can we know that there is 2 parts?
    length = (buffer[0] << 8) | buffer[1];

    return read_exact(buffer, length);
}

// --------------------------------------------------------------

int write_command(byte *buffer, int length)
{
    byte li; // li means ... what? list-item?

    // right shift 8
    //    & it with 0xff (which is 11111111)
    // => the rightmost 8 bits/1 byte of li
    li = (length >> 8) & 0xff;
    write_exact(&li, 1);

    li = length & 0xff;
    write_exact(&li, 1);

    return write_exact(buffer, length);
}

// --------------------------------------------------------------

int read_exact(byte *buffer, int length)
{
    int index = 0;
    int read_so_far = 0;

    do {

        index = read(0, buffer + read_so_far, length - read_so_far);

        if (index <= 0) {
            return index;
        }

        read_so_far += index;

    } while (read_so_far < length);

    return length;
}

// --------------------------------------------------------------

int write_exact(byte *buffer, int length)
{
    int index = 0;
    int written = 0;

    do {

        index = write(1, buffer + written, length - written);

        if (index <= 0) {
            return index;
        }

        written += index;

    } while (written < length);

    return length;
}

// --------------------------------------------------------------
// --------------------------------------------------------------

int add_one(int first_number)
{
    return first_number + 1;
}


int multiply_by_two(int first_number)
{
    return first_number * 2;
}
