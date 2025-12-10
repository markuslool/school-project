#include "http_core.h"
#include <string.h>
#include <stdlib.h>

int init_network() {
    WSADATA wsaData;
    return (WSAStartup(MAKEWORD(2, 2), &wsaData) == 0);
}

void cleanup_network() {
    WSACleanup();
}

const char* get_mime_from_extension(const char* path) {
    const char* dot = strrchr(path, '.');
    if (!dot) return NULL;

    if (strcmp(dot, ".html") == 0) return "text/html";
    if (strcmp(dot, ".js")   == 0) return "application/javascript";
    if (strcmp(dot, ".wasm") == 0) return "application/wasm";
    if (strcmp(dot, ".css")  == 0) return "text/css";
    if (strcmp(dot, ".png")  == 0) return "image/png";
    if (strcmp(dot, ".pck")  == 0) return "application/octet-stream";
    return "text/plain";
}

void check_url_auto(const char* path) {
    SOCKET sock;
    struct sockaddr_in server;
    char request[1024];
    char response[BUFFER_SIZE];
    int recv_size;
    const char* expected_mime = get_mime_from_extension(path);

    printf("\n>>> CHECKING: %s\n", path);
    if (expected_mime) printf("    (Expecting type: %s)\n", expected_mime);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == INVALID_SOCKET) {
        printf("[ERR] Socket creation failed\n");
        return;
    }

    server.sin_addr.s_addr = inet_addr(SERVER_IP);
    server.sin_family = AF_INET;
    server.sin_port = htons(SERVER_PORT);


    if (connect(sock, (struct sockaddr *)&server, sizeof(server)) < 0) {
        printf("[ERR] CANNOT CONNECT to localhost:8080. Is server running?\n");
        closesocket(sock);
        return;
    }

    snprintf(request, sizeof(request),
             "GET %s HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n", path);

    if (send(sock, request, strlen(request), 0) < 0) {
        printf("[ERR] Send failed\n");
        closesocket(sock);
        return;
    }

    recv_size = recv(sock, response, BUFFER_SIZE - 1, 0);
    closesocket(sock);

    if (recv_size == SOCKET_ERROR || recv_size == 0) {
        printf("[ERR] Empty response or error reading\n");
        return;
    }
    response[recv_size] = '\0';

    if (strstr(response, "200 OK")) {
        printf("[PASS] HTTP 200 OK\n");
    } else if (strstr(response, "404 Not Found")) {
        printf("[FAIL] HTTP 404 - File Not Found!\n");
        return; // Нет смысла проверять дальше
    } else if (strstr(response, "403 Forbidden")) {
        printf("[FAIL] HTTP 403 - Access Denied (Security Block?)\n");
        return;
    } else {
        // Выводим первую строку ответа для понимания ошибки
        char* end_line = strstr(response, "\r\n");
        if (end_line) *end_line = '\0';
        printf("[WARN] Unexpected Status: %s\n", response);
        return;
    }

    int coop = (strstr(response, "Cross-Origin-Opener-Policy: same-origin") != NULL);
    int coep = (strstr(response, "Cross-Origin-Embedder-Policy: require-corp") != NULL);

    if (coop && coep) {
        printf("[PASS] Security Headers (COOP/COEP) are present.\n");
    } else {
        if (!coop) printf("[FAIL] Missing Header: Cross-Origin-Opener-Policy\n");
        if (!coep) printf("[FAIL] Missing Header: Cross-Origin-Embedder-Policy\n");
    }

    if (expected_mime) {
        char header_search[128];
        snprintf(header_search, sizeof(header_search), "Content-Type: %s", expected_mime);

        if (strstr(response, header_search)) {
            printf("[PASS] Content-Type is correct.\n");
        } else {
            printf("[FAIL] WRONG Content-Type! Expected: %s\n", expected_mime);
            char* ct = strstr(response, "Content-Type:");
            if (ct) {
                char* end = strstr(ct, "\r\n");
                if (end) *end = '\0';
                printf("       Server sent: %s\n", ct);
            } else {
                printf("       Server sent NO Content-Type header.\n");
            }
        }
    }
}
