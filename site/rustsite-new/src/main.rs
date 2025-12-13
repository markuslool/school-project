use axum::Router;
use std::net::SocketAddr;
use std::env;
use tower::ServiceBuilder;
use tower_http::{
    services::{ServeDir, ServeFile},
    set_header::SetResponseHeaderLayer,
};
use http::{header::HeaderName, HeaderValue};

#[tokio::main]
async fn main() {
    // 1. Инициализация логов
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .init();

    // 2. Получаем порт (для Heroku)
    let port_str = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let port = port_str.parse::<u16>().expect("PORT must be a number");

    // 3. Настраиваем заголовки (ОБЯЗАТЕЛЬНО для работы Godot 4)
    let coop_layer = SetResponseHeaderLayer::overriding(
        HeaderName::from_static("cross-origin-opener-policy"),
        HeaderValue::from_static("same-origin"),
    );
    let coep_layer = SetResponseHeaderLayer::overriding(
        HeaderName::from_static("cross-origin-embedder-policy"),
        HeaderValue::from_static("require-corp"),
    );

    // 4. Настраиваем папки с файлами
    // Папка с ассетами игры (.pck, .wasm, .js)
    let godot_assets = ServeDir::new("godot_game")
        .append_index_html_on_directories(false);
    
    // Папка со стилями (если ты создал папку "static" для main.css)
    let static_assets = ServeDir::new("static");

    // 5. Маршрутизация (Самое важное!)
    let app = Router::new()
        // --> ГЛАВНАЯ СТРАНИЦА (index.html)
        .route_service("/", ServeFile::new("templates/index.html"))
        .route_service("/index.html", ServeFile::new("templates/index.html"))

        // --> СТРАНИЦА "О НАС" (about.html)
        .route_service("/about.html", ServeFile::new("templates/about.html"))

        // --> САМА ИГРА (main.html)
        // Теперь игра доступна по адресу /game
        .route_service("/game", ServeFile::new("templates/main.html"))
        // На случай, если в ссылках осталось main.html
        .route_service("/main.html", ServeFile::new("templates/main.html"))

        // --> Подключение папок
        .nest_service("/godot_game", godot_assets) // Файлы движка
        .nest_service("/static", static_assets)    // CSS стили

        // --> Применяем заголовки ко всему сайту
        .layer(
            ServiceBuilder::new()
                .layer(coop_layer)
                .layer(coep_layer)
        );

    // 6. Запуск сервера
    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    tracing::info!("Server running at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}