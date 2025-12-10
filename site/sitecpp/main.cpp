#include "crow_all.h"
#include <filesystem>
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>

namespace fs = std::filesystem;
std::string get_mime_type(const std::string& ext) {
    if (ext == ".html") return "text/html";
    if (ext == ".js")   return "application/javascript";
    if (ext == ".wasm") return "application/wasm";
    if (ext == ".css")  return "text/css";
    if (ext == ".png")  return "image/png";
    if (ext == ".pck")  return "application/octet-stream";
    return "text/plain";
}

int main()
{
    crow::SimpleApp app;
    crow::mustache::set_base("templates");
    CROW_ROUTE(app, "/")
    ([](){
        try {
            auto page = crow::mustache::load("main.html");
            return crow::response(page.render());
        }
        catch (const std::exception& e) {
            return crow::response(500, "Template Error");
        }
    });
    CROW_ROUTE(app, "/godot_game/<path>")
    ([](crow::response& res, std::string path){
        fs::path full_path = fs::current_path() / "godot_game" / path;
        std::cout << "DEBUG: Requested: " << full_path.string() << std::endl;
        if (!fs::exists(full_path) || !fs::is_regular_file(full_path)) {
            std::cout << "ERROR: File missing: " << full_path.string() << std::endl;
            res.code = 404;
            res.end();
            return;
        }
        std::ifstream file(full_path, std::ios::binary);

        if (!file.is_open()) {
            std::cout << "ERROR: Cannot open file permissions!" << std::endl;
            res.code = 500;
            res.end();
            return;
        }
        std::ostringstream buffer;
        buffer << file.rdbuf();
        std::string file_content = buffer.str();
        std::string ext = full_path.extension().string();
        res.set_header("Content-Type", get_mime_type(ext));
        res.add_header("Cross-Origin-Opener-Policy", "same-origin");
        res.add_header("Cross-Origin-Embedder-Policy", "require-corp");
        std::cout << "SUCCESS: Sending " << file_content.size() << " bytes." << std::endl;
        res.write(file_content);
        res.end();
    });

    app.loglevel(crow::LogLevel::Warning);
    app.port(8080).multithreaded().run();
}
