#include "crow_all.h"
#include <filesystem>
#include <string>

namespace fs = std::filesystem;

int main()
{
    // 1. Создаем приложение
    crow::SimpleApp app;

    // 2. Настраиваем папку шаблонов
    crow::mustache::set_base("templates");

    // 3. Определяем маршрут
    // Обратите внимание: CROW_ROUTE(app, "/") НЕ должен быть внутри других скобок
    CROW_ROUTE(app, "/")
    ([](){
        std::string template_name = "main.html";
        fs::path template_path = fs::current_path() / "templates" / template_name;

        // Проверка наличия файла
        if (!fs::exists(template_path)) {
            return crow::response(404, "Template not found");
        }

        try {
            // Загрузка и рендеринг
            auto page = crow::mustache::load(template_name);

            // Исправление ошибки типов: сразу возвращаем результат рендера
            crow::response res = page.render();
            return res;
        }
        catch (const std::exception& e) {
            return crow::response(500, std::string("Error rendering template: ") + e.what());
        }
    });

    // 4. Запуск сервера
    app.port(8080).multithreaded().run();
}
