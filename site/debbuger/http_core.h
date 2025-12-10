#ifndef HTTP_CORE_H
#define HTTP_CORE_H

#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdio.h>


#define SERVER_IP "127.0.0.1"
#define SERVER_PORT 8080
#define BUFFER_SIZE 4096

int init_network();
void cleanup_network();

void check_url_auto(const char* path);

#endif
