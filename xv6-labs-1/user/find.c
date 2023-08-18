#include "kernel/types.h"
#include "kernel/fcntl.h"
#include "kernel/fs.h"
#include "kernel/stat.h"
#include "user/user.h"

char *basename(char *pathname) {
  char *prev = 0;
  char *curr = strchr(pathname, '/');
  while (curr != 0) {
    prev = curr;
    curr = strchr(curr + 1, '/');
  }
  return prev;
}

void find(char *curr_path, char *target) {
  char buf[512], *p;
  int fd;
  char *f_name = "";
  int match = 1;
  struct dirent de;
  struct stat st;
  if ((fd = open(curr_path, O_RDONLY)) < 0) {
    fprintf(2, "find: cannot open %s\n", curr_path);
    return;
  }

  if (fstat(fd, &st) < 0) {
    fprintf(2, "find: cannot stat %s\n", curr_path);
    close(fd);
    return;
  }

  switch (st.type) {

  case T_FILE:
    f_name = basename(curr_path);
    if (f_name == 0 || strcmp(f_name + 1, target) != 0) {
      match = 0;
    }
    if (match)
      printf("%s\n", curr_path);
    close(fd);
    break;

  case T_DIR:
    memset(buf, 0, sizeof(buf));
    uint curr_path_len = strlen(curr_path);
    memcpy(buf, curr_path, curr_path_len);
    buf[curr_path_len] = '/';
    p = buf + curr_path_len + 1;
    while (read(fd, &de, sizeof(de)) == sizeof(de)) {
      if (de.inum == 0 || strcmp(de.name, ".") == 0 ||
          strcmp(de.name, "..") == 0)
        continue;
      memcpy(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      find(buf, target); 
    }
    close(fd);
    break;
  }
}

int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(2, "usage: find [directory] [target filename]\n");
    exit(1);
  }
  find(argv[1], argv[2]);
  exit(0);
}
