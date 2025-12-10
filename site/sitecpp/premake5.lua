workspace "SiteCpp"
architecture "x64"
startproject "my_app"

-- Только стандартные конфигурации
configurations { "Debug", "Release" }

project "my_app"
kind "ConsoleApp"
language "C++"
cppdialect "C++17"
targetdir "bin/%{cfg.buildcfg}"

files { "main.cpp", "crow_all.h" }

-- Пути
includedirs { ".", "./asio/include" }

-- Глобальные настройки (для Windows)
system "windows"
toolset "gcc"    -- Используем MinGW
defines { "ASIO_STANDALONE", "_WIN32", "WIN32" }
links { "ws2_32", "mswsock" }

filter "configurations:Debug"
defines { "DEBUG" }
symbols "On"

filter "configurations:Release"
defines { "NDEBUG" }
optimize "On"
