#include <stdio.h>
#include <string.h>
#include "http_core.h"

int main() {
    char input[256];

    if (!init_network()) {
        printf("Failed to init Winsock\n");
        return 1;
    }

    printf("==========================================\n");
    printf("   GODOT SERVER REAL-TIME DEBUGGER (C)    \n");
    printf("==========================================\n");
    printf("commands:\n");
    printf("  /path/to/file  -> check this url\n");
    printf("  exit           -> close debugger\n");
    printf("==========================================\n");

    while (1) {
        printf("\ndebugger> ");
        if (scanf("%255s", input) != 1) break;

        if (strcmp(input, "exit") == 0 || strcmp(input, "quit") == 0) {
            break;
        }

        check_url_auto(input);
    }

    cleanup_network();
    return 0;
}
