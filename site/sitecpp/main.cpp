#include "crow_all.h"
#include <filesystem>
#include <string>

namespace fs = std::filesystem;

int main()
{

    crow::SimpleApp app;


    crow::mustache::set_base("templates");

    CROW_ROUTE(app, "/")
    ([](){
        std::string template_name = "main.html";
        fs::path template_path = fs::current_path() / "templates" / template_name;

        if (!fs::exists(template_path)) {
            return crow::response(404, "Template not found");
        }

        try {
            auto page = crow::mustache::load(template_name);
            crow::response res = page.render();
            return res;
        }
        catch (const std::exception& e) {
            return crow::response(500, std::string("Error rendering template: ") + e.what());
        }
    });

    CROW_ROUTE(app, "/godot_game/<path>")
    ([](crow::response& res, std::string path){
        std::string file_path = "godot_game/" + path;

        res.set_static_file_info(file_path);
        res.end();
    });

    // 4. Запуск сервера
    app.port(8080).multithreaded().run();
}
