#include "kernel/types.h"
#include "user/user.h"


int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(2, "usage: sleep [ticks num]\n");
    exit(1);
  }
  // atoi sys call guarantees return an integer
  int ticks = atoi(argv[1]);
  int sleep_time = sleep(ticks);
  exit(sleep_time);
}



