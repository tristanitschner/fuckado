// SPDX-License-Identifier: GPL-3.0-or-later
// (c) Tristan Itschner 2022

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>

#define string2(x) #x
#define string(x) string2(x)
//#define M 4
//#define N 32


#define CRCPOLY	0x1edc6f41
#define REVERSE 

typedef struct {
  char designator[10];
  uint64_t polynomial;
  int N;
} crc_t;

crc_t crcs[] = 
{
  {{"crc32"},   0x04C11DB7, 32},
  {{"crc32c"},  0x1EDC6F41, 32},
  {{"crc32k"},  0x741B8CD7, 32},
  {{"crc32k2"}, 0x32583499, 32},
  {{"crc32q"},  0x814141AB, 32},
};


void table_generator(char name[], uint32_t poly, int N, int M, int reversed, FILE * dest)
{
  uint32_t table[256]; // TODO: dynamically allocate
  uint32_t poly_r = 0;

  if (reversed) {
	for (int i = 0; i < N; i++) {
	  poly_r |= (((1 << i) & poly) >> i) << (31 - i);
	}
	//printf("reversed %8x\n", poly_r);
  } else {
	poly_r = poly;
  }

  uint32_t c;
  int n, k;

  fprintf(dest, "\n");

  fprintf(dest, "-- %s, polynomial 0x%08x", name, poly);

  fprintf(dest, ", %i bits at once", M);

  if (reversed) {
	fprintf(dest, ", reversed\n");
  } else {
	fprintf(dest, ", not reversed\n");
  }


  fprintf(dest, "\n");

  fprintf(dest, "constant %stable%i : crc32table_t (0 to 2**%i - 1) := (", name, M, M);

  for (n = 0; n < (1 << M); n++) {
	if (!(n % 4)) fprintf(dest, "\n");
	c = n;
	for (k = 0; k < M; k++) {
	  if ((c & 1) != 0) {
		c = poly_r ^ (c >> 1);
	  } else {
		c = c >> 1;
	  }
	}
	table[n] = c;
	fprintf(dest, "\t%ix\"%08x\"",N,c);
	if (n != (1 << M) - 1) fprintf(dest, ", ");
  }

  fprintf(dest, "\n);\n\n\n");
}

int main(int argc, char ** argv)
{
  FILE * out;
  if (argc == 0) {
    printf("Error: You need to provide the destination file as first argument.");
    exit(1);
  }
  out = fopen(argv[1], "w");
  fprintf(out, 
	  "library ieee;\n"
	  "use ieee.numeric_std.all;\n"
	  "use ieee.std_logic_1164.all;\n"
	  );
  fprintf(out, "package crc is\n");
  fprintf(out, "type crc32table_t is array (integer range <>) of std_logic_vector(%i - 1 downto 0);\n", 32);

  //fprintf(out, "constant M : integer := %i; -- crc bits calculated during one clock\n", M);
  //fprintf(out, "constant N : integer := %i; -- length of crc polynomial\n", N);
  for (int i = 0; i < sizeof(crcs) / sizeof(crc_t); i++) {
	table_generator(crcs[i].designator, crcs[i].polynomial, crcs[i].N, 8, 1, out);
	table_generator(crcs[i].designator, crcs[i].polynomial, crcs[i].N, 4, 1, out);
	table_generator(crcs[i].designator, crcs[i].polynomial, crcs[i].N, 2, 1, out);
	table_generator(crcs[i].designator, crcs[i].polynomial, crcs[i].N, 1, 1, out);
  }
  fprintf(out, "end package;");
}
